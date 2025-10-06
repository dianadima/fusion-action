%% Multimodal action understanding fMRI experiment analysis
% Read and preprocess fMRI data; perform pairwise decoding, representational similarity analysis, and variance partitioning
% DC Dima 2023
% note: for fMRI, the structure is data/subject/session

%% set paths
clear; clc; close all

%add path to GLMsingle; assumes running from script directory
wpath = pwd;
cd('~/Scripts/GLMsingle/'); setup; addpath(pwd); cd(wpath)

%specify dataset type: 'vid' (videos) / 'sen' (sentences)
dtypes = {'vid','sen'};

%set paths
%basepath = fileparts(fileparts(matlab.desktop.editor.getActiveFilename));    %parent directory
basepath = fileparts(wpath);
addpath(genpath(fileparts(wpath)))                                            %add code to path

datapath = fullfile(basepath, 'preproc', 'fmriprep');                         %path to fMRIprep data
glmspath = fullfile(basepath, 'preproc', 'glmsingle');                        %path to GLMsingle data
dsgnpath = fullfile(basepath, 'matlabdata');                                  %path to trial and stimulus information
savepath = fullfile(basepath, 'results');                                     %path to results

%subject IDs to analyze
sub_idx = [4, 11, 15, 16, 18, 2, 21,13, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33];

%% preprocessing: create design matrices and run GLMsingle

fmri_designs(dsgnpath,sub_idx)
fmri_glmsingle(dsgnpath,datapath,sub_idx)

%% reliability mask: get voxel-wise reliability

fmri_reliability(glmspath,sub_idx)

%% compute RDMs at each searchlight

fmri_searchlight_rdm(glmspath,savepath,sub_idx);

%% decoding and cross-decoding searchlight

fmri_decode(glmspath,savepath,sub_idx)
fmri_crossdecode(glmspath,savepath,sub_idx)

%% searchlight multiple regression RSA

fmri_searchlight_rsa(savepath,sub_idx)

%% EEG-fMRI fusion

fmri_fusion(savepath,sub_idx)
