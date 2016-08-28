function blockLBPHist = extractLBPFeatures(im, blobIndIm, numBlobs)
%EXTRACTLBPFEATURES computes uniform local binary patterns with the consideration
% of spatial distribution of patterns
% INPUTS :
%   im :        gray image
%   blockSize : block size
% OUTPUTS:
%   features:   LBP features
%
% poppinace     2014.7.21
%

% if nargin < 2
%     blockSize = [16 16];
% end

% unipats = uniformPattern(8)';
% np = size(unipats, 1) + 1;
% map = np * ones(2 ^ 8, 1, 'single');
% map(unipats + 1) = (1:np - 1)';

% uniform pattern LUT
np = 59;
map = [1;2;3;4;5;59;6;7;8;59;59;59;9;59;10;11;12;59;59;59;59;59;59;59; ...
       13;59;59;59;14;59;15;16;17;59;59;59;59;59;59;59;59;59;59;59;59; ...
       59;59;59;18;59;59;59;59;59;59;59;19;59;59;59;20;59;21;22;23;59; ...
       59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59; ...
       59;59;59;59;59;59;59;59;59;24;59;59;59;59;59;59;59;59;59;59;59; ...
       59;59;59;59;25;59;59;59;59;59;59;59;26;59;59;59;27;59;28;29;30; ...
       31;59;32;59;59;59;33;59;59;59;59;59;59;59;34;59;59;59;59;59;59; ...
       59;59;59;59;59;59;59;59;59;35;59;59;59;59;59;59;59;59;59;59;59; ...
       59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;59;36; ...
       37;38;59;39;59;59;59;40;59;59;59;59;59;59;59;41;59;59;59;59;59; ...
       59;59;59;59;59;59;59;59;59;59;42;43;44;59;45;59;59;59;46;59;59; ...
       59;59;59;59;59;47;48;49;59;50;59;59;59;51;52;53;59;54;55;56;57;58];
im = extractLocalBinaryPattrens(im, 'P8R2'); % get LBP image
im = map(1 + im);
blockLBPHist = LBPFeatrueHistMex(im, blobIndIm, numBlobs, np);

end

% Local binary patterns 
function out = extractLocalBinaryPattrens(in, type)

[rows, cols] = size(in);

switch type
    
    case 'P8R2' % 8 pixels in a circle of radius 2
    %      o6  
    %   7o   o5
    % 0o   o   o4
    %   1o   o3
    %     2o
    % embed input matrix in a larger one, extending with zeros (trim a
    % 2 pixel border off of the output matrices if you don't like this)
    r = rows + 4; 
    c = cols + 4;
    A = zeros(r, c);
    r0 = 3:r - 2;
    c0 = 3:c - 2;
    A(r0, c0) = in;

    % radius 2 interpolation coefficients for +-45 degree lines
    alpha = single(2 - sqrt(2));
    beta = single(sqrt(2));

    % 8 directional derivative images
    d0 = A(r0, c0-2) - in;
    d2 = A(r0+2, c0) - in;
    d4 = A(r0, c0+2) - in;
    d6 = A(r0-2, c0) - in;
    d1 = alpha * A(r0+1, c0-1) + beta * A(r0+2, c0-2) - in;
    d3 = alpha * A(r0+1, c0+1) + beta * A(r0+2, c0+2) - in;
    d5 = alpha * A(r0-1, c0+1) + beta * A(r0-2, c0+2) - in;
    d7 = alpha * A(r0-1, c0-1) + beta * A(r0-2, c0-2) - in;

    % pack derivative images into a single matrix, one per column,
    % threshold and code to get output matrix
    d = [d0(:), d1(:), d2(:), d3(:), d4(:), d5(:), d6(:), d7(:)];
    code = single(2 .^ (7:-1:0)');
    out = reshape((d>=0) * code, rows, cols);

    otherwise
    error('Invalid input syntax.')
        
end

end

function output = uniformPattern(pNum)
% set up indicator table of all uniform patterns of size pnum bits
output = [];
for i = 0:2 ^ pNum-1
   BinP=zeros(1, pNum);
   temp = i;
   for j = 1:pNum
        if(floor(temp/(2 ^ (pNum - j))) > 0)
            BinP(1, j) = 1;
        end
        temp = mod(temp, 2^(pNum - j));
    end
    if isUniformPattern(BinP) == 1
        output = cat(2, output, i);
    end
end

end

function output = isUniformPattern(pattern)

count = 0;
num = size(pattern, 2);
for i = 1:num-1
    if pattern(i) ~= pattern(i + 1)
        count = count + 1;
    end
end

if count <= 2
    output = 1;
else
    output = 0;
end

end