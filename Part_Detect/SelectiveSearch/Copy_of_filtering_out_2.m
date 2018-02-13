threadNum=10
threadId=8
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~config
information_num=6;
boxes_num=2000;
im_size=zeros(1,2);
boxes=zeros(boxes_num,4);
beta=1;
outdir = '/home/junchao/AAAI2016/datasets/ss_selection_2_4_tmp/' ;
bboxdir = '/home/junchao/AAAI2016/datasets/cub-Vgg16-with-itsboundingbox/images/' ; 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[imglist imgdir x1 y1 x2 y2] = textread('saliency_boundingbox.txt' , '%s %s %f %f %f %f') ;
eachThreadnum = floor(length(imglist) / threadNum) ;

stimg = eachThreadnum * threadId + 1 ;
endimg = eachThreadnum * (threadId + 1) ;
if threadId == threadNum -1 
    endimg = length(imglist) ;
end

pth = sprintf('/home/junchao/AAAI2016/datasets/ss_result/%d.txt' , threadId) ;
f=fopen(pth , 'r');
%f1=fopen('/home/hexiangteng/software/CNN-Saliency-Map-master/position0.txt');
tt = 0;
for i=stimg:endimg
    tic;
%for i = 1 : 30
%       for j = 1 : 993 * 2006
%           tline = fgetl(f);
%       end
%     line=fgetl(f1);
%     s = regexp(line, ' ', 'split');
%     for j=3:6
%         gt(1,j-2)=str2double(char(s(j)));
%     end
gt = [x1(i) y1(i) x2(i) y2(i)] ;
    for j=1:information_num
        tline=fgetl(f);
        if j==2
            img_dir=tline;
            s = regexp(tline, '/', 'split');
            folder=s{end-1};
            filename=s{end};
            sal_dir=fullfile('/home/junchao/AAAI2016/datasets/saliency_CUB_200_2011',folder,filename); 
            thresh_dir=fullfile('/home/junchao/AAAI2016/datasets/thresh_CUB_200_2011',folder,filename);
            sal=imread(sal_dir);
            thresh=imread(thresh_dir);
            saliency=sal(:,:,1);
            [~,name,~]=fileparts(char(tline));
        end
        if j==4
            im_size(1,2)=str2double(tline);
        end
        if j==5
            im_size(1,1)=str2double(tline);
        end
    end
    for j=1:boxes_num
        tline=fgetl(f);
        s = regexp(tline, ' ', 'split');
        boxes(j,1)=str2double(char(s(4)));
        boxes(j,2)=str2double(char(s(3)));
        boxes(j,3)=str2double(char(s(6)));
        boxes(j,4)=str2double(char(s(5)));
%         for k=3:6
%             boxes(j,k-2)=str2double(char(s(k)));
%         end
    end
    fprintf('%d\n' , i) ;
    [truth,parts]=filtering_2(boxes,gt,im_size,saliency,beta);
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~��ѡ����part,ԭͼ��ԭbounding box����
    img=imread(img_dir);
    for j=1:2
    %part1 2 3 4
        height=parts(j,4)-parts(j,2);
        width=parts(j,3)-parts(j,1);
%         for m=1:height
%             for n=1:width
%                 temp(m,n)=img(parts(j,2)+m,parts(j,1)+n);
%             end
%         end
        temp = imcrop(img , [parts(j,1) parts(j,2) width height]) ;
        part_dir=[outdir,name,'_',num2str(j),'.jpg'];
        imwrite(temp,part_dir);
    end
    %ԭͼ
    img_dir=[outdir,name,'.jpg'];
    imwrite(img,img_dir);
    %bbox
    bbox=imread([bboxdir,folder,'/',filename]);
    bbox_dir=[outdir , name,'_bbox','.jpg'];
    tt = tt + toc;
    imwrite(bbox,bbox_dir);
    disp(num2str(tt/(i-stimg+1)));
end
fclose(f);

