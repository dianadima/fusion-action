function [p] = eeg_savepreproc(pr,isub,p)
% add participant data to structure containing preprocessing parameters

%save artefact rejection data across participants

p.badchan_num(isub) = 64 - pr.num_channels;
p.trlcatch_num(isub) = sum(pr.catch_trl);
p.trlcatch_prc(isub) = sum(pr.catch_trl)/numel(pr.catch_trl);

badtrl = pr.idx_badtrial;
badtrl(pr.catch_trl) = 0;
p.trlbad_num(isub) = sum(badtrl);
p.trlbad_prc(isub) = sum(badtrl)/(numel(badtrl)-p.trlcatch_num(isub));

p.muscle_zval(isub) = pr.muscle_zvalue;


end

