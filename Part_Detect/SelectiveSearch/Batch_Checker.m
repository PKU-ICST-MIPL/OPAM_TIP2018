function Batch_Checker(batchfilename, check)

fid = fopen(batchfilename,'rb');
datasize = fread(fid, 2, 'int')
fseek(fid, 8, 'bof');
rawdata = fread(fid, datasize(1)*datasize(2), 'uint8');
rawdata = reshape(rawdata, datasize(2), datasize(1));
fclose(fid);

% for i = 1:36
%     base = datasize(2) - 36;
%     i+base
%     imgdata = rawdata(i+base,:);
%     size(imgdata);
%     imgsize = [256, 256, 3];
%     img = zeros(imgsize);
%     img = (reshape(imgdata, 3, 256*256)/256)';
%     img = reshape(img, 256, 256, 3);
%     for cha = 1:3
%         img(:,:,cha) = img(:,:,cha)';
%     end
%     subplot(6,6,i); imshow(img);
% end

    imgdata = rawdata(check,:);
    size(imgdata);
    imgsize = [256, 256, 3];
    img = zeros(imgsize);
    img = (reshape(imgdata, 3, 256*256)/256)';
    img = reshape(img, 256, 256, 3);
    for cha = 1:3
        img(:,:,cha) = img(:,:,cha)';
    end
    imshow(img);



end
