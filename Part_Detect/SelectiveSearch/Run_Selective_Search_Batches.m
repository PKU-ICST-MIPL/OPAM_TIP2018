function Run_Selective_Search_Batches(st_batch, end_batch, img_list, prefix, res_path)
%Example: Run_Selective_Search(10, 0, './val_animal_all_clu1.mat',...

    load(img_list);
    imgnum = size(imglist, 2);
    batch_size = 1000;
    batch_num = ceil(imgnum / batch_size)
    
    info = sprintf('Start From %d to %d\n', st_batch, end_batch)
    for i = st_batch: end_batch - 1
       if i < batch_num
            SSearch_on_image_list(i, img_list, prefix, res_path);
       end
    end


end