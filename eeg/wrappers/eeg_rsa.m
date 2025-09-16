function [results] = eeg_rsa(datapath,savepath)
%correlate EEG patterns to model RDMs, behavioral RDM, and eyetracking RDM


load(fullfile(datapath,'models.mat'),'models','modelnames');
for i = 1:size(models,2)
    models(:,i) = (models(:,i)-mean(models(:,i)))/(std(models(:,i)));
end

load(fullfile(savepath,'decoding_accuracy.mat'),'decoding_acc','time')

time_orig = time;

nmod = numel(modelnames);
nsub = size(decoding_acc,1);

[winmat,time, nwin] = eeg_timewindows(time_orig);

rsacorr = nan(nsub,nmod,nwin);

for isub = 1:nsub

    fprintf(sprintf('Running participant %d\n',isub))

    rdm = squeeze(decoding_acc(isub,:,:));
    subcorr = eeg_runrsa(rdm,time_orig,models);
    rsacorr(isub,:,:) = subcorr;
end

%fixed-effects version
avgrdm = squeeze(mean(decoding_acc,1));
avgcorr = eeg_runrsa(avgrdm,time_orig,models);

%noise ceiling
nc_low = nan(nsub,nwin);
nc_upp = nan(nsub,nwin);

for isub = 1:nsub
    tmp1 = squeeze(decoding_acc(isub,:,:));
    tmp2 = decoding_acc;
    tmp2(isub,:,:) = [];
    tmp2 = squeeze(mean(tmp2,1));
    for iwin = 1:nwin

      nc_low(isub,iwin) = spearman_rho_a(mean(tmp1(:,winmat(:,iwin)),2), mean(tmp2(:,winmat(:,iwin)),2));
      nc_upp(isub,iwin) = spearman_rho_a(mean(tmp1(:,winmat(:,iwin)),2), mean(avgrdm(:,winmat(:,iwin)),2));

    end
end

%results
results.rsa = rsacorr;
results.rdm = decoding_acc;
results.avgrsa = avgcorr;
results.modelnames = modelnames;
results.time = time;
results.time_orig = time_orig;
results.noiseceil_upp = nc_upp;
results.noiseceil_low = nc_low;

save(fullfile(savepath,'rsa.mat'),'-struct','results')

%note: statistical testing done with jackknifing, code available at https://osf.io/nrtvx/





end