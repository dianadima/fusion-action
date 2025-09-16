function [results] = eeg_rsaonsets(results)
% bootstrapping analysis of feature correlation onsets
% onsets are determined with jackknifing, code available at https://osf.io/nrtvx/
% DC Dima 2025

rng(10)
rsacorr = results.rsa;
time = results.time;

nboot = 1000;
nsub = size(rsacorr,1);
nmod = size(rsacorr,2);

onsets = nan(nboot,nmod);
peaks = nan(nboot,nmod);

opt.std_threshold = 2;
opt.window_length = 5;
opt.n_windows=5;
opt.baseline_idx = 33;
opt.alpha = 0.05;
opt.tail = "right";

for ib = 1:nboot
    
    idx = randi(nsub,nsub,1); %bootstrap with replacement
    rsaboot = rsacorr(idx,:,:);
    rsabootmean = squeeze(nanmean(rsaboot,1));

    for imod = 1:nmod

        [~,peak_idx] = max(rsabootmean(imod,:));
        peaks(ib,imod) = time(peak_idx);

        stats = roifusion_stats_opts_jackknife_pb(squeeze(rsaboot(:,imod,:)),opt);

        if any(stats.SignificantVariables>0)
            onsets(ib,imod) = time(find(stats.SignificantVariables,1));
        end

    end


end

results.onsets = onsets;
results.peaks = peaks;




end

