#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix_operation.h"

// �����������
#define SVM prhs[0]
#define XT prhs[1]

// �����������
#define YD plhs[0]

// ���� C ���㺯�� (�ú��������ܺͱ��ļ�������)
void KERNEL();
void SVMSIM();
void SVMSIM_BLOCK();
void CALCULATE_SVC();
void CALCULATE_ONE_CLASS();
void CALCULATE_SVR();

void 
mexFunction (int nlhs, mxArray *plhs[],			// ��������������������������
			 int nrhs, const mxArray *prhs[])	// ��������������������������
{
    double *pxt,*pyd;
    int dt,nt;
    
    // ȡ���������
    pxt = mxGetPr(XT);
    dt = mxGetM(XT);             // ȡ�þ���X��������
    nt = mxGetN(XT);
    
    // Ϊ������������ڴ�ռ�
	YD = mxCreateDoubleMatrix(1,nt,mxREAL); 

	// ȡ���������ָ��
	pyd = mxGetPr(YD);

	// ���� C ���㺯�� (�ú��������ܺͱ��ļ�������)
    SVMSIM(pyd,SVM,pxt,dt,nt);
	return;
}

void SVMSIM(double *pyd,    // �������,1��nt�ľ���
            mxArray *pSvm,  // SVM
            double *pxt,    // ��������,dt��nt�ľ���
            int dt,         // ������������
            int nt)         // ������������
{
    int nx,block,num,i,j1,j2;
    double cathe=10e+6,*tmp[4];
    
    nx = mxGetN(mxGetField(pSvm,0,"x"));         
    block = (int) ceil(nx*nt/cathe);
    num = (int) ceil(nt/block);
    
    tmp[0] = mxCalloc(dt*num,sizeof(double));
    tmp[1] = mxCalloc(1*num,sizeof(double));    
    tmp[2] = mxCalloc(dt*(nt-num*(block-1)),sizeof(double));    
    tmp[3] = mxCalloc(1*(nt-num*(block-1)),sizeof(double));    
    
    for (i=0;i<block;i++)
    {
        j1 = i*num;
        if (i<block-1)
        {
            j2 = (i+1)*num-1;    
            mGetCols(tmp[0],pxt,dt,nt,j1,j2);
            SVMSIM_BLOCK(tmp[1],pSvm,tmp[0],dt,num);
            mSetCols(pyd,1,nt,j1,j2,tmp[1]);
        }
        else
        {
            j2 = nt-1;            
            mGetCols(tmp[2],pxt,dt,nt,j1,j2);
            SVMSIM_BLOCK(tmp[3],pSvm,tmp[2],dt,num);
            mSetCols(pyd,1,nt,j1,j2,tmp[3]);
        }
    }
    mxFree(tmp[0]);
    mxFree(tmp[1]);            
    mxFree(tmp[2]);            
    mxFree(tmp[3]);                
}

void SVMSIM_BLOCK(double *pyd,    // �������,1��nt�ľ���
                  mxArray *pSvm,  // SVM
                  double *pxt,    // ��������,dt��nt�ľ���
                  int dt,         // ������������
                  int nt)         // ������������
{
    mxArray *pType,*pKer;
    int len,dx,nx,n_sv,*pi_sv,i,j;
    char *svmType;
    double *px,*py,*pa;
    
    if (mxIsStruct(pSvm))
    {
        pType = mxGetField(pSvm,0,"type"); 
        len = mxGetM(pType)*mxGetN(pType)+1;
        svmType = mxCalloc(len,sizeof(char));
        mxGetString(pType,svmType,len);         // ���˺������Ͷ����ַ���
        
        // mexPrintf(" svm.type = %s \n",svmType);
        
        pKer = mxGetField(pSvm,0,"ker"); 
        
        px = mxGetPr(mxGetField(pSvm,0,"x")); 
        dx = mxGetM(mxGetField(pSvm,0,"x")); 
        nx = mxGetN(mxGetField(pSvm,0,"x"));         
        
        py = mxGetPr(mxGetField(pSvm,0,"y")); 
        pa = mxGetPr(mxGetField(pSvm,0,"a")); 
        
        // mexPrintf(" dx = %d, nx = %d \n",dx,nx);                    
        
        if (dx != dt)
            mexErrMsgTxt("The dimension of train and test sample must be equal!");

        // ȡ��֧������������    
        pi_sv = mxCalloc(nx,sizeof(int)); 
        j = 0;
        for (i=0;i<nx;i++)
            if (fabs(pa[i])>1E-8)
            {
                pi_sv[j] = i;
                j = j+1;
            }
        n_sv = j;
        pi_sv = mxRealloc(pi_sv,n_sv*sizeof(int));
        
        if (!strcmp(svmType,"svc_c") || !strcmp(svmType,"svc_nu"))
        {
            CALCULATE_SVC(pyd,pKer,px,dx,nx,py,pa,pi_sv,n_sv,pxt,nt);        
        }
        else if (!strcmp(svmType,"svm_one_class"))
        {
            CALCULATE_ONE_CLASS(pyd,pKer,px,dx,nx,py,pa,pi_sv,n_sv,pxt,nt);                
        }
        else if (!strcmp(svmType,"svr_epsilon") || !strcmp(svmType,"svr_nu"))
        {
            CALCULATE_SVR(pyd,pKer,px,dx,nx,py,pa,pi_sv,n_sv,pxt,nt);                        
        }
        
        mxFree(svmType);
        mxFree(pi_sv);
    }
}

void CALCULATE_SVC(double *pyd,     // ,�������,1��nt�ľ���
                   mxArray *pKer,   // �˲���
                   double *px,      // ѵ������,dx��nx�ľ���
                   int dx,          // 
                   int nx,          // 
                   double *py,      // ѵ�����,1��nx�ľ���
                   double *pa,      // �������ճ���,1��nx�ľ���
                   int *pi_sv,      // ֧����������
                   int n_sv,        // 
                   double *pxt,     // ��������,dx��nt�ľ���
                   int nt)          // 
{

    double *px_sv,*py_sv,*pk1,*pk2,b,*tmp[6],p=1;
 
    px_sv = mxCalloc(dx*n_sv,sizeof(double));    
    mGetIndexCols(px_sv,px,dx,nx,pi_sv,n_sv);
    
    py_sv = mxCalloc(1*n_sv,sizeof(double));            
    mGetIndexCols(py_sv,py,1,nx,pi_sv,n_sv);

    pk1 = mxCalloc(nx*n_sv,sizeof(double));        
    KERNEL(pk1,pKer,px,px_sv,nx,n_sv,dx);
    mxFree(px_sv);        

    tmp[0] = mxCalloc(1*nx,sizeof(double));                 
    mPTimes(tmp[0],pa,1,nx,py,1,nx);
    
    tmp[1] = mxCalloc(1*n_sv,sizeof(double));         
    mTimes(tmp[1],tmp[0],1,nx,pk1,nx,n_sv);
    mxFree(pk1);        
    
    tmp[3] = mxCalloc(1*n_sv,sizeof(double));                
    mMinus(tmp[3],py_sv,1,n_sv,tmp[1],1,n_sv);
    mxFree(py_sv);            
    mxFree(tmp[1]);    
    
    mMean(&b,tmp[3],1,n_sv); 
    mxFree(tmp[3]);        
    
    //mPrint("svmSim.c -> b",&b,1,1);    

    pk2 = mxCalloc(nx*nt,sizeof(double));        
    KERNEL(pk2,pKer,px,pxt,nx,nt,dx);
    
    tmp[4] = mxCalloc(1*nt,sizeof(double));                
    mTimes(tmp[4],tmp[0],1,nx,pk2,nx,nt);
    mxFree(tmp[0]);            
    mxFree(pk2);    

    //mPrint("svmSim.c -> tmp",tmp[4],1,10);        
    
    tmp[5] = mxCalloc(1*nt,sizeof(double));                
    mPlus(tmp[5],tmp[4],1,nt,&b,1,1);       
    mxFree(tmp[4]);          

    //mPrint("svmSim.c -> tmp+b",tmp[5],1,10);            
    
    mSign(pyd,tmp[5],1,nt);
    mxFree(tmp[5]);         
}

void CALCULATE_ONE_CLASS(double *pyd,   // �������,1��nt�ľ���
                         mxArray *pKer, // �˲���
                         double *px,    // ѵ������,dx��nx�ľ���
                         int dx,        // 
                         int nx,        // 
                         double *py,    // ѵ�����,1��nx�ľ���
                         double *pa,    // �������ճ���,1��nx�ľ���
                         int *pi_sv,    // ֧����������
                         int n_sv,      // 
                         double *pxt,   // ��������,dx��nt�ľ���
                         int nt)        // 
{
    double *px_sv,*pk1,*pk2,*pk3,tmp1,tmp2,tmp3,*ptmp1,*ptmp2,*ptmp4,*ptmp5,b,R_square;
    int i,j,i_sv;
    
    px_sv = mxCalloc(dx*n_sv,sizeof(double));
    for (j=0;j<n_sv;j++)
    {
        i_sv = pi_sv[j];
        for (i=0;i<dx;i++)
            px_sv[j*dx+i] = px[i_sv*dx+i];
    }

    ptmp1 = mxCalloc(n_sv,sizeof(double));    
    for (j=0;j<n_sv;j++)
        KERNEL(ptmp1+j,pKer,px_sv+j*dx,px_sv+j*dx,1,1,dx);

    pk1 = mxCalloc(nx*n_sv,sizeof(double));
    KERNEL(pk1,pKer,px,px_sv,nx,n_sv,dx);
    
    ptmp2 = mxCalloc(n_sv,sizeof(double));
    for (j=0;j<n_sv;j++)
    {
        i_sv = pi_sv[j];
        tmp1 = 0;
        for (i=0;i<nx;i++)
            tmp1 = tmp1 + 2*pa[i]*pk1[j*nx+i];
        ptmp2[j] = tmp1;
    }
    
    pk2 = mxCalloc(nx*nx,sizeof(double));
    KERNEL(pk2,pKer,px,px,nx,nx,dx);
    
    tmp3 = 0;
    for (j=0;j<nx;j++)
        for (i=0;i<nx;i++)
            tmp3 = tmp3 + pa[i]*pa[j]*pk2[j*nx+i];
       
    R_square = 0;
    for (j=0;j<n_sv;j++)
        R_square = R_square + (ptmp1[j]-ptmp2[j]+tmp3);
    R_square = R_square/n_sv;
    
    // mexPrintf(" R_square = %f \n",R_square);        
            
    ptmp4 = mxCalloc(nt,sizeof(double));    
    for (j=0;j<nt;j++)
        KERNEL(ptmp4+j,pKer,pxt+j*dx,pxt+j*dx,1,1,dx);
        
    pk3 = mxCalloc(nx*nt,sizeof(double));
    KERNEL(pk3,pKer,px,pxt,nx,nt,dx);
    
    ptmp5 = mxCalloc(nt,sizeof(double));
    for (j=0;j<nt;j++)
    {
        tmp1 = 0;
        for (i=0;i<nx;i++)
            tmp1 = tmp1 + 2*pa[i]*pk3[j*nx+i];
        ptmp5[j] = tmp1;
    }
    
    for (j=0;j<nt;j++)
    {
        tmp1 = ptmp4[j]-ptmp5[j]+tmp3-R_square;
        if (tmp1>0)
            pyd[j] = 1;
        else if (tmp1==0)  
            pyd[j] = 0;        
        else if (tmp1<0)  
            pyd[j] = -1;        
    }
    
    mxFree(px_sv);
    mxFree(pk1);
    mxFree(pk2);
    mxFree(pk3);
    mxFree(ptmp1);    
    mxFree(ptmp2);
    mxFree(ptmp4);
    mxFree(ptmp5);    
}

void CALCULATE_SVR(double *pyd,     // ,�������,1��nt�ľ���
                   mxArray *pKer,   // �˲���
                   double *px,      // ѵ������,dx��nx�ľ���
                   int dx,          // 
                   int nx,          // 
                   double *py,      // ѵ�����,1��nx�ľ���
                   double *pa,      // �������ճ���,1��nx�ľ���
                   int *pi_sv,      // ֧����������
                   int n_sv,        // 
                   double *pxt,     // ��������,dx��nt�ľ���
                   int nt)          // 
{
    double *px_sv,*py_sv,*pk1,*pk2,b,*tmp[3];
    
    px_sv = mxCalloc(dx*n_sv,sizeof(double));    
    mGetIndexCols(px_sv,px,dx,nx,pi_sv,n_sv);
    
    py_sv = mxCalloc(1*n_sv,sizeof(double));        
    mGetIndexCols(py_sv,py,1,nx,pi_sv,n_sv);

    pk1 = mxCalloc(nx*n_sv,sizeof(double));    
    KERNEL(pk1,pKer,px,px_sv,nx,n_sv,dx);
    mxFree(px_sv);    
    
    tmp[0] = mxCalloc(1*n_sv,sizeof(double));        
    mTimes(tmp[0],pa,1,nx,pk1,nx,n_sv);
    mxFree(pk1);
    
    tmp[1] = mxCalloc(1*n_sv,sizeof(double));            
    mMinus(tmp[1],py_sv,1,n_sv,tmp[0],1,n_sv);
    mxFree(tmp[0]);        
    mxFree(py_sv);    
    
    mMean(&b,tmp[1],1,n_sv);
    mxFree(tmp[1]);    
    
    // mexPrintf(" b = %f \n",b);    
    
    pk2 = mxCalloc(nx*nt,sizeof(double));    
    KERNEL(pk2,pKer,px,pxt,nx,nt,dx);
    
    tmp[2] = mxCalloc(1*nt,sizeof(double));        
    mTimes(tmp[2],pa,1,nx,pk2,nx,nt);
    mxFree(pk2);    
    
    mPlus(pyd,tmp[2],1,nt,&b,1,1);       
    mxFree(tmp[2]);        
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
