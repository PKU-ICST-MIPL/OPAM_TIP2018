clear all;
 
testNum = 8041;
featureDim = 195;
[~, gt] = textread('./datalist/car_test.list' , '%s %d') ;

featurepath = './feature/patch/feature.txt';
score_vision_ori = readvisionfeature(featurepath ,featureDim , testNum, 2);

featurepath = './feature/bbox/feature.txt';
score_vision_bbox = readvisionfeature(featurepath ,featureDim , testNum,2);

featurepath = './feature/part1/feature.txt';
score_vision_part = readvisionfeature(featurepath ,featureDim , testNum,2);

featurepath = './feature/part2/feature.txt';
score_vision_part2 = readvisionfeature(featurepath ,featureDim , testNum,2);

feature_fusion = 0.5 * score_vision_ori  + 0.3 * score_vision_bbox + 0.2 * (score_vision_part + score_vision_part2) / 2;
[scores_fusion , classes_fusion] = max(feature_fusion , [] , 2) ;
classes_fusion = classes_fusion - 1 ;
precision_fusion = length(find((classes_fusion - gt) == 0)) / testNum

