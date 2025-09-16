function [data] = eeg_readdata(eegfile, lightsensor)
%read and preprocess EEG data from action perception experiment
%trials are read based on stimulus onset, realigned to photodiode onsets,
%and epoched into -0.2 to 1 segments
%data is high-pass filtered at 0.1 Hz and re-referenced to average of mastoids
%D.C. Dima Feb 2020

toi = [-0.2 2.8]; %duration of epoch of interest

%define trials and realign to photodiode onset
cfg = [];
cfg.datafile            = eegfile;
cfg.trialdef.eventtype  = 'STATUS'; 
cfg.trialdef.prestim    = abs(toi(1));
cfg.trialdef.poststim   = abs(toi(2));

if lightsensor
    if contains(eegfile,'13.bdf') && contains(pwd,'vid')
        cfg.trialdef.eventvalue = 1; %photodiode coded differently
    else
        cfg.trialdef.eventvalue = 513;
    end
else
    cfg.trialdef.eventvalue = 512;
end

cfg = ft_definetrial(cfg);
data = ft_preprocessing(cfg);

cfg            = [];
cfg.reref      = 'yes';
cfg.refchannel = 'all';
cfg.refmethod  = 'avg';

cfg.channel        = 1:64; 
cfg.demean         = 'yes';           %demean data
cfg.baselinewindow = [toi(1) 0];      %use pre-trigger period for baselining
cfg.detrend        = 'no';                

cfg.hpfilter       = 'yes';           %high-pass filter before artefact rejection to remove slow drifts
cfg.hpfreq         = 0.01;             %use a low threshold to avoid distorting temporal dynamics
cfg.hpfiltord      = 3;               %a lower filter order ensures filter stability

data = ft_preprocessing(cfg,data);

%remove badly marked trials
if contains(eegfile,'13.bdf') && contains(pwd,'vid')
    cfg = [];
    cfg.trials = 1:859;
    data = ft_selectdata(cfg,data);
end