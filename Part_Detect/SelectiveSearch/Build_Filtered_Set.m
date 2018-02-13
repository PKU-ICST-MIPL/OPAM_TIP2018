function Build_Filtered_Set(batchidx)
    %oriset
    for mbidx = 0:7
        datafile = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\dog_data_mb\\data_batch_%d_%d', batchidx,  mbidx)
        fid = fopen(datafile,'rb');
        datasize = fread(fid, 2, 'int');
        fseek(fid, 8, 'bof');
        rawdata = fread(fid, datasize(1)*datasize(2), 'uint8');
        rawdata = reshape(rawdata, datasize(2), datasize(1));
        fclose(fid);
        
        for img = 1:datasize(2)
            imgidx = img + mbidx * 128;
                resfile = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\filterres\\oripatch\\img_%d_%d_ori.jpg', batchidx, imgidx)
                imgdata = rawdata(img,:);
                imgsize = [256, 256, 3];
                img = zeros(imgsize);
                img = (reshape(imgdata, 3, 256*256)/256)';
                img = reshape(img, 256, 256, 3);
                for cha = 1:3
                    img(:,:,cha) = img(:,:,cha)';
                end
                imwrite(img,resfile, 'jpg');

        end
    end
        
        
        
%     for mbidx = 0:7
%         for pidx = 1:50
%             datafile = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\batchnew\\data_batch_%d_%d_%d', batchidx, pidx, mbidx)
%             %filterresfile = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\filterres\\dogfilter\\filter_%d_%d_%d', batchidx, pidx, mbidx)
%             filterresfile = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\filterres\\dogfilter\\filter_%d_%d_%d', batchidx, mbidx, pidx)
%             
%             fid = fopen(datafile,'rb');
%             datasize = fread(fid, 2, 'int');
%             fseek(fid, 8, 'bof');
%             rawdata = fread(fid, datasize(1)*datasize(2), 'uint8');
%             rawdata = reshape(rawdata, datasize(2), datasize(1));
%             fclose(fid);
%             
%             fid = fopen(filterresfile,'rb');
%             ressize = fread(fid, 2, 'int');
%             fseek(fid, 8, 'bof');
%             filterres = fread(fid, ressize(1)*ressize(2), 'float');
%             fclose(fid);
%             
%             for img = 1:datasize(2)
%                 imgidx = img + mbidx * 128;
%                 if filterres(img) == 1
%                     resfile = sprintf('D:\\v-tixi\\SelectiveSearchCodeIJCV\\ImageNetRes\\filterres\\filteredpatch\\img_%d_%d_%d.jpg', batchidx, imgidx, pidx)
%                     imgdata = rawdata(img,:);
%                     imgsize = [256, 256, 3];
%                     img = zeros(imgsize);
%                     img = (reshape(imgdata, 3, 256*256)/256)';
%                     img = reshape(img, 256, 256, 3);
%                     for cha = 1:3
%                         img(:,:,cha) = img(:,:,cha)';
%                     end
%                     imwrite(img,resfile, 'jpg');
%                 end
%             
%             end
%         end
%     end

end