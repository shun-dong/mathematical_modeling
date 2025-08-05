/*
 * CHEBWIN Chebyshev window.
 *   CHEBWIN(N,R) returns the N-point Chebyshev window with R decibels
 *   of ripple.
 *
 *  Reference: E. Brigham, "The Fast Fourier Transform and its Applications" 
 *  M-file Author: James Montanaro
 *  CMEX translation: D. Orofino
 */

/* $Revision: 1.4 $ */
/* Copyright (c) 1988-98 by The MathWorks, Inc. */

#include <math.h>
#include "mex.h"

#define N_IN   prhs[0]
#define R_IN   prhs[1]
#define W_OUT  plhs[0]

/*
 *  The MEX function:
 */
void mexFunction(
  int     nlhs,
  mxArray *plhs[],
  int     nrhs,
  const mxArray *prhs[]
)
{
    /*
     *  Check input syntax:
     */
    if (nrhs != 2) {
	mexErrMsgTxt("Incorrect number of input arguments.");
    }
    if ( !mxIsDouble(N_IN) || !mxIsDouble(R_IN) ) {
	mexErrMsgTxt("Input arguments must be double-precision scalars.");
    }
    if ((mxGetNumberOfElements(N_IN) != 1) ||
        (mxGetNumberOfElements(R_IN) != 1)  ) {
	mexErrMsgTxt("Inputs must be scalars.");
    }
    if (nlhs > 1) {
        mexErrMsgTxt("Too many return arguments.");
    }

    /* Compute window coefficients: */
    {
        const int_T  N      = (int_T) (mxGetPr(N_IN)[0]);
        const real_T R      = mxGetPr(R_IN)[0];
        const int_T  middle = (N%2==0) ? N/2 : N/2+1;
        real_T      *w;
        int_T       *kterm;
        int_T        i;

        /* Pre-compute values of k*(k+1) for k=1 to middle-2 */
        kterm = (int_T *)mxCalloc(middle-2, sizeof(int_T));
        if (kterm == NULL) {
            mexErrMsgTxt("Failed to allocate work array");
        }
        for (i=0; i<middle-2; i++) {
          kterm[i] = (i+1)*(i+2);
        }

        /* Allocate output vector: */
        W_OUT = mxCreateDoubleMatrix(N, 1, mxREAL);

        /* Compute window weights: */
        {
            real_T *w    = (real_T *)mxGetPr(W_OUT);
            real_T  wmax = 1.0/(N-1);  /* Initialize max value to w[0] */

            /* Convert dB attenuation: */
            real_T b = pow(10.0, R/20.0);
            b = tanh( log(b + sqrt(b*b-1)) / (N-1) );
            b *= b;

            /* Preset first and last weights: */
            w[N-1] = w[0] = wmax;

            /* Calculate remaining weights: */
            for(i=2; i<=middle; i++) {
                int_T  k;
                real_T t = b;
                real_T s = 0.0;

                for(k=1; k<i-1; k++) {
                    t *= b * (i-1-k) * (N-i-k) / kterm[k-1];
                    s += t;
                }
                w[N-i] = w[i-1] = b+s;

                /* Update maximum window value: */
                if (w[i-1] > wmax) {
                    wmax = w[i-1];
                }
            }

            /* Normalize weights */
            for(i=0; i<N; i++) {
                *w++ /= wmax;
            }
        }

        mxFree(kterm);  /* Clean up */
    }
}
