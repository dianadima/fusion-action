function [rsacorr, time] = eeg_runrsa(rdm,time,models)

[winmat, time, nwin] = eeg_timewindows(time);
rsacorr = nan(size(models,2),nwin);

for t = 1:nwin

    widx = winmat(:,t);
    trdm = squeeze(nanmean(rdm(:,widx),2));

    cmat = spearman_rho_a([trdm models]);
    rsacorr(:,t) = cmat(1,2:end);
end






end