function [] = fmri_glmsingle(dsgnpath,datapath,sub_idx)
%iterate through subjects and run GLMsingle for every subject & session

dtypes = {'ses-vid','ses-sen'};
savepath = fileparts(datapath);
mkdir(fullfile(savepath,'glmsingle'))

for isub = 1:numel(sub_idx) 

    if sub_idx(isub) < 10
        sub_id = sprintf('%02.f',sub_idx(isub));
    else
        sub_id = sprintf('%03.f',sub_idx(isub));
    end

    mkdir(fullfile(savepath,'glmsingle',['sub-' sub_id]))
    
    for dset = 1:2

        sub = ['sub-' sub_id];
        ses = dtypes{dset};

        dpath = fullfile(dsgnpath, sub_id, ses);
        load(fullfile(dpath,'design.mat'),'design')
    
        fpath = fullfile(datapath,['sub-' sub_id],dtypes{dset},'func');
        spath = fullfile(savepath,'glmsingle', ['sub-' sub_id], dtypes{dset});
        mkdir(spath)

        % run GLM for perception task
        cfg = [];
        cfg.nruns = numel(design);
        cfg.stimdur = 2;
        cfg.task = 'perception';
        cfg.ses = ses;
        cfg.sub = sub;

        run_glm(design,fpath,spath,cfg)

    end
end


    function [] = run_glm(design,fpath,spath,cfg)

        tr = 1;
        stimdur = cfg.stimdur;
        data_array = cell(cfg.nruns,1);

        for r = 1:cfg.nruns

            datafile = sprintf('%s_%s_task-%s_run-%01.f_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz',cfg.sub,cfg.ses,cfg.task,r);
            maskfile = sprintf('%s_%s_task-perception_run-%01.f_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz',cfg.sub,cfg.ses,r);

            %skull strip data
            data = niftiread(fullfile(fpath,datafile));
            mask = niftiread(fullfile(fpath,maskfile));
            data(mask==0) = 0;

            data_array{r} = data;

        end
            
            %run GLMsingle
            [results,designSINGLE] = GLMestimatesingletrial(design',data_array',stimdur,tr);

            save(fullfile(spath,'glm_task.mat'),'-v7.3','results','designSINGLE')

        end

end
