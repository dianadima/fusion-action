%% Multimodal action understanding EEG experiment analysis
% Read and preprocess EEG data; perform pairwise decoding, representational similarity analysis, and variance partitioning

%% set paths
clear; clc; close all
set(0,'DefaultAxesFontName','Arial')
set(0,'DefaultFigureRenderer','painters')

%add path to Fieldtrip
addpath('~/Scripts/fieldtrip-20220104/')
ft_defaults

%specify dataset type: 'vid' (videos) / 'sen' (sentences)
dtype = 'vid';
%dtype = 'sen';

%set paths
basepath = fileparts(fileparts(matlab.desktop.editor.getActiveFilename));    %parent directory
addpath(genpath(fileparts(basepath)))                                        %add code to path

datapath = fullfile(basepath, 'data', dtype);                                %path to data
savepath = fullfile(basepath, 'results', dtype);                             %path to results
stimpath = fullfile(fileparts(basepath), 'stimuli', dtype);                  %path to stimuli

%% read & preprocess data

eeg_preprocess(datapath,savepath)

%% read & preprocess eyetracking data 

%get gaze data and fixation info
et_convert(datapath)

%create eyetracking-based RDM
et_rdm(datapath)

%% time-resolved decoding

%within modality
eeg_decode(datapath,savepath,'time-resolved');

%across modalities
eeg_crossdecode(fullfile(basepath, 'data', 'vid'), fullfile(basepath,'data','sen'), fullfile(basepath,'results'),'time-resolved');

%% time-resolved RSA

eeg_rsa(datapath,savepath)

%% variance partitioning

models = {'Action target'; 'Action class'; 'Everyday activity'};
eeg_varpart2(datapath,savepath,'varpart_semantic_loo.mat',models);

models = {'Action target'; 'Everyday activity'; 'Action verb'};
eeg_varpart2(datapath,savepath,'varpart_semantic_ver2_loo.mat',models);

models = {{'CORnet-S V1'};{'Effectors'}; {'Action target','Action class','Everyday activity','Action verb'}};
eeg_varpart2(datapath,savepath,'varpart_grouped_c_e_tcav_loo.mat',models);





