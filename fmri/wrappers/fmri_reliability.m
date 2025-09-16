function [] = fmri_reliability(glmpath,sub_idx)

dtype = 'ses-vid';
nsub = numel(sub_idx);
brainsz = [78 93 78];
thresh_range = 0:0.05:0.95;
nvid = 95;

voxel_rel = nan([nsub brainsz]);
video_rel = nan([nsub numel(thresh_range) nvid]);

for isub = 1:numel(sub_idx)

    fprintf('Running subject %d...\n',isub)

    if sub_idx(isub) < 10
        sub_id = sprintf('sub-%02.f',sub_idx(isub));
    else
        sub_id = sprintf('sub-%03.f',sub_idx(isub));
    end

    load(fullfile(glmpath,sub_id,dtype,'glm_task.mat'),'results','designSINGLE')

    [voxmap,condmap] = run_reliability(results,designSINGLE);

    voxel_rel(isub,:,:,:) = voxmap;
    video_rel(isub,:,:) = condmap;

end

save(fullfile(glmpath,['reliability-' dtype '.mat']),'voxel_rel','video_rel')
%final mask is obtained by thresholding the averaged map


end













end