% Sample code to generate class activation map from 10 crops of activations
% Bolei Zhou, March 15, 2016
% for the online prediction, make sure you have complied matcaffe
function demo(threadnum1 ,threadid1)
threadnum = str2num(threadnum1);
threadid = str2num(threadid1);
% clear
addpath('/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/matlab/caffe');
addpath('/home/junchao/hexiangteng/CVPR2018/code-one-shot/caffe-master/matlab') ;

oridir = '../images/';
[imglist idx] = textread('../datalist/car.list' , '%s %d') ;
outdir = '/home/junchao/hexiangteng/TIP2018/CAM-master-car/heatmap' ;
if ~exist(outdir , 'dir')
    mkdir(outdir);
end

seg_outdir = '/home/junchao/hexiangteng/TIP2018/CAM-master-car/heatmap-seg' ;
if ~exist(seg_outdir , 'dir')
    mkdir(seg_outdir);
end
txt_outdir = '/home/junchao/hexiangteng/TIP2018/CAM-master-car/heatmap-txt' ;
if ~exist(txt_outdir , 'dir')
    mkdir(txt_outdir);
end

net_weights = ['./models/vgg16/car_vgg16CAM_iter_55000.caffemodel'];
net_model = ['./models/vgg16/deploy_vgg16CAM.prototxt'];
net = caffe.Net(net_model, net_weights, 'test');  
online = 1; % whether extract features online or load pre-extracted features
%tic 
len_imglist = length(imglist) ;
eachthread = floor(len_imglist / threadnum);
startid = eachthread * threadid + 1;
endid = eachthread * (threadid +1) ;
if endid > len_imglist 
    endid = len_imglist ;
end

for i = startid : endid
    if mod(i , 10) == 0
        fprintf('now dealing with %d img\n' , i);
        %toc
    end
     imgnamearr = regexp(imglist{i} , '\.' , 'split') ;
     imgpath = fullfile(oridir , imglist{i}) ;
    curHeatMapFile = sprintf('%s/%s.bmp' , outdir , imgnamearr{1});
    curImgFile = imgpath ;
   
    curBBoxFile = sprintf('%s/%s.txt' , txt_outdir , imgnamearr{1}) ;
   
    outImgFile = sprintf('%s/%s' , seg_outdir , imglist{i}) ;
    if exist(curBBoxFile , 'file')
       continue;
    end
    
    img = imread(imgpath);
    if length(size(img)) == 2 
        img1 = zeros(size(img,1) , size(img,2) ,3) ;
        img1(:,:,1) = img ;
        img1(:,:,2) = img ;
        img1(:,:,3) = img ;
        img = img1 ;
    end
    re_size = [size(img , 1) , size(img , 2)];
    img = imresize(img, [256 256]);
 
    if online == 1
        % load the CAM model and extract features  

        weights_LR = net.params('CAM_fc_car',1).get_data();% get the softmax layer of the network

        scores = net.forward({prepare_image(img)});% extract conv features online
        activation_lastconv = net.blobs('CAM_conv').get_data();
        scores = scores{1};
    end


    %% Class Activation Mapping

    topNum = 1; % generate heatmap for top X prediction results
    scoresMean = mean(scores,2);
    [value_category, IDX_category] = sort(scoresMean,'descend');
    [curCAMmapAll] = returnCAMmap(activation_lastconv, weights_LR(:,IDX_category(1:topNum)));

    

    for j=1:topNum
        curCAMmap_crops = squeeze(curCAMmapAll(:,:,j,:));
        curCAMmapLarge_crops = imresize(curCAMmap_crops,[256 256]);
        curCAMLarge = mergeTenCrop(curCAMmapLarge_crops);
        curHeatMap = imresize(im2double(curCAMLarge),[256 256]);
        curHeatMap = im2double(curHeatMap);

        %curHeatMap = map2jpg(curHeatMap,[]);
        curHeatMap = map2jpg(curHeatMap,[], 'jet');
        curHeatMap = imresize(curHeatMap , re_size);
        %curHeatMap = im2double(img)*0.2+curHeatMap*0.7;
        %curResult = [curResult ones(size(curHeatMap,1),8,3) curHeatMap];

        %curPrediction = [curPrediction ' --top'  num2str(j) ':' categories{IDX_category(j)}];

    end

    imwrite(curHeatMap , curHeatMapFile);

    %figure,imshow(curResult);title(curPrediction)
    
    generate_bbox(curHeatMapFile , curImgFile , curBBoxFile , outImgFile) ;
    

end

if online==1
    caffe.reset_all();
end
% end

