function [varpart] = eeg_varpart_loo(rdm,time_orig,model1,model2,model3)
% cross-validated variance partitioning analysis
% runs cross-validation across action stimuli (leave-one-out)
% uses Spearman's rho-A squared as prediction metric
%
% inputs: rdm (vectorized, Nsub x Npairs)
%         model1, model2, model3: predictors (Nmodel x Npairs)
%
% output: varpart, structure containing
%                rsq_adj, adjusted R-squared for each combination of models
%                comb_labels, order of model combinations (i.e. abc, ab, bc, ac, a, b, c)
%                total_rsq, total variance explained by the models (adjusted R-squared)
%                noiseceil, upper and lower bounds of noise ceiling (cf. Nili et al 2014)


%must subsample stimuli, not participants
ncomb = 7; %num regressions to run

%time windows
[winmat,time,nwin] = eeg_timewindows(time_orig);

%combine predictors for hierarchical regression
comb{1} = [model1 model2 model3];
comb{2} = [model1 model2];
comb{3} = [model2 model3];
comb{4} = [model1 model3];
comb{5} = model1;
comb{6} = model2;
comb{7} = model3;

comb_labels = {'abc','ab','bc','ac','a','b','c'};
vif = nan(nwin,size(comb{1},2));
rsq_mat = nan(ncomb,nwin,21);

rdm_avg = squeeze(nanmean(rdm,1)); %#ok<*NANMEAN>

for iw = 1:nwin

    widx = winmat(:,iw);
    rdmt = nanmean(rdm_avg(:,widx),2);

    for icomb = 1:ncomb

        %train and test
        lm = fitlm(comb{icomb},rdmt);
        rsq_mat(icomb,iw,21) = lm.Rsquared.Ordinary;

        %variance inflation factor
        if icomb==1
            R0 = corrcoef(comb{icomb});
            vif(iw,:) = diag(inv(R0))';
        end

    end
end

for isub = 1:20

    rdm_loo = rdm; rdm_loo(isub,:,:) = [];
    rdm_loo = squeeze(nanmean(rdm_loo,1));

    for iw = 1:nwin

        widx = winmat(:,iw);
        rdmt = nanmean(rdm_loo(:,widx),2);

        for icomb = 1:ncomb

            %train and test
            lm = fitlm(comb{icomb},rdmt);
            rsq_mat(icomb,iw,isub) = lm.Rsquared.Ordinary;

        end
    end

    rdm_loo = nanmean(rdm_loo(:,widx),2);

    lm = fitlm(comb{icomb},rdm_loo);
    rsq_mat(icomb,iw,isub) = lm.Rsquared.Ordinary;
end


%unique variance
a = rsq_mat(1,:,:) - rsq_mat(3,:,:);
b = rsq_mat(1,:,:) - rsq_mat(4,:,:);
c = rsq_mat(1,:,:) - rsq_mat(2,:,:);

%shared variance (pairs)
bc = rsq_mat(2,:,:) - rsq_mat(5,:,:) - b;
ab = rsq_mat(4,:,:) - rsq_mat(7,:,:) - a;
ac = rsq_mat(3,:,:) - rsq_mat(6,:,:) - c;

%shared variance (abc)
abc = rsq_mat(1,:,:) - (a+b+c) - (ab+ac+bc);

var_mat = cat(1,abc,ab,bc,ac,a,b,c); %7

varpart.pred = var_mat;
varpart.total = rsq_mat(1,:,:);
varpart.comb_labels = comb_labels;
varpart.vif = vif;
varpart.time = time;

%note: statistical testing done with jackknifing, code available at https://osf.io/nrtvx/

end







