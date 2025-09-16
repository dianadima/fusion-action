function [corrmap,time] = run_fusion(rdm,eeg,time_orig)

nwin = size(eeg,2)/10;
time = 1:10:size(eeg,2);
sz = size(rdm);
corrmap = nan([sz(1) sz(2) sz(3) nwin]);

for t = 1:nwin

    eeg_rdm = nanmean(eeg(:,time(t):time(t)+9),2); %20 ms windows

    for vx1 = 1:sz(1)
        for vx2 = 1:sz(2)
            for vx3 = 1:sz(3)

                vb = squeeze(rdm(vx1,vx2,vx3,:));
                if ~isnan(sum(vb))
                    corrmap(vx1,vx2,vx3,t) = corr(vb,eeg_rdm);
                end

            end
        end
    end

end

%save downsampled time axis
time = time_orig(1:10:size(eeg,2));

end
