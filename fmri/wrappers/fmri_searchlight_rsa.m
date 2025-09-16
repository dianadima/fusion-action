function [] = fmri_searchlight_rsa(respath,sub_idx)

dtype = 'ses-vid';
nsub = numel(sub_idx);
brainsz = [78 93 78];
load(fullfile(respath,'models.mat'),'models','modelnames')

nmod = size(models,2);
rsapred = nan([nsub nmod brainsz]);

for isub = 1:numel(sub_idx)

    fprintf('Running subject %d...\n',isub)
    load(fullfile(respath,'rdmZ',sprintf('rdm%d.mat',isub)),'rdm');

    rsamap = run_searchlight_rsaMR(rdm,models);
    rsapred(isub,:,:,:,:) = rsamap;

end

rsapred = permute(rsapred, [2 1 3 4 5]);

%get vif
R0 = corrcoef(models);
vif = diag(inv(R0))';

save(fullfile(respath,'rsa_vid.mat'),'rsapred','modelnames','vif')

%stats using Matlab TFCE toolbox

end













end