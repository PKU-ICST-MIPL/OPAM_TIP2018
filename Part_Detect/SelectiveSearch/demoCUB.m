function demoCUB(batchidx)

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

%Test the boxes
% imglist = {};
% filelistpath = '/home/tianjun/ExperimentCode/patch_test_code/Build_Patch_Data/CUB/CUB2011_DPD_Test.txt';
% fid = fopen(filelistpath, 'r');
% tline = fgets(fid);
% idx = 1;
% while ischar(tline)
%     imglist{idx} = tline;
%     idx = idx + 1;
%     tline = fgets(fid);
% end
% fclose(fid);
% save ./CUB2011/testing_img_list_DPD.mat imglist
% return

load('./CUB2011/testing_img_list_DPD.mat');
stimg = batchidx * 1000;
endimg = min( (batchidx + 1) * 1000, size(imglist, 2));

mbnum = floor((endimg - stimg) / 128) + 1;
nowimg = 1;

for mbidx = 0:mbnum-1
%for mbidx = 0:0
    totalTime = 0;
    mbstimg = stimg + 128 * mbidx + 1;
    mbendimg = stimg + 128 * (mbidx + 1);
    mbendimg = min(mbendimg, endimg);
    [mbstimg, mbendimg]
    for img = mbstimg:mbendimg
        fprintf('%d ', img);
        
        images = imglist{img};
        images = images(1:size(images, 2)-1);
        im = imread(images);     
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
        
        nowimg = nowimg + 1;
        
    end
    
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

%filename = sprintf('/home/tianjun/data/CUB2011/CUB_200_2011/boxes/boxes_batch_%d.mat', batchidx);
filename = sprintf('/home/tianjun/DPD/BVLC-DPD-0554308/fine-tune/boxes/test/boxes_batch_%d.mat', batchidx);
save(filename, 'boxes');


filename = sprintf('/home/tianjun/DPD/BVLC-DPD-0554308/fine-tune/boxes/test/boxes_batch_%d.txt', batchidx);
fid = fopen(filename,'w');
imgnum = size(boxes, 2);
fprintf(fid, '%d\n', imgnum);
for i = 1:imgnum
    i
    boxnum =  size(boxes{i}, 1);
    fprintf(fid, '%d\n', boxnum);
    for j = 1:boxnum
        fprintf(fid, '%d %d %d %d\n', boxes{i}(j, 1), boxes{i}(j, 2), boxes{i}(j, 3), boxes{i}(j, 4));
    end
end
fclose(fid); 


end