function [truth,parts]=filtering_2_TIP(boxes,gt,imgsize,saliency,beta)
disp(imgsize)
    ft_boxes=[];
    truth=0;
    parts=zeros(2 , 4);
    overlap=boxoverlap(boxes,gt);
    overlap=overlap';
if min(size(imgsize)) > 224
    scale_map=224./imgsize;
else
   scale_map = min(size(imgsize))./imgsize;
end
    check=0;
    saliency=double(saliency);
%    thresh=double(thresh);
    gt_area=cal_area(gt);
    if check<2
        check=0;
        ft_boxes=[];
        for i=1:size(boxes,1)
            if overlap(i)>0.7
                temp_area=cal_area(boxes(i,:));
                if overlap(i)*temp_area/gt_area>0.4 
                    ft_boxes=cat(1,ft_boxes,boxes(i,:));
                    check=check+1;
                end
            end
        end
    end
    fprintf('origin check: %d\n',check);
    if   check<2
        check=0;
        ft_boxes=[];
        for i=1:size(boxes,1)
 %           if overlap(i)>0.5
                temp_area=cal_area(boxes(i,:));
                if overlap(i)*temp_area/gt_area>0.4
                    ft_boxes=cat(1,ft_boxes,boxes(i,:));
                    check=check+1;
                end
  %          end
        end
    end
    fprintf('second check: %d\n',check);
    if check>200
        del_num=check-200;
        for i=1:del_num
            del_box_num=rand()*(check-i+1);
            del_box_num=ceil(del_box_num);
            ft_boxes(del_box_num,:)=[];
        end
    end
    if check<2
        check=0;
        ft_boxes=[];
        for i=1:size(boxes,1)
%             if overlap(i)>0.5
                temp_area=cal_area(boxes(i,:));
                if overlap(i)*temp_area/gt_area>0.3 
                    ft_boxes=cat(1,ft_boxes,[boxes(i,:),overlap(i)]);
                    check=check+1;
                end
%             end
        end
        if check>=2
            [~,ps_up]=max(ft_boxes(:,5));
            ft_boxes(ps_up,5)=0;
            [~,ps_up2]=max(ft_boxes(:,5));
            parts(1,:) = ft_boxes(ps_up,1:4);
            parts(2,:) = ft_boxes(ps_up2,1:4) ;
        %parts=cat(1,parts,boxes(ps_up,:));
        %parts=cat(1,parts,boxes(ps_up2,:));
            return;
        end
    end
    if check<2
        [~,ps_up]=max(overlap);
        overlap(ps_up)=0;
        [~,ps_up2]=max(overlap);
        parts(1,:) = boxes(ps_up,:);
        parts(2,:) = boxes(ps_up2,:) ;
        return;
    end
    fprintf('check %d\n' , check) ;
    box_num=size(ft_boxes,1);
    fprintf('box_num %d\n',box_num);
    totalnum = (box_num - 1) * box_num / 2 ;
    scores=zeros(totalnum , 5);
    cont = 1 ;
    for i=1:(box_num-1)
        for j=(i+1):box_num
            xi1 = max(ft_boxes(i,1), gt(1));
            yi1 = max(ft_boxes(i,2), gt(2));
            xi2 = min(ft_boxes(i,3), gt(3));
            yi2 = min(ft_boxes(i,4), gt(4));
            xj1 = max(ft_boxes(j,1), gt(1));
            yj1 = max(ft_boxes(j,2), gt(2));
            xj2 = min(ft_boxes(j,3), gt(3));
            yj2 = min(ft_boxes(j,4), gt(4));
            x1 = max(xi1, xj1);
            y1 = max(yi1, yj1);
            x2 = min(xi2, xj2);
            y2 = min(yi2, yj2);
            iarea=(xi2-xi1+1)*(yi2-yi1+1);
            jarea=(xj2-xj1+1)*(yj2-yj1+1);
            w=x2-x1+1;
            h=y2-y1+1;
            if (w<=0||h<=0)
                inter=0;
            else
                inter=w*h;
            end
            s=iarea+jarea-2*inter;
            if s<1
                continue;
            end
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~��ʼ��mapֵ
            x01 = max(ft_boxes(i,1), ft_boxes(j,1));
            y01 = max(ft_boxes(i,2), ft_boxes(j,2));
            x02 = min(ft_boxes(i,3), ft_boxes(j,3));
            y02 = min(ft_boxes(i,4), ft_boxes(j,4));
            temp=[ft_boxes(i,:);ft_boxes(j,:);x01 y01 x02 y02];
            for k=1:3
                temp(k,:)=bsxfun(@times, temp(k,:), [scale_map(1), scale_map(2), scale_map(1), scale_map(2)]);
            end
            temp=int8(temp);      %�任��ϵ������
            count1=0;
            count2 = 0 ;
            average1=0;
            average2 = 0 ;
            average = 0;
%             thresh1=0;
%             thresh2=0;
            for m=(temp(1,2)+1):temp(1,4)
                for n=(temp(1,1)+1):temp(1,3)
                    average1=average1+saliency(m,n);
 %                   thresh1=thresh1+thresh(m,n);
                    count1=count1+1;
                end
            end
%             thresh1=thresh1/ count1 ;
%             if thresh1>0
%                 fprintf('thresh is positive :%d\n',thresh1);
%             end
            map1=average1/count1;
%             if  map< 83
%                 break;
%             end ;
            for m=(temp(2,2)+1):temp(2,4)
                for n=(temp(2,1)+1):temp(2,3)
                    average2=average2+saliency(m,n);
 %                   thresh2=thresh2+thresh(m,n);
                    count2=count2+1;
                end
            end
%             thresh2=thresh2 / count2 ;
             map2 = average2 / count2 ;
%             if map<83
%                 continue ;
%             end
            for m=(temp(3,2)+1):temp(3,4)
                for n=(temp(3,1)+1):temp(3,3)
                    average= average -saliency(m,n);
                    count2=count2-1;
                end
            end
            
            map=(average + average1 + average2) /(count1 + count2);
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�����ܷ����Լ������
            if map<1
                continue;
            end
            score=beta*log(s)+log(map);
       %     score=iarea*map1+jarea*map2;
            scores(cont,:) = [i j score s map] ;
            cont = cont + 1 ;
        end
    end
%     scores
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�ҵ�������߶�Ӧ������boxes�����
    [~,location]=max(scores(:,3));
%     scores
    if cont == 1
        check=0;
        ft_boxes=[];
        for i=1:size(boxes,1)
%             if overlap(i)>0.5
                temp_area=cal_area(boxes(i,:));
                if temp_area/gt_area>0.3 
                    ft_boxes=cat(1,ft_boxes,[boxes(i,:),overlap(i)]);
                    check=check+1;
                end
%             end
        end
        if check>=2
            [~,ps_up]=max(ft_boxes(:,5));
            ft_boxes(ps_up,5)=0;
            [~,ps_up2]=max(ft_boxes(:,5));
            parts(1,:) = ft_boxes(ps_up,1:4);
            parts(2,:) = ft_boxes(ps_up2,1:4) ;
        %parts=cat(1,parts,boxes(ps_up,:));
        %parts=cat(1,parts,boxes(ps_up2,:));
            return;
        end
    end
    %fprintf('ft_boxes : %d %d\n' , scores(location,1) , scores(location,2));
    parts(1,:) = ft_boxes(max(1, scores(location,1)),:);
    parts(2,:) = ft_boxes(max(2, scores(location,2)),:);
%     if cont == 2
%         [~,ps_up2]=max(overlap);
%         parts(2,:) = boxes(ps_up2,:) ;
%     end
end
