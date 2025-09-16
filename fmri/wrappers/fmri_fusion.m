function [] = fmri_fusion(respath,sub_idx)

dtype = 'ses-vid';
nsub = numel(sub_idx);

%load EEG time-resolved decoding data
load('~/eeg/results/vid/decoding_accuracy.mat','decoding_acc','time');
eeg = squeeze(nanmean(decoding_acc,1)); clear decoding_acc
time_orig = time; clear time

%run fusion
for isub = 1:nsub

    fprintf('Running subject %d...\n',isub)
    load(fullfile(respath,'rdmZ',sprintf('rdm%d',isub)),'rdm');
    [fus_corr,time] = run_fusion(rdm,eeg,time_orig);
    clear rdm

    save(fullfile(respath,'fusion',['fusZ-' dtype '-' num2str(isub) '.mat']),'-v7.3','fus_corr','time')

end
%stats using Matlab TFCE toolbox

end



