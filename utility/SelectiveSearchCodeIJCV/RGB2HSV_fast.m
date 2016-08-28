function [colourIm imageToSegment] = RGB2HSV_fast(im)
maxRGB = max(im(:,:,1),im(:,:,2),im(:,:,3));
minRGB = min(im(:,:,1),im(:,:,2),im(:,:,3));
end