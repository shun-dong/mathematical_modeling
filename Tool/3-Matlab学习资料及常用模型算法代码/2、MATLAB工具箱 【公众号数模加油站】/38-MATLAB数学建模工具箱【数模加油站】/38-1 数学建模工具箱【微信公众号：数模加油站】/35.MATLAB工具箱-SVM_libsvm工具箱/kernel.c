#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix_operation.h"

// �����������
#define KER prhs[0]
#define X prhs[1]
#define Y prhs[2]

// �����������
#define K plhs[0]

// ���� C ���㺯�� (�ú��������ܺͱ��ļ�������)
void KERNEL();

void 
mexFunction (int nlhs, mxArray *plhs[],			// ��������������������������
			 int nrhs, const mxArray *prhs[])	// ��������������������������
{
    int n1,d1,n2,d2;
    double *px,*py,*pk;

    // ȡ���������
	px = mxGetPr(X);
    d1 = mxGetM(X);             // ȡ�þ���X��������
    n1 = mxGetN(X);

    py = mxGetPr(Y);
    d2 = mxGetM(Y);             // ȡ�þ���Y��������
    n2 = mxGetN(Y);
    
    if (d1!=d2)
        mexErrMsgTxt("The column of two input matrix must be equal!");
    
    // Ϊ������������ڴ�ռ�
	K = mxCreateDoubleMatrix(n1,n2,mxREAL); 

	// ȡ���������ָ��
	pk = mxGetPr(K);

    // ���� C ���㺯�� (�ú��������ܺͱ��ļ�������)
    KERNEL(pk,KER,px,py,n1,n2,d1);
	return;
}

void KERNEL(double *pk,     // �������K,n1��n2�ľ���
            mxArray *pKer,  // �˲���
            double *px,     // ����X,d1��n1�ľ���
            double *py,     // ����Y,d1��n2�ľ���
            int n1,         // ����X������
            int n2,         // ����Y������
            int d1)         // ����X,Y������            
{
    int d,i,j,k,len;
    double c,s,g,*tmp[9],p=-0.5;
    mxArray *pType;
    char *kerType;
    
    // �ṹ������Ĳ�������
    if (mxIsStruct(pKer))
    {
        pType = mxGetField(pKer,0,"type"); 
        len = mxGetM(pType)*mxGetN(pType)+1;
        kerType = mxCalloc(len,sizeof(char));
        mxGetString(pType,kerType,len);         // ���˺������Ͷ����ַ���

        if (!strcmp(kerType,"linear"))
        {
            tmp[0] = mxCalloc(n1*d1,sizeof(double));
            
            mTranspose(tmp[0],px,d1,n1);
            mTimes(pk,tmp[0],n1,d1,py,d1,n2);
            
            mxFree(tmp[0]);
        }
        else if (!strcmp(kerType,"ploy"))
        {
            d = (int) mxGetScalar(mxGetField(pKer,0,"degree"));
            c = mxGetScalar(mxGetField(pKer,0,"offset"));
            
            tmp[0] = mxCalloc(n1*d1,sizeof(double));
            mTranspose(tmp[0],px,d1,n1);
            
            tmp[1] = mxCalloc(n1*n2,sizeof(double));
            mTimes(tmp[1],tmp[0],n1,d1,py,d1,n2);
            mxFree(tmp[0]);
            
            tmp[2] = mxCalloc(n1*n2,sizeof(double));
            mPlus(tmp[2],tmp[1],n1,n2,&c,1,1);
            mxFree(tmp[1]);            
            
            mPower(pk,tmp[2],n1,n2,(double)d);
            mxFree(tmp[2]);
        }
        else if (!strcmp(kerType,"gauss"))
        {
            s = mxGetScalar(mxGetField(pKer,0,"width"));     
            
            tmp[0] = mxCalloc(n1*n2,sizeof(double));
            tmp[1] = mxCalloc(d1*1,sizeof(double));
            tmp[2] = mxCalloc(d1*1,sizeof(double));
            tmp[3] = mxCalloc(d1*1,sizeof(double));            
            tmp[4] = mxCalloc(1,sizeof(double));            
            
            for (i=0;i<n1;i++)
                for (j=0;j<n2;j++)
                {
                    mGetCol(tmp[1],px,d1,n1,i);
                    mGetCol(tmp[2],py,d1,n2,j);
                    mMinus(tmp[3],tmp[1],d1,1,tmp[2],d1,1);
                    mNorm(tmp[4],tmp[3],d1,1);
                    mSetElement(tmp[0],n1,n2,i,j,*tmp[4]);
                }
                
            mxFree(tmp[1]);
            mxFree(tmp[2]);
            mxFree(tmp[3]);
            mxFree(tmp[4]);            
                
            //mPrint("tmp",tmp[0],n1,n2);                

            tmp[5] = mxCalloc(n1*n2,sizeof(double));
            mRDivide(tmp[5],tmp[0],n1,n2,&s,1,1);   
            mxFree(tmp[0]);
            
            tmp[6] = mxCalloc(n1*n2,sizeof(double));
            mPower(tmp[6],tmp[5],n1,n2,2);
            mxFree(tmp[5]);

            tmp[7] = mxCalloc(n1*n2,sizeof(double));            
            mPTimes(tmp[7],tmp[6],n1,n2,&p,1,1);
            mxFree(tmp[6]);
            
            mExp(pk,tmp[7],n1,n2);
            mxFree(tmp[7]);            
            
            //mPrint("K",pk,n1,n2);
        }
        else if  (!strcmp(kerType,"tanh"))
        {
            g = mxGetScalar(mxGetField(pKer,0,"gamma")); 
            c = mxGetScalar(mxGetField(pKer,0,"offset"));
            
            tmp[0] = mxCalloc(n1*d1,sizeof(double));
            mTranspose(tmp[0],px,d1,n1);
            
            tmp[1] = mxCalloc(n1*n2,sizeof(double));
            mTimes(tmp[1],tmp[0],n1,d1,py,d1,n2);
            mxFree(tmp[0]);
            
            tmp[2] = mxCalloc(n1*n2,sizeof(double));            
            mTimes(tmp[2],tmp[1],n1,n2,&g,1,1);
            mxFree(tmp[1]);
            
            tmp[3] = mxCalloc(n1*n2,sizeof(double));                        
            mPlus(tmp[3],tmp[2],n1,n2,&c,1,1);
            mxFree(tmp[2]);            
            
            mTanh(pk,tmp[3],n1,n2);
            mxFree(tmp[3]);            
        }
        mxFree(kerType);
    }
}

