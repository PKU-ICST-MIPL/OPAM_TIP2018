function SSearch_on_image_list(batchidx)

img_list = '../../datalist/car.list';
imgroot = '../../images/';
res_path = './ss_result/';

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

[imglist, ~] = textread(img_list, '%s %d');
% we set four pipelines, each run 1000 images
stimg = batchidx * 1000 + 1;
endimg = min(stimg + 1000, length(imglist) + 1);
nowimg = 1;
[stimg, endimg]
totalTime = 0;

for img = stimg:endimg-1
    fprintf('%d ', img);
    image = imglist{img};
    image = sprintf('%s%s', imgroot, image);
    OK = 1;
    try
        im = imread(image); 
    catch
        disp('An Error Occur, will continue')
        OK = 0;
    end
    
    if OK
        imgpath{nowimg} = image;
        imgsize{nowimg} = size(im);
        maxsize = max(imgsize{nowimg});
        ratio{nowimg} = 1;
        if maxsize > 1000
           ratio{nowimg} = 1000.0 / maxsize;
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
		if size(im, 3) == 1
		im3 = zeros(size(im, 1),size(im,2), size(im,3));
		im3(:,:,1) = im;im3(:,:,2) = im;im3(:,:,3) = im;
		%disp(size(im3));
                [boxesT{idx} blobIndIm blobBoxes hierarchy priorityT{idx}] = Image2HierarchicalGrouping(im3, sigma, k, minSize, colorType, simFunctionHandles);
else
                [boxesT{idx} blobIndIm blobBoxes hierarchy priorityT{idx}] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
end
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


filename = sprintf('%s%d.txt', res_path, batchidx);
fid = fopen(filename,'w');
imgnum = size(boxes, 2);
for i = 1:imgnum
    fprintf(fid, '# %d\n', i + batchidx * 1000 - 1);
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
    
    boxnum =  size(boxes{i}, 1);
    
    boxes{i} = floor((boxes{i} - 1) / ratio{i}) + 1;
    
    fprintf(fid, '%d\n', boxnum);
    for j = 1:boxnum
        fprintf(fid, '0 1 %d %d %d %d\n', boxes{i}(j, 1), boxes{i}(j, 2), boxes{i}(j, 3), boxes{i}(j, 4));
    end
end
fclose(fid); 


end
