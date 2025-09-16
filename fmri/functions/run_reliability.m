function [corrmap, condmap] = run_reliability(results,designSINGLE)


sigma = 2.55; %for a FWHM of 6

model = results{4}; clear results
betas = model.modelmd;

ntrl = size(betas,4);
nvid = 95; %stimuli we care about

%design elements
cond = designSINGLE.stimorder;
trun = designSINGLE.numtrialrun;

%smoothing: only for this analysis
smooth_betas = nan(size(betas));
for i = 1:ntrl
    smooth_betas(:,:,:,i) = imgaussfilt3(betas(:,:,:,i),sigma);
end
clear betas


brainmask = model.meanvol>1000;
smooth_betas(~brainmask) = nan;

%divide betas into odd-even runs

idx1 = zeros(ntrl,1);
c = 1;
for r = 1:10
    if mod(r,2)>0
        idx1(c:c+trun(r)-1) = 1;
    else
        idx1(c:c+trun(r)-1) = 0;
    end
    c = c+trun(r);
end
idx2 = abs(idx1-1);

betas1 = smooth_betas(:,:,:,logical(idx1));
betas2 = smooth_betas(:,:,:,logical(idx2));
clear smooth_betas

cond1 = cond(logical(idx1));
cond2 = cond(logical(idx2));

%get voxel-wise reliability first
corrmap = nan(size(brainmask));

for vx1 = 1:size(brainmask,1)
    for vx2 = 1:size(brainmask,2)
        for vx3 = 1:size(brainmask,3)

            half1 = nan(nvid,1);
            half2 = nan(nvid,1);

            for v = 1:nvid

                vidx1 = cond1==v;
                half1(v) = nanmean(squeeze(betas1(vx1,vx2,vx3,vidx1)));

                vidx2 = cond2==v;
                half2(v) = nanmean(squeeze(betas2(vx1,vx2,vx3,vidx2)));
            end

            corrmap(vx1,vx2,vx3) = corr(half1,half2);
        end
    end
end

%then get condition reliability using various threshold
thresh_range = 0:0.05:0.95;
condmap = nan(numel(thresh_range),nvid);
for t = 1:numel(thresh_range)
    c = corrmap>thresh_range(t);
    
    for v = 1:nvid
        
        vidx1 = cond1==v;
        b1 = nanmean(betas1(:,:,:,vidx1),4);
        
        vidx2 = cond2==v;
        b2 = nanmean(betas2(:,:,:,vidx2),4);

        %remove unreliable voxels
        b1(~c) = nan; b1 = b1(:); b1(isnan(b1)) = [];
        b2(~c) = nan; b2 = b2(:); b2(isnan(b2)) = [];
        if ~isempty(b1)
            condmap(t,v) = corr(b1,b2);
        end
    end
end


end





