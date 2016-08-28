#include "mex.h"
#include <math.h>
#include <malloc.h>
#include <stdio.h>
#include "stdlib.h"

void Hist(double **FeatureMap, double **blobIndMap, int row, int col, int BlockNum, int FeatureDimension, double **FeatureHist)
{
	int i = 0, j = 0;
	double **Block = (double **)malloc(sizeof(double*)*BlockNum);
    for(i = 0; i < BlockNum; i++)
         Block[i] = (double *)malloc(sizeof(double)*col*row);

	double *BlockCnt = (double *)malloc(sizeof(double)*BlockNum);

	for(i = 0 ; i < BlockNum; i++)
		BlockCnt[i] = 0;

	for(i = 0 ; i < row; i++)
	{
		for(j = 0 ; j < col; j++)
		{
			Block[(int)(blobIndMap[i][j])][(int)(BlockCnt[(int)(blobIndMap[i][j])])] = FeatureMap[i][j];
			BlockCnt[(int)(blobIndMap[i][j])] ++;
		}
	}

	for(i = 0 ; i < BlockNum; i++)
	{
		for(j = 0 ; j < BlockCnt[i]; j++)
		{
			FeatureHist[i][(int)(Block[i][j])]++;
		}
		BlockCnt[i] = 0;
	}

	for (i = 0; i < BlockNum; i++)
	{
		for (j = 1; j < FeatureDimension-1; j++)
		{
			BlockCnt[i] += FeatureHist[i][j];
		}
	}

	for(i = 0 ; i < BlockNum; i++)
	{
		for(j = 0 ; j < FeatureDimension; j++)
		{
			FeatureHist[i][j] = FeatureHist[i][j] / BlockCnt[i];
		}
	}

	for(i = 0; i < BlockNum;i++)
		free(Block[i]);
	free(Block);

	free(BlockCnt);
}

void mexFunction(int nout, mxArray *out[], 	int nin, const mxArray *in[])
{
	int col = mxGetN(in[0]);
	int row = mxGetM(in[0]);
	double *LBPFeature = mxGetPr(in[0]);
	double *blobInd = mxGetPr(in[1]);

	double BlockNum = *(double*)mxGetPr(in[2]);
	double FeatureDimension = *(double*)mxGetPr(in[3]);
	int i,j;

	double **FeatureHist = (double **)malloc(sizeof(double*)*BlockNum);
    for(i = 0; i < BlockNum; i++)
         FeatureHist[i] = (double *)malloc(sizeof(double)*FeatureDimension);

	double **FeatureMap = (double **)malloc(sizeof(double*)*row);
    for(i = 0; i < row; i++)
         FeatureMap[i] = (double *)malloc(sizeof(double)*col);

	double **blobIndMap = (double **)malloc(sizeof(double*)*row);
    for(i = 0; i < row; i++)
         blobIndMap[i] = (double *)malloc(sizeof(double)*col);


	double *res = NULL;

	for (i=0;i<BlockNum ;i++)
	{
		for (j=0;j<FeatureDimension;j++)
		{
			FeatureHist[i][j] = 0;
		}
	}

	for (i=0;i<row ;i++)
	{
		for (j=0;j<col;j++)
		{
			blobIndMap[i][j] = blobInd[i+j*row]-1;
			FeatureMap[i][j] = LBPFeature[i+j*row]-1;
		}
	}


	Hist(FeatureMap, blobIndMap, row, col, BlockNum, FeatureDimension, FeatureHist);

	out[0] =  mxCreateDoubleMatrix(BlockNum,FeatureDimension-2,mxREAL);
	res = mxGetPr(out[0]);
	for(i = 0 ; i < BlockNum; i++)
	{
		for(j = 1; j < FeatureDimension-1;j++)
		{
			*(res + i + (j - 1)*int(BlockNum)) = FeatureHist[i][j];
		}
	}
	for(i = 0; i < BlockNum;i++)
		free(FeatureHist[i]);
	free(FeatureHist);

	for(i = 0; i < row;i++)
		free(FeatureMap[i]);
	free(FeatureMap);
return;		
}