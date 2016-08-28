#include "mex.h"
#include <math.h>
#include <malloc.h>
#include <stdio.h>
#include "stdlib.h"


#define min(a,b) a<b?a:b
#define max(a,b) a>b?a:b
void interUnio(double *potentialBox,int r1,double *colorBox,int r2,double *res)
{
	unsigned int i=0,j=0;
	unsigned int m=0,n=0;
	double bi[4], bb1[4], bb2[4];
	double iw, ih, ov, ua;

	for(i = 0; i < r1; i++)
		for(j = 0; j < r2; j++)
		{
			bb1[0] = potentialBox[i*4];
			bb1[1] = potentialBox[i*4 + 1];
			bb1[2] = potentialBox[i*4 + 2] + potentialBox[i*4] - 1;
			bb1[3] = potentialBox[i*4 + 3] + potentialBox[i*4 + 1] - 1;

			bb2[0] = colorBox[j*4];
			bb2[1] = colorBox[j*4 + 1];
			bb2[2] = colorBox[j*4 + 2] + colorBox[j*4] - 1;
			bb2[3] = colorBox[j*4 + 3] + colorBox[j*4 + 1] - 1;

			bi[0] = max(bb1[0], bb2[0]);
			bi[1] = max(bb1[1], bb2[1]);
			bi[2] = min(bb1[2], bb2[2]);
			bi[3] = min(bb1[3], bb2[3]);	

			iw = bi[2] - bi[0] + 1;
			ih = bi[3] - bi[1] + 1;
			ov = 0;
			if (iw>0 && ih>0){
				ua = (bb1[2]-bb1[0]+1)*(bb1[3]-bb1[1]+1)+(bb2[2]-bb2[0]+1)*(bb2[3]-bb2[1]+1)-iw*ih;
				ov = iw*ih/ua;
			}
			else
			{
				ov = 0;
			}
			res[i * r2 + j] = ov;
		}

}

void mexFunction(int nout, mxArray *out[], 	int nin, const mxArray *in[])
{
	int col1 = mxGetN(in[0]);
	int row1 = mxGetM(in[0]);
	int col2 = mxGetN(in[1]);
	int row2 = mxGetM(in[1]);

	double *Box1 = mxGetPr(in[0]);//objPotentialBox
	double *Box2 = mxGetPr(in[1]);//colorBoxes

	int i,j;

	double *potentialBox = (double*)calloc(row1*col1,sizeof(double));
	double *colorBox = (double*)calloc(row2*col2,sizeof(double));

	double *res = NULL;

	for (i=0;i<row1 ;i++)
	{
		for (j=0;j<col1;j++)
		{
			potentialBox[i*col1+j] = Box1[i+j*row1];
		}
	}
	for (i=0;i<row2 ;i++)
	{
		for (j=0;j<col2;j++)
		{
			colorBox[i*col2+j] = Box2[i+j*row2];
		}
	}

	out[0] =  mxCreateDoubleMatrix(row1*row2,1,mxREAL);
	res = mxGetPr(out[0]);
	interUnio(potentialBox,row1,colorBox,row2,res);
	free(potentialBox);
	potentialBox = NULL;
	free(colorBox);
	colorBox = NULL;
return;		
}