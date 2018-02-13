

function val = pre_cnn(inputMat)
    val = inputMat;
    
    mean_val = mean(val,1);
    mean_val = repmat(mean_val,[size(val,1),1]);
    val = val - mean_val;
    
    std_val = std(val);
    std_val(find(std_val==0))=1;
    std_val = repmat(std_val,[size(val,1),1]);
    val = val./std_val;
end
