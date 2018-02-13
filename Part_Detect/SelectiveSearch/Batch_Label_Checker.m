function Batch_Label_Checker(filepath, which)
    %load synsets     
    load('D://v-tixi//meta_clsloc.mat');
    %read config
    configpath = 'D:\v-tixi\DNN_training\dog.config';
    configfid = fopen(configpath, 'r');
    tline = fgets(configfid);
    tline = fgets(configfid);
    tline = fgets(configfid);
    res = regexp(tline, ' ', 'split');
    map = [];
    for i = 1:1000
        labmap = res(i);
        labmap = str2num(labmap{1});
        if labmap ~= -1
            map(labmap+1) = i;
        end
    end
    fclose(configfid);
    
    fid = fopen(filepath,'rb');
    datasize = fread(fid, 2, 'int');
    fseek(fid, 8, 'bof');
    rawdata = fread(fid, datasize(1)*datasize(2), 'float');
    rawdata = reshape(rawdata, datasize(2), datasize(1));
    fclose(fid);

    [res, labels] = max(rawdata, [], 2);
    
    labelwnid = {}
    for i = 1:1000
        labelwnid{i} = synsets(map(labels(i))).words;
    end
    
    labelwnid{which}



end