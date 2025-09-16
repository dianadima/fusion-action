function [] = eeg_decode(datapath, savepath, type)
% pairwise video decoding using fusionlab toolbox
% trials are averaged within folds (k-fold CV) and randomly assigned to folds using specified number of permutations
% plots average accuracy over subjects and pairs
% note: requires fl_decodesvn function; for alternatives, see my meg-mvpa repository 

%outputs
switch type
    case 'time-resolved'
        outfile = 'decoding_accuracy.mat'; %time-resolved decoding
    case 'temporal-gen'
        outfile = 'decoding_accuracy_tg.mat'; %temporal generalization
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
    subdatapath = fullfile(datapath, sub);
    datafile = fullfile(subdatapath, [sub 'data1.mat']);

    if exist(datafile,'file')

        data = load(datafile);
        time = data.time{1};

        %get data into right format
        [datamatrix, condid] = eeg_preparerdm(data,0); %use 0 to keep all observations for decoding
        clear data

        switch type

            case 'time-resolved'
                dec = fl_decodesvm(datamatrix,condid,'method', 'pairwise','numpermutation',10, 'kfold',2);
                decoding_acc(isub,:,:) = dec.d';  %#ok<*AGROW>

            case 'temporal-gen'
                dec = fl_decodesvm(datamatrix,condid,'method','temporalgen','numpermutation',1,'kfold',2);
                decoding_acc = dec.d;
                save(fullfile(savepath,strrep(outfile,'.mat',sprintf('_%02.f.mat',isub))),'-v7.3','decoding_acc','time')
                clear dec decoding_acc
        end

    end
end

%note: statistical testing done with jackknifing, code available at https://osf.io/nrtvx/

end

