function [feature] = readvisionfeature(featurepath , featureDim , testNum, scale)
    if nargin<4
        scale = 1;
    end
    totaltest = testNum ;
    scale = 1.8;
    feature = load(featurepath);
    for i = 1 : featureDim
        feature(:,i) = sign(feature(:,i)) .* abs(feature(:,i)) .^ (1/scale);% the best
    end
    feature = exp(feature); 
    sumOfRowfeature = sum(feature,2);
    sumOfRowfeature = repmat(sumOfRowfeature , 1 , featureDim) ;
    feature = feature ./ sumOfRowfeature;
    feature = pre_cnn(feature);
    feature = feature(1:totaltest,:) ;
    [scores , classes] = max(feature ,[] , 2) ;
    classes = classes - 1 ;
    [list, gt] = textread('./datalist/car_test.list' , '%s %d');
    gt_bbox = gt;
    presion_fusion = length(find((classes - gt_bbox) == 0)) / testNum ;
    fprintf('%f\n' , presion_fusion);
end
