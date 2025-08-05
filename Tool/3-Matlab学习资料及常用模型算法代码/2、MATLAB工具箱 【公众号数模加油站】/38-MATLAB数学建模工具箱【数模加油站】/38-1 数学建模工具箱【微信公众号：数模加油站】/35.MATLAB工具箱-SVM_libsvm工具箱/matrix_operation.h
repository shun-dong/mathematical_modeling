#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"

//----------------------------------------------------------
// �������

void mTimes(double *pc,
            double *pa,
            int ra,
            int ca,
            double *pb,
            int rb,
            int cb)
{
    int i,j,k;
    double tmp;
    
    if (ca==rb)
    {
        for (j=0;j<cb;j++)
            for (i=0;i<ra;i++)
            {
                tmp = 0;
                for (k=0;k<ca;k++)
                    tmp = tmp + pa[k*ra+i]*pb[j*ca+k];
                pc[j*ra+i] = tmp;
            }
    }
    else if (ra==1 && ca==1)
    {
        for (j=0;j<cb;j++)
            for (i=0;i<rb;i++)
                pc[j*rb+i] = pa[0]*pb[j*rb+i];
    }
    else if (rb==1 && cb==1)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pa[j*ra+i]*pb[0];
    }
    else
        mexErrMsgTxt("A dimension error occured in function \"mTimes\"\n"); 
}

//----------------------------------------------------------
// ������

void mPTimes(double *pc,
             double *pa,
             int ra,
             int ca,
             double *pb,
             int rb,
             int cb)
{
    int i,j;
    
    if (ra==rb && ca==cb)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pa[j*ra+i]*pb[j*ra+i];
    }
    else if (ra==1 && ca==1)
    {
        for (j=0;j<cb;j++)
            for (i=0;i<rb;i++)
                pc[j*rb+i] = pa[0]*pb[j*rb+i];
    }
    else if (rb==1 && cb==1)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pb[0]*pa[j*ra+i];
    }
    else
        mexErrMsgTxt("A dimension error occured in function \"mPTimes\"\n"); 
}

//----------------------------------------------------------
// �������

void mPlus(double *pc,
           double *pa,
           int ra,
           int ca,
           double *pb,
           int rb,
           int cb)
{
    int i,j;
    
    if (ra==rb && ca==cb)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pa[j*ra+i]+pb[j*ra+i];
    }
    else if (ra==1 && ca==1)
    {
        for (j=0;j<cb;j++)
            for (i=0;i<rb;i++)
                pc[j*rb+i] = pa[0]+pb[j*rb+i];
    }
    else if (rb==1 && cb==1)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pb[0]+pa[j*ra+i];
    }
    else
        mexErrMsgTxt("A dimension error occured in function \"mPlus\"\n"); 
}

//----------------------------------------------------------
// �������

void mMinus(double *pc,
           double *pa,
           int ra,
           int ca,
           double *pb,
           int rb,
           int cb)
{
    int i,j;
    
    if (ra==rb && ca==cb)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pa[j*ra+i]-pb[j*ra+i];
    }
    else if (ra==1 && ca==1)
    {
        for (j=0;j<cb;j++)
            for (i=0;i<rb;i++)
                pc[j*rb+i] = pa[0]-pb[j*rb+i];
    }
    else if (rb==1 && cb==1)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pb[0]-pa[j*ra+i];
    }
    else
        mexErrMsgTxt("A dimension error occured in function \"mMinus\"\n"); 
}

//----------------------------------------------------------
// �������ҳ�

void mRDivide(double *pc,
              double *pa,
              int ra,
              int ca,
              double *pb,
              int rb,
              int cb)
{
    int i,j;
    
    if (ra==rb && ca==cb)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pa[j*ra+i]/pb[j*ra+i];
    }
    else if (ra==1 && ca==1)
    {
        for (j=0;j<cb;j++)
            for (i=0;i<rb;i++)
                pc[j*rb+i] = pa[0]/pb[j*rb+i];
    }
    else if (rb==1 && cb==1)
    {
        for (j=0;j<ca;j++)
            for (i=0;i<ra;i++)
                pc[j*ra+i] = pa[j*ra+i]/pb[0];
    }
    else
        mexErrMsgTxt("A dimension error occured in function \"mRDivide\"\n"); 
}

//----------------------------------------------------------
// ����Ԫ�ص��ݴη�

void mPower(double *pb,
            double *pa,
            int ra,
            int ca,
            double e)
{
    int i,j;
    for (j=0;j<ca;j++)
        for (i=0;i<ra;i++)
            pb[j*ra+i] = pow(pa[j*ra+i],e);
}

//----------------------------------------------------------
// ����ת��

void mTranspose(double *pb,
                double *pa,
                int ra,
                int ca)
{
    int i,j;
    for (j=0;j<ra;j++)
        for (i=0;i<ca;i++)
            pb[j*ca+i] = pa[i*ra+j];
}

//----------------------------------------------------------
// ������eΪ�׵�ָ��

void mExp(double *pb,
          double *pa,
          int ra,
          int ca)
{
    int i,j;
    for (j=0;j<ca;j++)
        for (i=0;i<ra;i++)
            pb[j*ra+i] = exp(pa[j*ra+i]);
}

//----------------------------------------------------------
// ����Ԫ�ص�tanh����

void mTanh(double *pb,
           double *pa,
           int ra,
           int ca)
{
    int i,j;
    for (j=0;j<ca;j++)
        for (i=0;i<ra;i++)
            pb[j*ra+i] = tanh(pa[j*ra+i]);
}

//----------------------------------------------------------
// ȡ�þ���a��j��

void mGetCol(double *pb,
             double *pa,
             int ra,
             int ca,
             int j)
{
    int i;
    if (j>=0 && j<ca)
    {
        for (i=0;i<ra;i++)
            pb[i] = pa[j*ra+i];
    }
    else
        mexErrMsgTxt("The column index exceed its limit in function \"mGetCol\"\n"); 
}

//----------------------------------------------------------
// ȡ�þ���a��i��

void mGetRow(double *pb,
             double *pa,
             int ra,
             int ca,
             int i)
{
    int j;
    if (i>=0 && i<ra)
    {
        for (j=0;j<ca;j++)
            pb[j] = pa[j*ra+i];
    }
    else
        mexErrMsgTxt("The row index exceed its limit in function \"mGetRow\"\n"); 
}

//----------------------------------------------------------
// ���þ���a��j��

void mSetCol(double *pa,
             int ra,
             int ca,
             int j,
             double *pb)
{
    int i;
    if (j>=0 && j<ca)
    {
        for (i=0;i<ra;i++)
            pa[j*ra+i] = pb[i];
    }
    else
        mexErrMsgTxt("The column index exceed its limit in function \"mSetCol\"\n"); 
}

//----------------------------------------------------------
// ���þ���a��i��

void mSetRow(double *pa,
             int ra,
             int ca,
             int i,
             double *pb)
{
    int j;
    if (i>=0 && i<ra)
    {
        for (j=0;j<ca;j++)
            pa[j*ra+i] = pb[j];
    }
    else
        mexErrMsgTxt("The row index exceed its limit in function \"mSetRow\"\n"); 
}

//----------------------------------------------------------
// ȡ�þ���a��j1��j2��

void mGetCols(double *pb,
              double *pa,
              int ra,
              int ca,
              int j1,
              int j2)
{
    int i,j;
    
    if (j1>=0 &&  j1<=j2 && j2<ca)
    {
        for (j=j1;j<=j2;j++)    
            for (i=0;i<ra;i++)
                pb[(j-j1)*ra+i] = pa[j*ra+i];
    }
    else
        mexErrMsgTxt("The column index exceed its limit in function \"mGetCols\"\n"); 
}

//----------------------------------------------------------
// ���þ���a��j1��j2��

void mSetCols(double *pa,
              int ra,
              int ca,
              int j1,
              int j2,
              double *pb)
{
    int i,j;
    
    if (j1>=0 &&  j1<=j2 && j2<ca)
    {
        for (j=j1;j<=j2;j++)    
            for (i=0;i<ra;i++)
                pa[j*ra+i] = pb[(j-j1)*ra+i];
    }
    else
        mexErrMsgTxt("The column index exceed its limit in function \"mSetCols\"\n"); 
}

//----------------------------------------------------------
// ������ȡ�þ���a��������

void mGetIndexCols(double *pb,
                   double *pa,
                   int ra,
                   int ca,
                   int *pIndex,
                   int len)
{
    int i,j,j_index;
    
    for (j=0;j<len;j++)    
    {
        j_index = pIndex[j];
        if (j_index>=0 && j_index<ca)
            for (i=0;i<ra;i++)
                pb[j*ra+i] = pa[j_index*ra+i];
        else
            mexErrMsgTxt("The column index exceed its limit in function \"mGetIndexCols\"\n"); 
    }
}

//----------------------------------------------------------
// �������õþ���a��������

void mSetIndexCols(double *pa,
                   int ra,
                   int ca,
                   int *pIndex,
                   int len,
                   double *pb)
{
    int i,j,j_index;
    
    for (j=0;j<len;j++)    
    {
        j_index = pIndex[j];
        if (j_index>=0 && j_index<ca)
            for (i=0;i<ra;i++)
                pa[j_index*ra+i] = pb[j*ra+i];
        else
            mexErrMsgTxt("The column index exceed its limit in function \"mSetIndexCols\"\n"); 
    }
}

//----------------------------------------------------------
// �Ծ���ÿһ��ȡ������,�����������,ֱ���������

void mNorm(double *pb,
           double *pa,
           int ra,
           int ca)
{
    int i,j;
    double tmp;
    
    if (ra==1)
    {
        tmp = 0;
        for (j=0;j<ca;j++)    
            tmp = tmp + pa[j]*pa[j];
        *pb = sqrt(tmp);    
    }
    else
        for (j=0;j<ca;j++)    
        {
            tmp = 0;
            for (i=0;i<ra;i++)
                tmp = tmp + pa[j*ra+i]*pa[j*ra+i];        
            pb[j] = sqrt(tmp);            
        }
}

//----------------------------------------------------------
// �Ծ���ÿһ��ȡ��ֵ,�����������,ֱ�������ֵ

void mMean(double *pb,
           double *pa,
           int ra,
           int ca)
{
    int i,j;
    double tmp;
    
    if (ra==1)
    {
        tmp = 0;
        for (j=0;j<ca;j++)    
            tmp = tmp + pa[j];
        *pb = tmp/ca;    
    }
    else
        for (j=0;j<ca;j++)    
        {
            tmp = 0;
            for (i=0;i<ra;i++)
                tmp = tmp + pa[j*ra+i];        
            pb[j] = tmp/ra;            
        }
}


//----------------------------------------------------------
// �Ծ����i�е�j��Ԫ�ظ�ֵ

void mSetElement(double *pa,
                  int ra,
                  int ca,
                  int i,
                  int j,
                  double b)
{
    if (i>=0 && i<ra && j>=0 && j<ca)     
        pa[j*ra+i] = b;        
    else
        mexErrMsgTxt("The index exceed its limit in function \"mSetElement\"\n"); 
}

//----------------------------------------------------------
// ȡ�����i�е�j��Ԫ��

void mGetElement(double *pb,
                 double *pa,
                 int ra,
                 int ca,
                 int i,
                 int j)
{
    if (i>=0 && i<ra && j>=0 && j<ca)     
        *pb = pa[j*ra+i];        
    else
        mexErrMsgTxt("The index exceed its limit in function \"mGetElement\"\n"); 
}

//----------------------------------------------------------
// �����ʾ

void mPrint(char *name,
            double *pa,
            int ra,
            int ca)
{
    int i,j;
    
    mexPrintf("%s = \n",name);            
    for (i=0;i<ra;i++)
    {
    mexPrintf("    ");            
        for (j=0;j<ca;j++)
            mexPrintf("%4.4f\t",pa[j*ra+i]);
    mexPrintf("\n");            
    }
}

//----------------------------------------------------------
// ����Ԫ�ص�sign

void mSign(double *pb,
           double *pa,
           int ra,
           int ca)
{
    int i,j;
    for (j=0;j<ca;j++)
        for (i=0;i<ra;i++)
            if (pa[j*ra+i]>0)
                pb[j*ra+i] = 1;
            else if (pa[j*ra+i]==0)
                pb[j*ra+i] = 0;
            else
                pb[j*ra+i] = -1;
}
