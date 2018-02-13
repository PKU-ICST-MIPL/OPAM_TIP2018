function detect_part()
	filterspath = 'parts'
	clusternum_str='2'
	outdir=['./' filterspath '/']
    if(~exist(outdir))
      mkdir(outdir);
    end
    clusternum = str2num(clusternum_str);
    filters = load('param');
    
    confmat = zeros(size(filters, 1));
    num = size(confmat, 1);
    
    for i = 1:num
       for j = 1:num
          A = filters(i,:); 
          B = filters(j,:);
          %confmat(i, j) = abs(A - B);
          confmat(i, j) = (A*B') / (sqrt(sum(A.^2, 2)) * sqrt(sum(B.^2, 2)));
           
       end
    end
    time_st = tic;
    filter_ind = specture_cluster(confmat, clusternum);
    fprintf('specture_cluster for [%s] [clusternum=%d] end. the time is [%f]s\n',filterspath, clusternum, toc(time_st));
    %save filter_ind_conv4.mat filter_ind
    
    %load filter_ind_conv4.mat
    for ci = 1:clusternum
      fname = [outdir '/' 'part_' num2str(ci) '.txt'];
      fid = fopen(fname, 'w');
      fprintf('write to [%s] ...\n',fname);
      part = find(filter_ind == ci);
      for i = 1 : size(part, 1)
        fprintf(fid, '%d\n', part(i)-1);
      end
      fclose(fid);
    end    

end
