function [recall, objPotentialBoxes] = getObjBndBoxesForTestFast( cfg )

colorType = 'Hsv';
simFunctionHandles = {@SSSimColourTextureSizeFillOrig,@SSSimBoxFillOrig, @SSSimSize}; 
minBoxWidth = 12;
NUM_test = length(cfg.testStruct);
gtTestBoxes = cell(1, NUM_test); 
objPotentialBoxes = cell(1, NUM_test);
tStart = tic;
parfor i = 1:NUM_test    
    [im, objBoxes] = initalData(cfg.testStruct(i), cfg.datasetPath, cfg.datasetLabel); 
    [imRow,imCol,~] = size(im); 
    if imRow>=1024 || imCol>=1024, continue; end  % Remove 968 images from ILSVRC test set. The big images can be resized for application.
    if size(objBoxes,1) == 0,continue;end % Remove the images whose GTs are all denoted as 'difficult'
    gtTestBoxes{i} = objBoxes;
    % objectness test main program
    if mod(i, 500) == 0, fprintf('    current processed %d images\n', i);end
    %% %%%%%%%%%%%%%%%FIRST RANKING%%%%%%%%%%%%%%%%%%%%%%
    [Colorboxes,blobIndIm,numBlobs,~,colourHist,blobSizes,~,~,~] = Image2HierarchicalGrouping(im, cfg.sigma, cfg.k, cfg.minSize, colorType, simFunctionHandles);
    Colorboxes = BoxRemoveDuplicates(Colorboxes);%x1,y1,x2,y2
    Colorboxes = FilterBoxesWidth(Colorboxes, minBoxWidth);%remove the block which is smaller than minBoxWidth
    ColorboxesRec = [Colorboxes(:,2), Colorboxes(:,1), Colorboxes(:,4)-Colorboxes(:,2)+1, Colorboxes(:,3)-Colorboxes(:,1)+1];%c1,r1,w,h
    ColorboxesRecLayerW = power(2, (floor(log2(ColorboxesRec(:, 3))) +...
        floor((ColorboxesRec(:, 3)-power(2, (floor(log2(ColorboxesRec(:, 3)))))) ./ power(2, (floor(log2(ColorboxesRec(:, 3))) - 1)))));%w
    ColorboxesRecLayerH = power(2, (floor(log2(ColorboxesRec(:, 4))) +...
        floor((ColorboxesRec(:, 4)-power(2, (floor(log2(ColorboxesRec(:, 4)))))) ./ power(2, (floor(log2(ColorboxesRec(:, 4))) - 1)))));%h
    
    ColorboxesRecLayerR = (log2(ColorboxesRecLayerH) - cfg.BING.T.minT) * cfg.BING.T.numT + (log2(ColorboxesRecLayerW) - cfg.BING.T.minT);
    ColorboxesRecLayerIdx = ColorboxesRecLayerR;
    for j = length(cfg.BING.sizeActive):-1:1
        ColorboxesRecLayerIdx(ColorboxesRecLayerR == cfg.BING.sizeActive(j)) = j;
    end
    ColorboxesRecLayerIdxHist = [];
    for j = 1:length(cfg.BING.sizeActive)
        ColorboxesRecLayerIdxHist = [ColorboxesRecLayerIdxHist,sum(ColorboxesRecLayerIdx == j)];
    end
    
    objPotentialBoxes{i} =  getObjBndBoxes(im, cfg.BING, ColorboxesRecLayerIdxHist);
    %% %%%%%%%%%%%SECOND RANKING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %feature blocks (NG and color&context) fusing
    ratio = reshape(interUnionMex(objPotentialBoxes{i}(:, 2:5), ColorboxesRec), size(ColorboxesRec,1), size(objPotentialBoxes{i},1));
    [ratioMax, MaxIdx] = max(ratio); %obtain maxism overlapping rate
    %change the window by overlapping rate
    tmpobjPotentialBox = [objPotentialBoxes{i}(:,3), objPotentialBoxes{i}(:,2), objPotentialBoxes{i}(:,5)+objPotentialBoxes{i}(:,3)-1, objPotentialBoxes{i}(:,4)+objPotentialBoxes{i}(:,2)-1];%x1,y1,x2,y2
    tmpColorboxesRec = Colorboxes(:, 1:4);%x1,y1,x2,y2
    tmpColorboxesRec = tmpColorboxesRec(MaxIdx,:);
    tmpobjPotentialBox = floor(tmpobjPotentialBox + [ratioMax',ratioMax',ratioMax',ratioMax'].*(tmpColorboxesRec-tmpobjPotentialBox));
    objPotentialBoxes{i}(:,2:5) = [tmpobjPotentialBox(:,2), tmpobjPotentialBox(:,1), tmpobjPotentialBox(:,4)-tmpobjPotentialBox(:,2)+1, tmpobjPotentialBox(:,3)-tmpobjPotentialBox(:,1)+1];
    objPotentialBoxes{i}(:,1) = (objPotentialBoxes{i}(:,1) - min(objPotentialBoxes{i}(:,1)))/(max(objPotentialBoxes{i}(:,1))- min(objPotentialBoxes{i}(:,1)));
    objPotentialBoxes{i}(:,1) = objPotentialBoxes{i}(:,1) .* ratioMax';
    objPotentialBoxes{i} = -sortrows(-objPotentialBoxes{i}, 1);
    
    %%%%%%%%%%%%%%end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    objPotentialBoxes{i} = objPotentialBoxes{i}(:, 2:5);
    %% %%%%%%%%%%%%%%%THIRD RANKING%%%%%%%%%%%%%%%%%%%%%%%%
    SalienceNum = min(105, length(objPotentialBoxes{i}));
    SalienceWindow = zeros(SalienceNum, 5);
    xmin = objPotentialBoxes{i}(1:SalienceNum, 1);
    ymin = objPotentialBoxes{i}(1:SalienceNum, 2);
    xmax = objPotentialBoxes{i}(1:SalienceNum, 3) + objPotentialBoxes{i}(1:SalienceNum, 1) - 1;
    ymax = objPotentialBoxes{i}(1:SalienceNum, 4) + objPotentialBoxes{i}(1:SalienceNum, 2) - 1;
    score = zeros(SalienceNum, 1);
    for n = 1 : SalienceNum
        intersection = blobIndIm(ymin(n):ymax(n), xmin(n):xmax(n));
        [area, Label] = hist(intersection(:), 1:numBlobs);
        Label(area == 0) = [];
        area = area(Label);
        areasize = blobSizes(Label)';
        rate = area./areasize;
        inLabel = Label(rate >= 1);
        inSize = blobSizes(inLabel, :);
        inHist = sum(colourHist(inLabel, :) .* repmat(blobSizes(inLabel, :), 1, size(colourHist(inLabel, :), 2)), 1)...
            /sum(inSize);
        outLabel = Label(rate < 1);
        outSize = blobSizes(outLabel, :);
        outHist = sum(colourHist(outLabel, :) .* repmat(blobSizes(outLabel, :), 1, size(colourHist(outLabel, :), 2)), 1)...
            /sum(outSize);
        score(n) = 1 - sum(bsxfun(@min, outHist, inHist));
        
    end;
    SalienceWindow(1:SalienceNum, 1:4) = objPotentialBoxes{i}(1:SalienceNum, :);
    SalienceWindow(1:SalienceNum, 5) = score;
    
    SalienceStart = 1;
    SalienceVec = [5,10,15,25,40,65,SalienceNum];
    for s = 1:length(SalienceVec)
        if(SalienceVec(s) <= 2*SalienceStart),break;end
        SalienceEnd = SalienceVec(s);
        SalienceWindow(SalienceStart:SalienceEnd, :) = -sortrows(-SalienceWindow(SalienceStart:SalienceEnd, :), 5);
        SalienceStart = round(SalienceVec(s) / 2);
    end
    objPotentialBoxes{i} = [SalienceWindow(:,1:4); objPotentialBoxes{i}(SalienceNum+1:end, :)];
    %the first window
    RRankNum = 1;
    score = zeros(1, RRankNum);
    for j = 1 : RRankNum
        mag = getNGFeature(im, objPotentialBoxes{i}(j, :), cfg.BING.W);
        score(j) = dotMex(mag, cfg.BING.filter1W);
    end
    [MaxScore ,idx] = max(score);
    objPotentialBoxes{i} = [objPotentialBoxes{i}(idx, :); objPotentialBoxes{i}(1:idx-1, :); objPotentialBoxes{i}(idx+1:end, :)];
    
    midRec = [floor(imCol/8), floor(imRow/8), floor(imCol*3/4), floor(imRow*3/4)];
    
    mag1 = getNGFeature(im, midRec, cfg.BING.W);
    scoremid = dotMex(mag1, cfg.BING.filter1W);
    
    if scoremid*1.5 > MaxScore
        objPotentialBoxes{i} = [midRec; objPotentialBoxes{i}];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

tValue = toc(tStart);
fprintf('Average time for predicting an image is %f seconds.\n', tValue / NUM_test);
[recall,~,~] = evaluatePerImgRecall(objPotentialBoxes, gtTestBoxes, 10000 , NUM_test);
end

function mag1f = getNGFeature(im, Boxes, W)
subIm = imcrop(im, Boxes);
subIm = imresize(subIm, [W, W], 'nearest'); 
mag1f = computeNormedGradient(subIm, 3 );
end

