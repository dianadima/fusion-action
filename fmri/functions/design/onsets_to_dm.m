function dm = onsets_to_dm(trllist,stim_onsets)

%load(trlfile,'trllist','onsets');
tr = 1;
ntr = 375;
nst = 113; %maximum number of unique stimuli across runs

%note: GLMsingle requires design matrix without blanks coded
dm = zeros(ntr,nst);

onsets = stim_onsets - 0.5; %slice timing correction
trarray = 1:tr:ntr;
%catch_counter = 0;

for i = 1:nst %this skips nulls, coded as 0

    idx = find(trllist==i);

    for ii = 1:numel(idx)

        ons = onsets(idx(ii));
        tr_ons = nearest(trarray,ons);

        if i>0
            dm(tr_ons,i) = 1;
        else
            dm(tr_ons,nst+1) = 1; %code nulls as last condition 
        end

    end
end

%clear the last trial from the design matrix: too close to end of run
dm(369:375,:) = 0; %advised solution



        



