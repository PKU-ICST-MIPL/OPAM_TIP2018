load('D:\v-tixi\SelectiveSearchCodeIJCV\ImageNetRes\boxes_batch_0.mat');

filename = 'D:\v-tixi\SelectiveSearchCodeIJCV\ImageNetRes\boxes_batch_0.txt';
fid = fopen(filename,'w');
imgnum = size(boxes, 2);
fprintf(fid, '%d\n', imgnum);
for i = 1:imgnum
    i
    boxnum =  size(boxes{i}, 1);
    fprintf(fid, '%d\n', boxnum);
    for j = 1:boxnum
        fprintf(fid, '%d %d %d %d\n', boxes{i}(j, 1), boxes{i}(j, 2), boxes{i}(j, 3), boxes{i}(j, 4));
    end
end

fclose(fid); 