function [winmat,time,nwin] = eeg_timewindows(time)
% get 10 ms time windows with 6 ms overlap
% input: original time axis & number of samples
% output: window matrix, corrected time axis & number of windows

ws = 5; %10 ms window
ov = 2; %4 ms overlap

nwin_orig = numel(time);
t = 1:nwin_orig;
winmat = buffer(t,ws,ov);
winmat = winmat(:,2:end-1);

nwin = size(winmat,2);
time = time(winmat(1,:)); %save starting timepoints of windows

end

