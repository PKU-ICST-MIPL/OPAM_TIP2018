function RunImageNetBird(pidx)
    pwork = 8;
    stbatch = pidx * pwork;
    endbatch = min(77, (pidx + 1) * pwork);
    [stbatch, endbatch]
    for i = stbatch:endbatch-1
        demoImageNetBird(i); 
    end
end