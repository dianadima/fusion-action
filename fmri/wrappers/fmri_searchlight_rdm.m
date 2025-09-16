function [] = fmri_searchlight_rdm(glmpath,respath,sub_idx)

dtypes = {'ses-vid','ses-sen'};
nsub = numel(sub_idx);

for dt = 1:2

    dtype = dtypes{dt};
    fprintf('Running dataset %s...\n',dtype)
    load(fullfile(glmpath,['thresh_' dtype(5:7) '_prc.mat']),'thresh')

    for isub = 1:nsub

        fprintf('Running subject %d...\n',isub)

        if sub_idx(isub) < 10
            sub_id = sprintf('sub-%02.f',sub_idx(isub));
        else
            sub_id = sprintf('sub-%03.f',sub_idx(isub));
        end

        load(fullfile(glmpath,sub_id,dtype,'glm_task.mat'),'results','designSINGLE')
        rdm = get_searchlight_rdm(results,designSINGLE,thresh);
        save(fullfile(respath,'rdmZ_sen',sprintf('rdm%d.mat',isub)),'-v7.3','rdm')
        clear rdm

    end
   
end
