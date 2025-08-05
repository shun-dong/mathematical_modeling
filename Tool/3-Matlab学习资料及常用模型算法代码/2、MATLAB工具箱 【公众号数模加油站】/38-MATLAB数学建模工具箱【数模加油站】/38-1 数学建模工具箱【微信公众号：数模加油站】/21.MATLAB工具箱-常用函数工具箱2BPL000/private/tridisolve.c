/*  
 *  function y = tridisolve(e,d,b,n);
 *  TRIDISOLVE 
 *  Solves a symmetric, tridiagonal system
 *     A = diag(E,-1) + diag(D,0) + diag(E,1)
 *  TRIDISOLVE(E,D,B,N) 
 *  Algorithm from Golub and Van Loan, "Matrix Computations", 2nd Edition,
 *  p.156.
 * 
 *  MEX-file implementation: T. Krauss, D. Orofino, 4/22/97
 *  Copyright (c) 1988-98 by The MathWorks, Inc.
 *  $Revision: 1.3 $ $Date: 1997/12/02 21:15:06 $
 */
       
#include <math.h>
#include "mex.h"
#include "string.h"  /* for memcpy */
       
void mexFunction(
    int nlhs,
    mxArray *plhs[],
    int nrhs,
    const mxArray *prhs[]
)
{
   double *buf,*ee,*dd,*y,*ym1;
   int k;
   
   double eps = mxGetEps();
   double *e = mxGetPr(prhs[0]);
   double *d = mxGetPr(prhs[1]);
   double *b = mxGetPr(prhs[2]);
   int n = (int) mxGetScalar(prhs[3]);

   plhs[0] = mxCreateDoubleMatrix(n,1,0);
   y = mxGetPr(plhs[0]);

   buf = mxCalloc(2*n-1,sizeof(double));
   if (buf == NULL) {
       mexErrMsgTxt("Sorry, failed to allocate buffer.");
   }
   
   dd = buf;
   ee = dd+n;

   /* Make copies of b,e,d */
   memcpy((char *)y,(char *)b,n*sizeof(double));
   memcpy((char *)ee,(char *)e,(n-1)*sizeof(double));
   memcpy((char *)dd,(char *)d,n*sizeof(double));

   for (k = n-1; k--;) {            /* for k = 2:n    */
       double t = *ee;              /*    t = e(k-1);    */
       if (*dd == 0.0) {
           mexWarnMsgTxt("Matrix is singular to working precision.  Results may be inaccurate.\n");
           *dd = eps*eps;
       }
       *ee = t / *dd++;             /*    e(k-1) = t/d(k-1);    */
       *dd -= t * *ee++;            /*    d(k) = d(k) - t*e(k-1)    */
   }                                /* end    */

   ym1 = y++;  /* ym1 means "y minus 1" */
   ee = buf+n;
   for (k = n-1; k--;) {            /* for k = 2:n    */
       *y++ -= *ee++ * *ym1++;      /*    b(k) = b(k) - e(k-1)*b(k-1)    */
   }                                /* end    */
   if (*dd == 0.0) {
       mexWarnMsgTxt("Matrix is singular to working precision.  Results may be inaccurate.\n");
       *dd = eps*eps;
   }
   *ym1 /= *dd;                     /* b(n) = b(n) / d(n)    */

   y = ym1;  /* y points to last y value */
   ym1--;    /* ym1 points to 2nd to last y value */
   dd = buf + n-2;  /* dd points to 2nd to last d value */
   ee = buf + 2*n-2;  /* dd points to last e value */
   for (k = n-1; k--;) {            /* for k = n-1 : -1 : 1    */
       if (*dd == 0.0) {
           mexWarnMsgTxt("Matrix is singular to working precision.  Results may be inaccurate.\n");
           *dd = eps*eps; 
       }
       *ym1 /= *dd--;               /*    b(k) = b(k)/d(k)    */
       *ym1-- -= *ee-- * *y--;      /*    b(k) = b(k) - e(k)*b(k+1)   */
   }                                /* end   */

   mxFree(buf);

   return;
}
