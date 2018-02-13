function TestBestOverlap
    addpath('Dependencies');
    load('D:\\v-tixi\\SelectiveSearchCodeIJCV\\Dataset\\GroundTruthVOC2007test.mat');
    for i = 0:9
       path = sprintf('Dataset//boxes_%d.mat', i);
       load(path);
       stimg = i*500 + 1;
       endimg = (i+1)*500;
       endimg = min(endimg, length(testIms));
       for j = stimg:endimg
           res{j} = boxes{j};
       end
    end
    
    [boxAbo boxMabo boScores avgNumBoxes] = BoxAverageBestOverlap(gtBoxes, gtImIds, res);
    fprintf('Mean Average Best Overlap for the box-based locations: %.3f\n', boxMabo);
    
end