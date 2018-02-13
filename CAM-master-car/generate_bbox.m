%% Here is the code to generate the bounding box from the heatmap
%
% to reproduce the ILSVRC localization result, you need to first generate
% the heatmap for each testing image by merging the heatmap from the
% 10-crops (it is exactly what the demo code is doing), then resize the merged heatmap back to the original size of
% that image. Then use this bbox generator to generate the bbox from the resized heatmap.
%
% The source code of the bbox generator is also released. Probably you need
% to install the correct version of OpenCV to compile it.
%
% Special thanks to Hui Li for helping on this code.
%
% Bolei Zhou, April 19, 2016\
function generate_bbox(curHeatMapFile , curImgFile , curBBoxFile , outImgFile)


% curHeatMapFile = '/home/junchao/AAAI2016/CAM-master/heatmap/001.Black_footed_Albatross/Black_Footed_Albatross_0009_34.bmp' ;
% curImgFile = '/home/junchao/AAAI2016/datasets/cub/images/001.Black_footed_Albatross/Black_Footed_Albatross_0009_34.jpg' ;
% imglistarr = regexp(imglist{i} , '/' , 'split') ;
% outImgFile = '/home/junchao/AAAI2016/CAM-master/heatmap-seg/text.jpg' ;
% curBBoxFile = '/home/junchao/AAAI2016/CAM-master/heatmap-txt/001.Black_footed_Albatross/Black_Footed_Albatross_0009_34.txt' ;

bbox_threshold = [20, 100, 110]; % parameters for the bbox generator
curParaThreshold = [num2str(bbox_threshold(1)) ' ' num2str(bbox_threshold(2)) ' ' num2str(bbox_threshold(3))];


system(['/home/junchao/hexiangteng/TIP2018/CAM-master-car/bboxgenerator/./dt_box ' curHeatMapFile ' ' curParaThreshold ' ' curBBoxFile]);

boxData = dlmread(curBBoxFile);
boxData_formulate = [boxData(1:4:end)' boxData(2:4:end)' boxData(1:4:end)'+boxData(3:4:end)' boxData(2:4:end)'+boxData(4:4:end)'];
boxData_formulate = [min(boxData_formulate(:,1),boxData_formulate(:,3)),min(boxData_formulate(:,2),boxData_formulate(:,4)),max(boxData_formulate(:,1),boxData_formulate(:,3)),max(boxData_formulate(:,2),boxData_formulate(:,4))];

curHeatMap = imread(curHeatMapFile);
%curHeatMap = imresize(curHeatMap,[height_original weight_original]);

% subplot(1,2,1),hold off, imshow(curImgFile);
% hold on
maxarea = 0 ;
maxrect = [0 0 0 0] ;
for i=1:size(boxData_formulate,1)
    curBox = boxData_formulate(i,:);
    curarea = (curBox(3)-curBox(1)) * (curBox(4)-curBox(2)) ;
    if curarea > maxarea
        maxrect = [curBox(1) curBox(2) curBox(3)-curBox(1) curBox(4)-curBox(2)] ;
        maxarea = curarea ;
    end
    %rectangle('Position',[curBox(1) curBox(2) curBox(3)-curBox(1) curBox(4)-curBox(2)],'EdgeColor',[1 0 0]);
end
% rectangle('Position',maxrect,'EdgeColor',[1 0 0]);
% subplot(1,2,2),imagesc(curHeatMap);
img = imread(curImgFile) ;
img_new = imcrop(img , maxrect) ;
imwrite(img_new , outImgFile);

fid = fopen(curBBoxFile , 'w') ;
fprintf(fid , '%d %d %d %d\n' , maxrect(1) , maxrect(2) , maxrect(3) , maxrect(4)) ; 
fclose(fid) ;

end
 
