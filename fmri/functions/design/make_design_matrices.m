function [] = make_design_matrices(subpath)

nruns = 10;
d = {dir(subpath).name};
d(1:2) = [];
design = cell(nruns,1);

for r = 1:nruns

    idx = find(contains(d,['_block' num2str(r) '_']));
    load(fullfile(subpath,d{idx}),'trllist','stim_onsets'); %#ok<*FNDSB> 
    design{r} = onsets_to_dm(trllist,stim_onsets);
end

save(fullfile(subpath,'design.mat'),'design')
