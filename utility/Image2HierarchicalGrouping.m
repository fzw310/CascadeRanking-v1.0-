function [boxes blobIndIm numBlobs colourIm colourHist blobSizes blobBoxes hierarchy priority] = Image2HierarchicalGrouping(im, sigma, k, minSize, colourType, functionHandles)
% function [boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping
%                              (im, sigma, k, minSize, colourType, functionHandles)
%
% Creates hierarchical grouping from an image
%
% im:                   Image
% sigma (= 0.8):        Smoothing for initial segmentation (Felzenszwalb 2004)
% k (= 100):            Threshold for initial segmentation
% minSize (= 100):      Minimum size of segments for initial segmentation
% colourType:           ColourType in which to do grouping (see Image2ColourSpace)
% functionHandles:      Similarity functions which are called. Function
%                       creates as many hierarchies as there are functionHandles
%
% boxes:                N x 4 array with boxes of all hierarchical groupings
% blobIndIm:            Index image with the initial segmentation
% blobBoxes:            Boxes belonging to the indices in blobIndIm
% hierarchy:            M x 1 cell array with hierarchies. M =
%                       length(functionHandles)
%
%     Jasper Uijlings - 2013
% Change colour space
[colourIm imageToSegment] = Image2ColourSpace(im, colourType);
[blobIndIm blobBoxes neighbours] = mexFelzenSegmentIndex(imageToSegment, sigma, k, minSize);

numBlobs = size(blobBoxes,1);
% Skip hierarchical grouping if segmentation results in single region only
if numBlobs == 1
    warning('Oversegmentation results in a single region only');
    boxes = blobBoxes;
    hierarchy = [];
    priority = 1; % priority is legacy
    return;
end

%%% Calculate histograms and sizes as prerequisite for grouping procedure

% Get colour histogram
[colourHist blobSizes] = BlobStructColourHist(blobIndIm, colourIm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
localContrast = zeros(length(blobBoxes), 1);

% Get texture histogram
textureHist = extractLBPFeatures(colourIm(:,:,1), blobIndIm, numBlobs);

% Allocate memory for complete hierarchy.
blobStruct.colourHist = zeros(size(colourHist,2), numBlobs * 2 - 1);
blobStruct.textureHist = zeros(size(textureHist,2), numBlobs * 2 - 1);
blobStruct.size = zeros(numBlobs * 2 -1, 1);
blobStruct.boxes = zeros(numBlobs * 2 - 1, 4);
%%%%%%%%%%%%%%%%%%
blobStruct.sim = zeros(numBlobs * 2 -1, 1);
%%%%%%%%%%%%%%%%%%
% Insert calculated histograms, sizes, and boxes
blobStruct.colourHist(:,1:numBlobs) = colourHist';
blobStruct.textureHist(:,1:numBlobs) = textureHist';
blobStruct.size(1:numBlobs) = blobSizes ./ 3;
blobStruct.boxes(1:numBlobs,:) = blobBoxes;


blobStruct.imSize = size(im,1) * size(im,2);

% Loop over all merging strategies. Perform them one by one.
boxes = cell(1, length(functionHandles)+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim = cell(1, length(functionHandles)+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
priority = cell(1, length(functionHandles) + 1);
hierarchy = cell(1, length(functionHandles));
for i=1:length(functionHandles)
    [boxes{i}, sim{i},~,~,~] = BlobStruct2HierarchicalGrouping(blobStruct, neighbours, numBlobs, functionHandles{i});
    boxes{i} = boxes{i}(numBlobs+1:end,:);
    priority{i} = (size(boxes{i}, 1):-1:1)';
end

% Also save the initial boxes
i = i+1;boxes{i} = blobBoxes;
% Concatenate boxes and priorities resulting from the different merging
% strategies
boxes = cat(1, boxes{:});
