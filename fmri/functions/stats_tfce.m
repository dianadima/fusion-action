function [] = stats_tfce(results)
%run stats on RSA results

results = permute(results,[1 3 4 5 2]); %subjects are last dimension

nmod = size(results,1);
nsub = size(results,5);

pval_corr = nan(nmod,size(results,2),size(results,3),size(results,4));
tmap_corr = nan(size(pval_corr));

for im = 1:nmod

    r = squeeze(results(im,:,:,:,:));
    p = matlab_tfce('onesample',1,r);

    tmap = mean(r,4)./(std(r,0,4)./sqrt(nsub));
    tmap(p>0.05) = NaN;

    pval_corr(im,:,:,:) = p;
    tmap_corr(im,:,:,:) = tmap;

end



