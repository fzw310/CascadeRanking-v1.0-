% main_ObjectnessBING
%

clear; close all; clc


parStartflag = 0;

% initialize matlab parallel computing environment
if parStartflag
    if matlabpool('size') <= 0
       parpool('local')
    else
       disp('parpool already initialized.') 
    end
end


%--------------------------------------------------------------------------
% parameter setting
base = 2;
W = 8;
NSS = 2;
numPerSz = 130;

T.logBase = log(base);
T.minT = ceil(log(10) / T.logBase);
T.maxT = ceil(log(500) / T.logBase);
T.numT = T.maxT - T.minT + 1;

% path seting
root = 'F:\公共数据库\pascal 2007\VOC2007';
% annotationsFolder = 'Annotations';
VOCFolder = 'JPEGImages';
% txtResFolder = 'txtRes';

%--------------------------------------------------------------------------
load annoStruct2007 
fprintf('Load annotations ... ')
% annotationsPath = fullfile(root, annotationsFolder);
% annoStruct = loadAnnotations(annotationsPath);
% save annoStruct

fprintf('finished. \n')

%--------------------------------------------------------------------------
% get potential bounding boxes for images
VOCPath = fullfile(root, VOCFolder);
getObjBndBoxesForTestFast(VOCPath, annoStruct, base, W, NSS, numPerSz, T, parStartflag);


% matlabpool close
if parStartflag
    delete(gcp)
end


