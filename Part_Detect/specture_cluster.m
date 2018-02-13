function ind = specture_cluster(confmat, k)
    W = confmat + confmat';
    % Given W: a similarity matrix.
    
    F = sum(W);
    
    D = diag(sum(W));
    
    L = D - W;
    
    [v,d] = eig(L);
    F = v(:,2:k+1);
    F = F ./ repmat(sqrt(sum(F.^2,2)), 1, k);
    ind = kmeans(F,k);
end