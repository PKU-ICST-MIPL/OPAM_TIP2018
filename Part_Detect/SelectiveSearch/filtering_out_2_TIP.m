function filtering_out_2_TIP(threadId)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~config
count=0;
information_num=6;
boxes_num=1000;
im_size=zeros(1,2);
boxes=zeros(boxes_num,4);
beta=1;
outdir = './parts/';
image_path='../../images/';
if ~exist(outdir , 'dir')
    mkdir(outdir) ;
end
heatdir = '../../CAM-master-car/heatmap/' ;
bboxdir = '../../CAM-master-car/heatmap-seg/' ; 
bbox_txt_dir = '../../CAM-master-car/heatmap-txt/' ; 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


pth = sprintf('./ss_result/%d.txt' , threadId) ;
f=fopen(pth , 'r');
while ~feof(f)
    for j=1:information_num
        tline=fgetl(f);

        if j==2
            img_dir=tline;
            s = regexp(tline, '/', 'split');
            filename=s{end};
            [~,name,~]=fileparts(char(tline));
            sal_dir=sprintf('%s/%s.bmp' ,heatdir,name);
            sal=imread(sal_dir);
            sal = rgb2gray(sal);
            saliency=sal(:,:,1);
            
        end
        if j==4
            im_size(1,2)=str2double(tline);
        end
        if j==5
            im_size(1,1)=str2double(tline);
        end
        if j == 6
	boxes_num=str2double(tline);
	boxes=zeros(min(boxes_num, 1000),4);
        end
    end
txtpath = sprintf('%s/%s.txt' ,bbox_txt_dir, name) ;
[x1 y1 w h] = textread(txtpath , '%d %d %d %d') ;
 gt = [x1 y1 x1+w y1+h] ;
    for j=1:boxes_num 
        tline=fgetl(f);
	if j > 1000
		continue;
	end
        s = regexp(tline, ' ', 'split');
        boxes(j,1)=str2double(char(s(4)));
        boxes(j,2)=str2double(char(s(3)));
        boxes(j,3)=str2double(char(s(6)));
        boxes(j,4)=str2double(char(s(5)));
    end
    fprintf('%d\n' , i) ;
    [truth,parts]=filtering_2_TIP(boxes,gt,im_size,saliency,beta);
    count=count+truth;
%     %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~��ѡ����part,ԭͼ��ԭbounding box����
     
    img=imread([image_path,'/',filename]);
    
    %part1
    height=parts(1,4)-parts(1,2) ;
    width=parts(1,3)-parts(1,1) ;
    img_part1 = imcrop(img , [parts(1,1) parts(1,2) width height]) ;
    part_dir=[outdir,name,'_1','.jpg'];
    imwrite(img_part1,part_dir);
    %part2
    height=parts(2,4)-parts(2,2);
    width=parts(2,3)-parts(2,1);
    img_part2 = imcrop(img , [parts(2,1) parts(2,2) width height]) ;
    part_dir=[outdir,name,'_2','.jpg'];
    imwrite(img_part2,part_dir);
    %ԭͼ
    img_dir=[outdir,name,'.jpg'];
    imwrite(img,img_dir);
  %  bbox
    bbox=imread([bboxdir,'/',filename]);
    bbox_dir=[outdir , name,'_bbox','.jpg'];
    imwrite(bbox,bbox_dir);
end
fprintf('%d\n',count);
fclose(f);
%end

