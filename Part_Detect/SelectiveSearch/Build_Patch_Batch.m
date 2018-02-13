function Build_Patch_Batch(batchidx)

boxfilename = sprintf('ImageNetRes\\boxes_batch_%d.mat', batchidx)
load(boxfilename);
size(boxes)

for i = 0:7
    imgfile = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\dog_data_mb\\data_batch_%d_%d', batchidx, i)
    %read data file
    fid = fopen(imgfile,'rb');
    datasize = fread(fid, 2, 'int')
    fseek(fid, 8, 'bof');
    rawdata = fread(fid, datasize(1)*datasize(2), 'uint8');
    rawdata = reshape(rawdata, datasize(2), datasize(1));
    fclose(fid);
    
    for imgidx = 1 : datasize(2)
        img = (reshape(rawdata(imgidx,:), 3, 256*256)/256)';
        img = reshape(img, 256, 256, 3);
        for cha = 1:3
            img(:,:,cha) = img(:,:,cha)';
        end
        im(:,:,:,imgidx) = img;
    end
    
    for pidx = 1:50
        res = [];
        batchfilename = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\batchnew\\data_batch_%d_%d_%d', batchidx, pidx, i)
        %datasize
        for imgidx = 1 : datasize(2)
            boxidx = i * 128 + imgidx;
            
            if pidx <= size(boxes{boxidx}, 1)          
                %[pidx, imgidx, boxes{boxidx}(pidx,1), boxes{boxidx}(pidx,3), boxes{boxidx}(pidx,2), boxes{boxidx}(pidx,4)]
                patch = im(boxes{boxidx}(pidx,1):boxes{boxidx}(pidx,3), boxes{boxidx}(pidx,2):boxes{boxidx}(pidx,4), :, imgidx);
                patch = imresize(patch, [256, 256]);
                %reshape the result and pin to batchfile
                for cha = 1:3
                    patch(:,:,cha) = patch(:,:,cha)';
                end
                patch = reshape(patch, 256*256, 3)';
                patch = reshape(patch, 3*256*256,1)*256;
                res(:,imgidx) = patch;
            else
                patch = im(pidx:256-pidx, pidx:256-pidx, :, imgidx);
                patch = imresize(patch, [256, 256]);
                %reshape the result and pin to batchfile
                for cha = 1:3
                    patch(:,:,cha) = patch(:,:,cha)';
                end
                patch = reshape(patch, 256*256, 3)';
                patch = reshape(patch, 3*256*256,1)*256;
                res(:,imgidx) = patch;
            end
            
        end
        
        res = res';
        res = reshape(res,  datasize(1) * datasize(2), 1);
        res = uint8(res);

        fid = fopen(batchfilename,'wb');
        fwrite(fid, datasize, 'int');
        fwrite(fid, res, 'uint8');
        fclose(fid);   
    end


end