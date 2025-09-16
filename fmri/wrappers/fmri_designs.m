function [] = fmri_designs(dsgnpath,sub_idx)
%iterate through subjects and create design matrices

dtypes = {'ses-vid','ses-sen'};

for isub = 1:numel(sub_idx) 

    %fix subject coding
    if sub_idx(isub) < 10
        sub_id = sprintf('%02.f',sub_idx(isub));
    else
        sub_id = sprintf('%03.f',sub_idx(isub));
    end

    for dset = 1:2
        dpath = fullfile(dsgnpath, sub_id, dtypes{dset});
        make_design_matrices(dpath)
    end

end


end