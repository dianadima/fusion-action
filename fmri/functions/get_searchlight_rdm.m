function brain_rdm = get_searchlight_rdm(results,designSINGLE,thresh)
% get RDMs at each searchlight
% input: results structure from GLMsingle;
%        design structure from GLMsingle
%        threshold based on voxel reliability
% no smoothing applied; betas are zscored within run and across voxels within each searchlight

src_res = 3; %searchlight resolution
model = results{4}; clear results; betas = model.modelmd; %betas
nvid = 95; %stimuli we care about
cond = designSINGLE.stimorder; %stimulus indexing

%zscore betas across images within each run, first step
c = 1;
tr_remove = find(cond>nvid);
for i = 1:numel(designSINGLE.design) %for each run
   
    idx = c:c+designSINGLE.numtrialrun(i)-1; %select trials for this run
    betas(:,:,:,idx(ismember(idx,tr_remove))) = NaN; %ignore catch trials when computing zscores
    c = c+designSINGLE.numtrialrun(i); %update index
    betas(:,:,:,idx) = (betas(:,:,:,idx) - nanmean(betas(:,:,:,idx),4))./nanstd(betas(:,:,:,idx),[],4); %zscore
end

%threshold data 
brainmask = model.meanvol>1000; % this gets rid of voxels outside brain
if ~isempty(thresh)
    brainmask(~thresh) = 0;
end

brainsz = size(brainmask);
brain_rdm = nan([brainsz 95*94/2]);

vox_src = prepare_searchlight(brainsz, brainmask, src_res);

betas = permute(betas,[4 1 2 3]);
betas = betas(:,:);

clear thresh designSINGLE model

for vox = 1:numel(vox_src)

    if ~isempty(vox_src{vox})

        sbetas = betas(:,vox_src{vox});

        if any(~isnan(sbetas(:)))

            [vx1,vx2,vx3] = ind2sub(brainsz,vox);
            voxbetas = nan(nvid,size(sbetas,2));

            for v = 1:nvid

                vidx1 = cond==v;
                voxbetas(v,:) = nanmean(sbetas(vidx1,:),1); %#ok<*NANMEAN>

            end

            voxbetas(:,isnan(sum(voxbetas,1))) = [];
            voxbetas = zscore(voxbetas,0,2); %second normalization: zscore across voxels
            vb = pdist(voxbetas).^2'; %squared Euclidean distance

            brain_rdm(vx1,vx2,vx3,:) = vb;
        end

    end

end

end





