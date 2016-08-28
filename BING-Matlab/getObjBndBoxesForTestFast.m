function getObjBndBoxesForTestFast( VOCPath, annoStruct, base, W, NSS, numDetPerSz, T, parStartflag )
%GETOBJBNDBOXESFORTESTFAST get potential bounding boxes for images
%

%--------------------------------------------------------------------------
%%training the svmModel of BingObjectness, next line can be commented if models were trained
trainObjectness(VOCPath, annoStruct, base, W, NSS, numDetPerSz, T, parStartflag);
filterW = loadTrainedModel(W);
%--------------------------------------------------------------------------
% evaluate algorithm on testset
% preload images and ground truth boxes on testset
fprintf('Start predicting ...\n')
IDX_testObj = dlmread('test.txt');
testStruct = annoStruct(IDX_testObj);

% NUM_test = 200; % for debugging use
NUM_test = length(IDX_testObj);

gtTestBoxes = cell(1, NUM_test);
objPotentialBoxes = cell(1, NUM_test);
tStart = tic;
if parStartflag
    parfor i = 1:NUM_test
        fileName = testStruct(i).annotation.filename;
        im = imread(fullfile(VOCPath, fileName)); % load image

        object = testStruct(i).annotation.object;
        objBoxes = [];
        for j = 1:length(object)
            if str2double(object(j).difficult), continue; end
            box = object(j).bndbox;
            xmin = str2double(box.xmin);
            xmax = str2double(box.xmax);
            ymin = str2double(box.ymin);
            ymax = str2double(box.ymax);
            objBox = [xmin, ymin, xmax - xmin + 1, ymax - ymin + 1]; % [x, y, width, length]
            objBoxes = cat(1, objBoxes, objBox);
        end
        gtTestBoxes{i} = objBoxes;

        % objectness test main program
        if mod(i, 500) == 0, fprintf('    current processed %d images\n', i);end
        objPotentialBoxes{i} = getObjBndBoxes(im, base, W, NSS, numDetPerSz, T, filterW );
    end
else
    for i = 1:NUM_test
        disp(i);
        fileName = testStruct(i).annotation.filename;
        im = imread(fullfile(VOCPath, fileName)); % load image

        object = testStruct(i).annotation.object;
        objBoxes = [];
        for j = 1:length(object)
            if str2double(object(j).difficult), continue; end
            box = object(j).bndbox;
            xmin = str2double(box.xmin);
            xmax = str2double(box.xmax);
            ymin = str2double(box.ymin);
            ymax = str2double(box.ymax);
            objBox = [xmin, ymin, xmax - xmin + 1, ymax - ymin + 1]; % [x, y, width, length]
            objBoxes = cat(1, objBoxes, objBox);
        end
        gtTestBoxes{i} = objBoxes;

        % objectness test main program
        if mod(i, 500) == 0, fprintf('    current processed %d images\n', i);end
        objPotentialBoxes{i} = getObjBndBoxes(im, base, W, NSS, numDetPerSz, T, filterW );
    end    
end

tValue = toc(tStart);
fprintf('Average time for predicting an image is %f seconds.\n', tValue / NUM_test);

%--------------------------------------------------------------------------
% output performace index - recall
[~,~,BestLocation] = evaluatePerImgRecall(objPotentialBoxes, gtTestBoxes, 5000 , NUM_test);

% drawBox(BestLocation, VOCPath, testStruct, NUM_test);

end

