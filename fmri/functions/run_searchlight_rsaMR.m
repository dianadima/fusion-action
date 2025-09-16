function corrmap = run_searchlight_rsaMR(rdm,models)
% run searchlight RSA (multiple regression)

nmod = size(models,2);
brainsz = [78 93 78];
corrmap = nan([nmod brainsz]);

for vx1 = 1:size(rdm,1)
    for vx2 = 1:size(rdm,2)
        for vx3 = 1:size(rdm,3)

            vb = squeeze(rdm(vx1,vx2,vx3,:));

            if ~isnan(sum(vb))

                %multiple regression
                lm = fitlm(models,vb);
                corrmap(:,vx1,vx2,vx3) = lm.Coefficients.Estimate(2:end); 
            end


        end
    end
end




end





