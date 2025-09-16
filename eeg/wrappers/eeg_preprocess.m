function [] = eeg_preprocess(datapath,savepath)
% loop through subjects and read, preprocess and plot EEG data (basic timelock analysis)
% multimodal action experiment
% inputs: datapath: path to data (preprocessed data will be saved here)
%         savepath: path to results (will be used to save figures)

figpath = fullfile(savepath,'figures'); mkdir(figpath)
subfigpath = fullfile(figpath, 'individual'); mkdir(subfigpath)

% CHANGE ME
nsub = 20;
timelock_array = cell(nsub,1);

%save preprocessing data for all subjects
p = struct;

for isub = 1:nsub

    subf = sprintf('%.2d',isub);
    cd(fullfile(datapath,subf))

    eegfile = [subf '.bdf'];
    trlfile = dir(['p' subf '*.mat']).name;

    outfile = [subf 'data.mat'];         %save preproc data

    if ~exist(fullfile(datapath,subf,[subf 'data.mat']),'file')

        %for certain sessions, use digital trigger instead of light sensor (which lost connection for some trials)
        v = 1;
        if (contains(datapath,'vid') && ismember(isub,[3 11 14:20])) || (contains(datapath,'sen') && ismember(isub,[2:4 15:20]))
            v = 0;
        end

        data = eeg_readdata(eegfile, v);
        [data, preproc] = eeg_cleandata(data, trlfile, outfile);

    end

    %timelock analysis
    cfg = [];
    timelock = ft_timelockanalysis(cfg,data);
    eeg_ploterp(timelock, subf, subfigpath) %plot & save ERP topographies/butterfly plot
    
    timelock_array{isub} = timelock;
    p = eeg_savepreproc(preproc,isub,p);

end

save(fullfile(datapath,'preproc.mat'),'-struct','p')
close all

%plot & save grand average topography and global field power
cfg = [];
alltimelock = ft_timelockgrandaverage(cfg,timelock_array{:});
save(fullfile(savepath,'avg_erp.mat'),'alltimelock','timelock_array')
eeg_ploterp(alltimelock,'avg',figpath);