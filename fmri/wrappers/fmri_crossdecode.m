function [] = fmri_crossdecode(glmpath,respath,sub_idx)

dtypes = {'ses-vid','ses-sen'};
nsub = numel(sub_idx);
brainsz = [78 93 78];
decoding_map = nan([nsub brainsz]);
load(fullfile(glmpath,'thresh_vid_prc.mat'),'thresh');

for isub = 1:numel(sub_idx)

    fprintf('Running subject %d...\n',isub)
    sub_res = cell(2,1); sub_des = cell(2,1);

    if sub_idx(isub) < 10
        sub_id = sprintf('sub-%02.f',sub_idx(isub));
    else
        sub_id = sprintf('sub-%03.f',sub_idx(isub));
    end

    for dt = 1:2

        load(fullfile(glmpath,sub_id,dtypes{dt},'glm_task.mat'),'results','designSINGLE')
        sub_res{dt} = results{4};
        sub_des{dt} = designSINGLE;
    end

    decmap = run_searchlight_crossdecoding(sub_res,sub_des,thresh);
    decoding_map(isub,:,:,:) = decmap;
    clear decmap

end

save(fullfile(respath,'crossdecode','crossdecoding.mat'),'decoding_map')
%stats using Matlab TFCE toolbox



end
