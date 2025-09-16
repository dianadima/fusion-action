function decmap = run_searchlight_crossdecoding(results,designSINGLE,thresh)

src_res = 3; %searchlight resolution
cond = cell(2,1);

for d = 1:2
    
    model = results{d}; 
    betas = model.modelmd;
    nvid = 95; %stimuli we care about

    %design elements
    cond{d} = designSINGLE{d}.stimorder;

    brainmask = model.meanvol>1000;
    if ~isempty(thresh)
        brainmask(~thresh) = 0;
    end

    brainsz = size(brainmask);
    decmap = nan(brainsz);

    vox_src = prepare_searchlight(brainsz, brainmask, src_res);

    betas = permute(betas,[4 1 2 3]);
    betas = betas(:,:);

    if d==1

        cond_betas1 = betas; clear betas
        searchlight1 = vox_src;
    else
        cond_betas2 = betas; clear betas
        searchlight2 = vox_src; clear vox_src

    end

end

clear results designSINGLE model

for vox = 1:numel(searchlight1)

    if ~isempty(searchlight1{vox}) && ~isempty(searchlight2{vox})

        sbetas1 = cond_betas1(:,searchlight1{vox});
        sbetas2 = cond_betas2(:,searchlight2{vox});

        if any(~isnan(sbetas1(:))) && any(~isnan(sbetas2(:)))

            voxbetas1 = nan(nvid,size(sbetas1,2));
            voxbetas2 = nan(nvid,size(sbetas2,2));

            for v = 1:nvid

                vidx1 = cond{1}==v;
                voxbetas1(v,:) = nanmean(sbetas1(vidx1,:),1); %#ok<*NANMEAN>

                vidx2 = cond{2}==v;
                voxbetas2(v,:) = nanmean(sbetas2(vidx2,:),1); %#ok<*NANMEAN>

            end

            voxbetas1(:,isnan(sum(voxbetas1,1))) = [];
            voxbetas2(:,isnan(sum(voxbetas2,1))) = [];

            d = decode_svm(nvid,voxbetas1,voxbetas2);

            [vx1,vx2,vx3] = ind2sub(brainsz,vox);
            decmap(vx1,vx2,vx3) = nanmean(d);

        end

    end

end



    function d = decode_svm(ncond,traindata,testdata)

        sd = std(traindata,[],2,'omitnan');
        traindata = bsxfun(@rdivide,traindata,sd); 
        testdata = bsxfun(@rdivide,testdata,sd);

        trainlabel = double((1:ncond))';
        testlabel = double((1:ncond))';

        dv_elements = zeros(ncond,ncond*(ncond-1)/2,'single');
        for c = ncond-1:-1:1
            rows = ncond-c:ncond;
            cols = sum(c+1:ncond-1)+1:sum(c+1:ncond-1)+c;
            dv_elements(rows,cols) = [ones(1,c);-eye(c)];
        end
        dv_plus_ndx = find(dv_elements>0);

        d = zeros(ncond*(ncond-1)/2,1,'single'); 
        smodel = svmtrain(trainlabel,double(traindata),'-s 0 -t 0 -q -b 0'); %#ok<SVMTRAIN>
        [~, ~, decision_values] = svmpredict(testlabel, double(testdata), smodel,'-q');
        d = single(decision_values(dv_plus_ndx)>0) + single(decision_values(dv_minus_ndx)<0); %#ok<*FNDSB> 

        scale = 100/1/2; 
        d = d*scale;

    end

end


