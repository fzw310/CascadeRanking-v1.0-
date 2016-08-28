function trainObjectness( VOCPath, annoStruct, base, W, NSS, numDetPerSz, T, parStartflag )
%TRAINOBJECTNESS train the w, a and b of objectness
%   trainObjectness includes two stage training of svm
%
IDX_trainObj = dlmread('train.txt');
trainStruct = annoStruct(IDX_trainObj);

% generate training data

NUM_train = length(IDX_trainObj);
NUM_neg_box = 100; % number of negative windows sampled from each image

fprintf('Preload training images and boxes ... ');
% preload images and ground truth bounding boxes on training set
im3u = cell(1, NUM_train);
gtTrainBoxes = cell(1, NUM_train);
for i = 1:NUM_train
    object = trainStruct(i).annotation.object;
    gtBoxes = [];
    for r = 1:length(object)
        if str2double(object(r).difficult), continue; end
        box = object(r).bndbox;
        xmin = str2double(box.xmin);
        xmax = str2double(box.xmax);
        ymin = str2double(box.ymin);
        ymax = str2double(box.ymax);
        gtBox = [xmin, ymin, xmax - xmin + 1, ymax - ymin + 1]; % [x, y, width, length]
        gtBoxes = cat(1, gtBoxes, gtBox);
    end
    gtTrainBoxes{i} = gtBoxes;
    
    % load image
    fileName = trainStruct(i).annotation.filename;
    im3u{i} = imread(fullfile(VOCPath, fileName));
end
fprintf('finished.\n');

%--------------------------------------------------------------------------
% get training data for training stage I
    fprintf('Get training data for training stage I ... ');

    xP = []; xN = [];
    szTrainP = cell(1, NUM_train);
    for i = 1:NUM_train
        [height, width, ~] = size(im3u{i});
        % get positive training data for training stage I
        szP = [];
        gtBoxes = gtTrainBoxes{i};
        
        [bndBoxes, bbR] = gtBndBoxSampling(gtBoxes, base, T);
        bndBoxes(:, 3) = min(bndBoxes(:, 3), width);
        bndBoxes(:, 4) = min(bndBoxes(:, 4), height);
        nS = size(bndBoxes, 1);
        for k = 1:nS
            mag1f = getNGFeature(im3u{i}, bndBoxes(k, :), W);
            magF1f = fliplr(mag1f); % flip left right to increase diversity of training data
%             mag1f = mag1f(W+1:2*W,W+1:2*W);
%             magF1f = magF1f(W+1:2*W,W+1:2*W);
            xP = cat(2, xP, mag1f(:));
            xP = cat(2, xP, magF1f(:));
            szP = cat(1, szP, bbR(k));
            szP = cat(1, szP, bbR(k));
        end
        
        szTrainP{i} = szP;

        % get negtive training data for training stage I
        x = ceil(rand(NUM_neg_box, 2) * width);
        y = ceil(rand(NUM_neg_box, 2) * height);

        negBoxes = [min(x, [], 2), min(y, [], 2), ...
                    max(x, [], 2) - min(x, [], 2) + 1, ...
                    max(y, [], 2) - min(y, [], 2) + 1];

        idx_vec = interUnion(negBoxes, gtBoxes) < 0.5;
        negBoxes = negBoxes(sum(idx_vec, 1) == size(gtBoxes, 1), :);

        for j = 1:size(negBoxes, 1) % adding a loop to avoid repeating time-wasting imread
            mag1f = getNGFeature(im3u{i}, negBoxes(j, :), W);
%             mag1f = mag1f(W+1:2*W,W+1:2*W);
            xN = cat(2, xN, mag1f(:));
        end
    end
    fprintf('finished.\n');

    %--------------------------------------------------------------------------
    % get active size
    NUM_R = T.numT * T.numT + 1;
    szCount = zeros(1, NUM_R);
    for i = 1:NUM_train
        rp = szTrainP{i};
        for j = 1:length(rp)
            szCount(rp(j)) = szCount(rp(j)) + 1;
        end
    end
    szActive = find(szCount > 50) - 1; % if only 50- positive samples at this size, ignore it.
    save szActive.mat szActive
    save xP_SVM_I.mat xP%%save the positive samples

    %--------------------------------------------------------------------------
    % training stage I
    fprintf('Start training stage I ... \n');
    t1 = tic;
    NUM_P = size(xP, 2);
    NUM_N = size(xN, 2);
    label = [1*ones(NUM_P, 1); -1 * ones(NUM_N, 1)];
    instance = sparse([xP'; xN']);

    svmModelI = train(label, instance, '-s 5 -c 10 -B 1');
    save svmModelI.mat svmModelI

    tTrainI = toc(t1);
    fprintf('Training stage I takes %f seconds.\n\n', tTrainI);

%--------------------------------------------------------------------------
% get training data for training stage II
    fprintf('Get training data for training stage II ... ');

    filterW = loadTrainedModel(W);
    load szActive

    xPcell = cell(NUM_train, length(szActive));
    xNcell = cell(NUM_train, length(szActive));
    for i = 1:NUM_train
        objPotentialBoxes = predictBBoxSI(im3u{i}, base, W, NSS, numDetPerSz, T, filterW);
        for r = 1:length(objPotentialBoxes)
            bbsr = objPotentialBoxes{r};
            if isempty(bbsr), continue; end
            val = bbsr(:, 1);
            bbr = bbsr(:, 2:5);
            gtbb = gtTrainBoxes{i};
            idx = sum(interUnion(bbr, gtbb) > 0.5, 1) > 0;
            xPcell{i, r} = val(idx);
            xNcell{i, r} = val(~idx);
        end
    end

    xP = cell(1, length(szActive));
    xN = cell(1, length(szActive));
    for r = 1:length(szActive)
        xPr = xPcell(:, r); xNr = xNcell(:, r);
        pDatar = []; nDatar = [];
        for i = 1:NUM_train
            if ~isempty(xPr{i})
                xpr = xPr{i};
                pDatar = cat(1, pDatar, xpr);
            end
            xnr = xNr{i};
            nDatar = cat(1, nDatar, xnr);
        end

        xP{r} = pDatar;
        xN{r} = nDatar;
    end
    fprintf('finished.\n');

    %--------------------------------------------------------------------------
    % training stage II
    fprintf('Start training stage II ... \n');
    t2 = tic;
    svmModelII = zeros(length(szActive), 2);
    for r = 1:length(szActive)
        NUM_P = length(xP{r});
        NUM_N = length(xN{r});
        label = [ones(NUM_P, 1); -1 * ones(NUM_N, 1)];
        instance = sparse([xP{r}; xN{r}]);
        svmModel = train(label, instance, '-s 5 -c 100 -B 1');
        svmModelII(r, :) = svmModel.w';
    end
    save svmModelII.mat svmModelII

    tTrainII = toc(t2);
    fprintf('Training stage II takes %f seconds.\n\n', tTrainII);
end

function mag1f = getNGFeature(im, Boxes, W)

subIm = imcrop(im, Boxes);
subIm = imresize(subIm, [W, W], 'nearest'); % resize image patch to 8x8
mag1f = computeNormedGradient(subIm, 3 );

end

