function [data,preproc] = eeg_trialselect(data, preproc, trlfile)
%remove catch trials/trials with responses, and add updated trial list to
%data structure for further analyses (action perception experiment)
%final step in EEG data cleaning 
%D.C.Dima Feb 2020

%% load .mat file containing trial list & responses
trl = load(trlfile);
ntrl = numel(trl.trl_list);

%get indices of catch trials
catch_trl_idx = find(trl.trl_list>95);

%check if a response variable was recorded and remove all trials with a response in addition to the catch trials
if isfield(trl,'response') && ~contains(trlfile, 'p08_25-Jan') 
    catch_trl_idx = unique([catch_trl_idx find(trl.response)]);
end

%make a catch/response trial index
catchlist = false(1,ntrl); 
catchlist(catch_trl_idx) = 1;

%photodiode malfunction in last run: remove badly marked trials
if contains(trlfile,'p13_21')
    catchlist(860:ntrl) = [];
    trl.trl_list(860:ntrl) = [];
%EEG malfunction in first run - remove unrecorded trials    
elseif contains(trlfile,'p14_24')
    catchlist = catchlist(77:ntrl);
    trl.trl_list = trl.trl_list(77:ntrl);
elseif contains(trlfile,'p17_09')
    catchlist = catchlist(2:ntrl);
    trl.trl_list = trl.trl_list(2:ntrl);
elseif contains(trlfile, 'p17_04')
    catchlist = catchlist(1:773);
    trl.trl_list = trl.trl_list(1:773);
end

triallist = trl.trl_list;
preproc.catch_trl = catchlist;                    %save index of catch&response trials in the preproc struct

%% 1. remove catch trials from clean EEG data
% adjust catch trial index to EEG size
trl_rmv_eeg = catchlist(preproc.idx_badtrial==0); %keep only good trials, so as to match EEG data which has been cleaned

%new EEG data struct: keep only the trials set to 0 in the catch trial index
cfg = [];
cfg.trials = find(~trl_rmv_eeg);
data = ft_preprocessing(cfg, data);

%% 2. remove (1) bad EEG trials (2) catch & response trials from trial list
trl_rmv_lst = logical(catchlist'+preproc.idx_badtrial);
triallist(trl_rmv_lst) = [];

if numel(triallist)~=numel(data.trial)
    error('Something is wrong with the trial selection')
end


%% save

%remove cfg to reduce file size and add trial list to the EEG data itself for easy further analysis
data = rmfield(data,'cfg');
data.triallist = triallist;

%save the final number of trials
preproc.num_trl = numel(data.trial);






end

