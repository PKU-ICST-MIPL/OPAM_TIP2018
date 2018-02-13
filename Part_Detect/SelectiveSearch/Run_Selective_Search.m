function Run_Selective_Search(threadNum , threadId)
%Example: Run_Selective_Search(10, 0, './val_animal_all_clu1.mat',...
%'/home/tianjun/data/imagenet/val/', '/home/tianjun/expcode/CVPR2015/BoxLists/animal_all_clu1_boxes_batch_')

%     %Test the boxes
%     imglist = {};
%     filelistpath = '/home/tianjun/expcode/CVPR2015/CUB/CUB_Test.txt';
%     fid = fopen(filelistpath, 'r');
%     tline = fgets(fid);
%     idx = 1;
%     while ischar(tline)
%         res = regexp(tline, ' ', 'split');
%         imglist{idx} = res(1);
%         idx = idx + 1;
%         tline = fgets(fid);
%     end
%     fclose(fid);
%     save ./CUB_Test.mat imglist
%     return
    
    
    addpath('Dependencies');

% Compile anisotropic gaussian filter
if(~exist('anigauss'))
    fprintf('Compiling the anisotropic gauss filtering of:\n');
    fprintf('   J. Geusebroek, A. Smeulders, and J. van de Weijer\n');
    fprintf('   Fast anisotropic gauss filtering\n');
    fprintf('   IEEE Transactions on Image Processing, 2003\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://staff.science.uva.nl/~mark/downloads.html#anigauss\n\n');
    mex Dependencies/anigaussm/anigauss_mex.c Dependencies/anigaussm/anigauss.c -output anigauss
end

if(~exist('mexCountWordsIndex'))
    mex Dependencies/mexCountWordsIndex.cpp
end

% Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
if(~exist('mexFelzenSegmentIndex'))
    fprintf('Compiling the segmentation algorithm of:\n');
    fprintf('   P. Felzenszwalb and D. Huttenlocher\n');
    fprintf('   Efficient Graph-Based Image Segmentation\n');
    fprintf('   International Journal of Computer Vision, 2004\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://www.cs.brown.edu/~pff/segment/\n');
    fprintf('Note: A small Matlab wrapper was made. See demo.m for usage\n\n');
%     fprintf('   
    mex Dependencies/FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
end

%%
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
simFunctionHandles = simFunctionHandles(1:4); % Two different merging strategies

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
ks = [50 100 150 300]; % controls size of segments of initial segmentation. 
sigma = 0.8;

% After segmentation, filter out boxes which have a width/height smaller
% than minBoxWidth (default = 20 pixels).
minBoxWidth = 20;

% Comment the following three lines for the 'quality' version
% colorTypes = colorTypes(1:2); % 'Fast' uses HSV and Lab
% simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies
% ks = ks(1:2);
imgroot = '/home/junchao/AAAI2016/dataset_car' ;
res_path = '/home/junchao/AAAI2016/dataset_car/car_test_ss/';
% imgroot = 'F:\Study\paper\1.mine\AAAI-mine\Dataset\CUB_200_2011\CUB_200_2011\images\' ;
% res_path = 'F:\Study\paper\1.mine\AAAI-mine\Code-AAAI\ss_result\';
[imglist classid] = textread('/home/junchao/AAAI2016/code-AAAI/filelist_car/car/car_test_list.txt' , '%s %d') ;


% we set four pipelines, each run 250 images
eachThreadnum = floor(length(imglist) / threadNum) ;

stimg = eachThreadnum * threadId + 1 ;
endimg = eachThreadnum * (threadId + 1) ;
if threadId == threadNum -1 
    endimg = length(imglist) ;
end

nowimg = 1 ;
totalTime = 0 ;
for img = stimg:endimg
    fprintf('%d ', img);
    imagename = imglist{img};
    %imagedir = imgdir{img};
    image = sprintf('%s/%s', imgroot,imagename);
    OK = 1;
    try
        im = imread(image); 
    catch
        disp('An Error Occur, will continue')
        OK = 0;
    end
    
    if OK
        imgpath{nowimg} = image;
%         imgclass(nowimg) = class(img) ;
        imgsize{nowimg} = size(im);
        maxsize = max(imgsize{nowimg});
        ratio{nowimg} = 1;
        if maxsize > 1000
           ratio{nowimg} = 1000.0 / maxsize
           im = imresize(im, ratio{nowimg});
        end
        
        idx = 1;
        for j=1:length(ks)
            k = ks(j); % Segmentation threshold k
            minSize = k; % We set minSize = k

            %for n = 1:length(colorTypes)
            for n = 1:1
                colorType = colorTypes{n};
                tic;
                [boxesT{idx} blobIndIm blobBoxes hierarchy priorityT{idx}] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
                totalTime = totalTime + toc;
                idx = idx + 1;
            end
        end
        boxes{nowimg} = cat(1, boxesT{:}); % Concatenate boxes from all hierarchies
        priority = cat(1, priorityT{:}); % Concatenate priorities

        % Do pseudo random sorting as in paper
        priority = priority .* rand(size(priority));
        [priority sortIds] = sort(priority, 'ascend');
        boxes{nowimg} = boxes{nowimg}(sortIds,:);
    else
        imgpath{nowimg} = image;
%         imgclass(nowimg) = class(img) ;
        imgsize{nowimg} = [0 0 0];
        boxes{nowimg} = {};
    end
    nowimg = nowimg + 1;
end

size(boxes)

%%
tic
for i = 1:nowimg-1
    boxes{i} = FilterBoxesWidth(boxes{i}, minBoxWidth);
    boxes{i} = BoxRemoveDuplicates(boxes{i});
end
totalTime = totalTime + toc;

fprintf('Time per image: %.2f\n', totalTime ./nowimg);

% filename = sprintf('/home/tianjun/data/ImageNet1K/birdvalimg/boxes/boxes_batch_%d.mat', batchidx);
% save('../BoxLists/tryboxes.mat', 'boxes');
% save('../BoxLists/tryimg.mat', 'imgpath');
% save('../BoxLists/trysize.mat', 'imgsize');

filename = sprintf('%s%d.txt', res_path, threadId);
fid = fopen(filename,'w');
imgnum = size(boxes, 2);
%fprintf(fid, '%d\n', imgnum);
for i = 1:imgnum
    %name
    fprintf(fid, '# %d\n', i + threadId * eachThreadnum );
    fprintf(fid, '%s\n', imgpath{i});
    
    width = imgsize{i}(1);
    height = imgsize{i}(2);
    if size(imgsize{i}, 2) == 3
        fprintf(fid, '%d\n', imgsize{i}(3));
        fprintf(fid, '%d\n', imgsize{i}(1));
        fprintf(fid, '%d\n', imgsize{i}(2));
    else
        fprintf(fid, '%d\n', 1);
        fprintf(fid, '%d\n', imgsize{i}(1));
        fprintf(fid, '%d\n', imgsize{i}(2));      
    end
%     fprintf(fid , '%d\n' , imgclass(i)) ;
    boxnum =  size(boxes{i}, 1);
    
    %some images are resized
    boxes{i} = floor((boxes{i} - 1) / ratio{i}) + 1;
    
%    fprintf(fid, '%d\n', boxnum);
%     for j = 1:boxnum
%         fprintf(fid, '0 1 %d %d %d %d\n', boxes{i}(j, 1), boxes{i}(j, 2), boxes{i}(j, 3), boxes{i}(j, 4));
%     end
    
    
%     %We only select from top-400
    if boxnum > 2000
        fprintf(fid, '%d\n', 2000);
        for j = 1:2000
            fprintf(fid, '0 1 %d %d %d %d\n', boxes{i}(j, 1), boxes{i}(j, 2), boxes{i}(j, 3), boxes{i}(j, 4));
        end   
    else
        fprintf(fid, '%d\n', 2000);
        for j = 1:boxnum
            fprintf(fid, '0 1 %d %d %d %d\n', boxes{i}(j, 1), boxes{i}(j, 2), boxes{i}(j, 3), boxes{i}(j, 4));
        end
        for j = boxnum+1:2000
            fprintf(fid, '0 1 %d %d %d %d\n', 1, 1, width, height);
        end    
    end
    
    

end
fclose(fid); 

end


