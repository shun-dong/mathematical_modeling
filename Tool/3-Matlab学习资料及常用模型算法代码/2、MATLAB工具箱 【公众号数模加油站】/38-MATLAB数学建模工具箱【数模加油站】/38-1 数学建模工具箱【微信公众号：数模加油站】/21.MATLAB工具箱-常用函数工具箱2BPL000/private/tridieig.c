/* $Revision: 1.4 $ */
#include <math.h>
#include "mex.h"

/*  function x = tridieig(c,b,m1,m2,eps1);
 *  TRIDIEIG  Find a few eigenvalues of a tridiagonal matrix.
 *  LAMBDA = TRIDIEIG(D,E,M1,M2).  D and E, two vectors of length N,
 *  define a symmetric, tridiagonal matrix:
 *     A = diag(E(2:N),-1) + diag(D,0) + diag(E(2:N),1)
 *  E(1) is ignored.
 *  TRIDIEIG(D,E,M1,M2) computes the eigenvalues of A with indices
 *     M1 <= K <= M2.
 *  TRIDIEIG(D,E,M1,M2,TOL) uses TOL as a tolerance.
 *
 *  Author: C. Moler
 *  Copyright (c) 1988-98 by The MathWorks, Inc.
 */

void mexFunction(
    int nlhs,
    mxArray *plhs[],
    int nrhs,
    const mxArray *prhs[]
)
{
   double *c,*b,*x,*beta,*wu;
   double eps,eps1,eps2,xmin,xmax,x0,xu,x1,q,s,h;
   int m1,m2,n,i,k,z,a;
   
   eps = mxGetEps();
   c = mxGetPr(prhs[0]);
   b = mxGetPr(prhs[1]);
   m1 = (int) mxGetScalar(prhs[2]);
   m2 = (int) mxGetScalar(prhs[3]);
   n = mxGetM(prhs[0])*mxGetN(prhs[0]);
   eps1 = (nrhs >= 5 ? mxGetScalar(prhs[4]) : 0);

   beta = mxCalloc(n,sizeof(double));
   beta[0] = 0;
   for (i = 1; i < n; i++) {
      beta[i] = b[i]*b[i];
   }
   xmin  = c[n-1] - fabs(b[n-1]);
   xmax  = c[n-1] + fabs(b[n-1]);
   for (i = 0; i < n-1; i++) {
      h = fabs(b[i]) + fabs(b[i+1]);
      if (c[i] - h < xmin)
         xmin = c[i] - h;
      if (c[i] + h > xmax)
         xmax = c[i] + h;
   }

   eps2 = eps*(xmax > -xmin ? xmax : -xmin);
   if (eps1 <= 0)
      eps1 = eps2;
   eps2 = 0.5*eps1 + 7*eps2;
   x0 = xmax;
   x = mxCalloc(n,sizeof(double));
   wu = mxCalloc(n,sizeof(double));
   for (i = m1-1; i < m2; i++) {
      x[i]= xmax;
      wu[i]= xmin;
   }
   
   z = 0;
   for (k = m2; k >= m1; k--) {
      xu = xmin;
      for (i = k; i >= m1; i--) {
         if (xu < wu[i-1]) {
            xu = wu[i-1];
            break;
         }
      }
      if (x0 > x[k-1]) {
         x0 = x[k-1];
      }
      while (1)
      {
      	x1 = (xu + x0) / 2.0;
         if ((x0 - xu) <= (2*eps*(fabs(xu) + fabs(x0)) + eps1)) {
            break;
         }
         z++;
         a = 0;
         q = 1.0;
         for (i = 0; i < n; i++) {
            if (q != 0) {
               s = beta[i] / q;
            } else {
               s = fabs(b[i]) / eps;
            }
            q = c[i] - x1 - s;
            a = a + (q < 0);
         }
         if (a < k) {
            if (a < m1) {
               xu = x1;
               wu[m1-1] = x1;
            } else {
               xu = x1;
               wu[a] = x1;
               if (x[a-1] > x1) {
                  x[a-1] = x1;
               }
            }
         } else {
            x0 = x1;
         }
      }
      x[k-1] = (x0 + xu) / 2.0;
   }
   mxFree(beta);
   mxFree(wu);
   plhs[0] = mxCreateDoubleMatrix(m2-m1+1,1,0);
   wu = mxGetPr(plhs[0]);
   for (i = m1; i <= m2; i++) {
      wu[i-m1] = x[i-1];
   }
   mxFree(x);
   return;
}
