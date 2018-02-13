function Build_Patch_Dataset(stbatch, endbatch)
    for i = stbatch:endbatch
       demoImageNetDog(i); 
       %Build_Patch_Batch(i);
    end
end