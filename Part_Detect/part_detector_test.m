clear
mainno = 2
imgRootDir = ''
listfilepath = './datalist/car_test_part.list';
actfilename = 'test_part_conv5_3/feature.txt';
partdir_prefix = ['Test_part_main' num2str(mainno)];
partdir_prefix
outdir = './parts/';
actfilepath = ['features/' actfilename]
[pathlist,label] = textread(listfilepath,'%s %d');
channel = 512;
boxnum = 2;
partnum = 2;
totalnum = length(pathlist)/boxnum
partmask = zeros(partnum,channel);

actMat_ori = load(actfilepath);
actMat_ori = actMat_ori(1:length(pathlist),:);
actMat = mean(reshape(actMat_ori, length(pathlist), channel, 196), 3);
assert(size(actMat,2)==channel);
actMat = actMat(1:totalnum*boxnum,:);
actsum = zeros(totalnum*boxnum, partnum);
boxid = zeros(totalnum, partnum);
for i=1:partnum
  partmaskpath = sprintf('%s/part_%d.txt',outdir, i);
  maskid = load(partmaskpath);
  partmask(i, maskid+1) = 1;
  partoutdir{i} = [outdir '/' partdir_prefix '_' num2str(i)];
  if(~exist(partoutdir{i}))
    mkdir(partoutdir{i})
  end
  actsum(:,i) = actMat*partmask(i,:)';
  actsum_tmp = reshape(actsum(:,i),boxnum,totalnum);
  [~, ind] = max(actsum_tmp);
  boxid(:,i) = ind';
end
box_repCnt = sum(boxid(:,1)==boxid(:,2))

% partid = zeros(totalnum, boxnum);
% for i=1:boxnum
%   actsum_tmp = actsum(i:boxnum:totalnum*boxnum,:);
%   [~, ind] = max(actsum_tmp,[],2);
%   partid(:,i) = ind;
% end
% part_repCnt = sum(partid(:,1)==partid(:,2))
% repCnt = 0;
% for i=1:totalnum
%   if(partid(i,1)~=partid(i,2))
%     continue;
%   end
%   if(boxid(i,1)==boxid(i,2))
%     partid(i,boxid(i,mainno)) = mainno;
%     partid(i,3-boxid(i,mainno)) = 3-mainno;
%     repCnt = repCnt+1;
%   else
%     partid(i,boxid(i,1)) = 1;
%     partid(i,boxid(i,2)) = 2;
%   end
% end
% repCnt
% %assert(1==0)
for i=1:totalnum
  outimg_id = i-1;
  for j=1:2
    inimg_id = (i-1)*boxnum+j;
    outimgpath = sprintf('%s/%d.jpg',partoutdir{j},outimg_id);
    unix(sprintf('cp %s %s',[pathlist{inimg_id}],outimgpath));
  end
  if(mod(i,1000)==0 || i==totalnum)
    fprintf('have process %d images. %s --> %s\n',i, pathlist{inimg_id},outimgpath);
  end
end
