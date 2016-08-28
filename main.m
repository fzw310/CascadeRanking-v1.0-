clear; close all; clc
addpath(genpath('./utility/'));
addpath(genpath('./mex/'));
addpath(genpath('./mat/'));
%%
datasetLabel = 1; % 1 for VOC 2007 % 2 for VOC2010 % 3 for VOC2012 % 4 for ImageNet2014
%%
cfg = default_parameters(datasetLabel);
%% get potential bounding boxes for images
[recall, objPotentialBoxes] = getObjBndBoxesForTestFast(cfg);