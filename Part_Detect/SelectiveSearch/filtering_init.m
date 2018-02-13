function [check,ft_boxes]=filtering_init(boxes,gt)
    ft_boxes=[];
    overlap=boxoverlap(boxes,gt);
    overlap=overlap';
    check=0;
    gt_area=cal_area(gt);
    for i=1:size(boxes,1)
        if overlap(i)>0.7
            temp_area=cal_area(boxes(i,:));
            if overlap(i)*temp_area/gt_area>0.4 
                ft_boxes=cat(1,ft_boxes,boxes(i,:));
                check=check+1;
            end
        end
    end
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
    if check>300
        del_num=check-300;
        for i=1:del_num
            del_box_num=rand()*(check-i+1);
            del_box_num=ceil(del_box_num);
            ft_boxes(del_box_num,:)=[];
        end
        check=300;
    end
end
