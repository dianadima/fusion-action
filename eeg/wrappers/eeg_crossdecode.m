function [] = eeg_crossdecode(datapath1, datapath2, savepath, type)
% pairwise video decoding using fusionlab toolbox
% trials are averaged within folds (k-fold CV) and randomly assigned to folds using specified number of permutations
% plots average accuracy over subjects and pairs 

%outputs
switch type
    case 'time-resolved'
        outfile = 'crossdecoding_accuracy.mat'; %time-resolved decoding
    case 'temporal-gen'
        outfile = 'crossdecoding_accuracy_tg.mat'; %temporal generalization
end

nsub = 20;

%store results
if contains(type,'time')
    decoding_acc = [];
end

for isub = 1:nsub

    %counter
    fprintf('Subject %d out of %d\n', isub, nsub)

    %get subject specific paths and filenames
    sub = sprintf('%02.f',isub);
    datafile1 = fullfile(datapath1, sub, [sub 'data.mat']);
    datafile2 = fullfile(datapath2, sub, [sub 'data.mat']);
    
    if exist(datafile1,'file')

    d1 = load(datafile1);
    d2 = load(datafile2);

    [data1, condid1] = eeg_preparerdm(d1,0); %use 0 to keep all observations for decoding
    [data2, condid2] = eeg_preparerdm(d2,0); %use 0 to keep all observations for decoding
    
    time = d1.time{1};

    %make sure the same channels are present in both datasets
    while(numel(d1.label)~=numel(d2.label))
        if numel(d1.label)>numel(d2.label)
            idx = [];
            for ichan = 1:numel(d1.label)
                x = 0;
                for ichan2 = 1:numel(d2.label)
                    if strcmp(d1.label{ichan},d2.label{ichan2})
                        x = 1;
                    end
                end
                if x==0, idx = [idx ichan]; end
            end
            data1(idx,:,:) = [];
            d1.label(idx) = [];
        elseif numel(d2.label)>numel(d1.label)
            idx = [];
            for ichan = 1:numel(d2.label)
                x = 0;
                for ichan2 = 1:numel(d1.label)
                    if strcmp(d2.label{ichan},d1.label{ichan2})
                        x = 1;
                    end
                end
                if x==0, idx = [idx ichan]; end
            end
            data2(idx,:,:) = [];
            d2.label(idx) = [];
        end
    end

    clear d1 d2

    switch type
        case 'time-resolved'
            dec = fl_decodesvm(data1,condid1,data2,condid2,'method', 'pairwise','numpermutation',1, 'kfold',1);
            decoding_acc(isub,:,:) = dec.d2';  %#ok<*AGROW>
        case 'temporal-gen'
            dec = fl_decodesvm(data1,condid1,data2,condid2,'method', 'temporalgen','numpermutation',1, 'kfold',2);
            decoding_acc = dec.d; 
            save(fullfile(savepath,strrep(outfile,'.mat',sprintf('_%02.fa.mat',isub))),'-v7.3','decoding_acc','time')
            clear dec decoding_acc

    end
    
    end

end

%note: statistical testing done with jackknifing, code available at https://osf.io/nrtvx/

end
