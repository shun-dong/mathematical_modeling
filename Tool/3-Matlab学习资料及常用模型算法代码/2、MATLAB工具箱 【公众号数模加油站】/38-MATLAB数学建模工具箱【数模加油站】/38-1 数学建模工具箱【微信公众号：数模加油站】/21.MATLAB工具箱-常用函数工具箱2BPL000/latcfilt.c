/*
 * latcfilt.c
 *
 * LATCFILT Lattice and lattice-ladder filter implementation.
 *    [F,G] = LATCFILT(K,X) filters X with the FIR lattice coefficients
 *    in vector K.  F is the forward lattice filter result, and G is the
 *    backward filter result.
 * 
 *    If K and X are vectors, the result is a (signal) vector.
 *    Matrix arguments are permitted under the following rules:
 *    - If X is a matrix and K is a vector, each column of X is processed
 *      through the lattice filter specified by K.
 *    - If X is a vector and K is a matrix, each column of K is used to
 *      filter X, and a signal matrix is returned.
 *    - If X and K are both matrices with the same # of columns, then the
 *      i-th column of K is used to filter the i-th column of X.  A
 *      signal matrix is returned.
 * 
 *    [F,G] = LATCFILT(K,V,X) filters X with the IIR lattice
 *    coefficients K and ladder coefficients V.  K and V must be
 *    vectors, while X may be a signal matrix.
 * 
 *    [F,G] = LATCFILT(K,1,X) filters X with the IIR all-pole lattice
 *    specified by K.  K and X may be vectors or matrices according to
 *    the rules given for the FIR lattice.
 *
 *
 *   See also FILTER, TF2LATC, LATC2TF.
 *
 *   D. Orofino, May 1996
 */

/* $Revision: 1.13 $ */
/* Copyright (c) 1988-98 by The MathWorks, Inc. */

#include <math.h>
#include <string.h> /* For memset() */
#include "mex.h"

#define H_IN   prhs[0]
#define V_IN   prhs[1]
#define X_IN   prhs[2]
#define F_OUT  plhs[0]
#define G_OUT  plhs[1]

#ifndef max
#define	max(A, B) ((A)>(B) ? (A) : (B))
#endif

static void Real_FIR_Lattice(
    double F[],  double G[], unsigned int Ly,  unsigned int ky, 
    double              x[], const unsigned int Lx, const unsigned int kx, 
    double              h[], const unsigned int Lh, const unsigned int kh, 
    double D[]
)
{
    double  *orig_x  = x;
    double  *orig_h  = h;
    const unsigned int orig_Ly = Ly;

    /*
     * Compute each column of filter output:
     */
    while (ky-- != 0) {
	double *x_pastend;

	/* Reset for next column: */
	if (kx == 1) x = orig_x;
	if (kh == 1) h = orig_h;
	Ly = orig_Ly;

	/* Determine end of input data column.
	 * Note that this relies on the "new" x pointer, so keep
	 * this after the "x=orig_x" line above.  Also, we do not
	 * want to recompute this in the sample loop below:
	 */
	x_pastend = x + Lx;   /* End of input data column       */

	/* Clear the delay buffers: */

	memset((void *)D, 0, Lh*sizeof(double));

	/* Loop over output samples: */
	while (Ly-- != 0) {
	    /*
	     * Purely-real sample loop:
	     */
	    double fout, gout;
	    double *Dp = D;            /* Reset to start of delay buffer */
	    double *Kp = h;            /* Reset to first lattice coeff   */
	    unsigned int stage_cnt = Lh;

	    /* Get next input sample to first-stage: */
	    double gin;
	    double fin = gin = ((x == x_pastend) ? 0.0 : *x++);

	    while (stage_cnt-- != 0) {
		fout = fin + *Dp * *Kp;
		gout = *Dp + fin * *Kp++;
		*Dp++ = gin;
		fin = fout;       /* Setup for next lattice stage */
		gin = gout;
	    }

	    /* Copy outputs: */
	    *F++ = fout;
	    if (G != NULL) *G++ = gout;
	}

	/* Next filter (we've been incrementing a copy of the pointer: */
	h += Lh;

    } /* k (output column) loop */
}

static void Complex_FIR_Lattice(
    double F[], double Fi[],
    double G[], double Gi[], unsigned int Ly, unsigned int ky, 
    double x[], double xi[], const unsigned int Lx, const unsigned int kx, 
    double h[], double hi[], const unsigned int Lh, const unsigned int kh, 
    double D[]
)
{
    double  *orig_x  = x,  *orig_xi = xi;
    double  *orig_h  = h,  *orig_hi = hi;
    const unsigned int orig_Ly = Ly;

    /*
     * Compute each column of filter output:
     */
    while (ky-- != 0) {
	double *x_pastend;

	/* Reset for next column: */
	if (kx == 1) {x=orig_x; xi=orig_xi;}
	if (kh == 1) {h=orig_h; hi=orig_hi;}
	Ly = orig_Ly;

	/* Determine end of input data column.
	 * Note that this relies on the "new" x pointer, so keep
	 * this after the "x=orig_x" line above.  Also, we do not
	 * want to recompute this in the sample loop below:
	 */
	x_pastend = x + Lx;   /* Beyond end of real input data column */

	/* Clear the delay buffers.
	 * Note that D contains BOTH real and imag buffers
	 * (first D then Di), so that D is of length 2*Lh.
	 */
	memset((void *)D, 0, 2*Lh*sizeof(double));

	/* Loop over output samples: */
	while (Ly-- != 0) {
	    /*
	     * Complex sample loop:
	     */
	    double  foutr, fouti, goutr, gouti;
	    double *Dr = D;       /* Reset to start of real buffer */
	    double *Di = D+Lh;    /* Reset to start of imag buffer */
	    double *Kr = h;       /* Reset to first lattice coeff  */
	    double *Ki = hi;
	    unsigned int stage_cnt = Lh;

	    /*
	     * Get next input samples:
	     * NOTE: Always construct a complex input.
	     *       Get imag sample first, so the x==x_pastend comparison
	     *       is executed BEFORE x is updated for real part...
	     */
	    double fini,finr, gini,ginr;
	    fini = gini = ((x == x_pastend) || (xi == NULL)
			   ? 0.0 : *xi++ );
	    finr = ginr = ((x == x_pastend) ? 0.0 : *x++);

	    if (Ki != NULL) {
		/* Complex coeffs, K: */
		while (stage_cnt-- != 0) {
		    double kkr = *Kr++, kki = *Ki++;
		    double ddr = *Dr, ddi = *Di;

		    /* Update delay buffers: */
    		    *Dr++ = ginr; *Di++ = gini;

		    /*
		     * Compute stage outputs:
		     * Don't forget that fout = fin +   D * K,
		     *           whereas gout =   D + fin * conj(K).
		     */
		    foutr = finr +  ddr * kkr -  ddi *   kki;
		    goutr = ddr  + finr * kkr - fini * (-kki);

		    fouti = fini +  ddr *   kki  +  ddi * kkr;
		    gouti = ddi  + finr * (-kki) + fini * kkr;

		    /* Update for next stage: */
		    finr = foutr; fini = fouti;
		    ginr = goutr; gini = gouti;
		}
	    } else {
		/* Real coeffs, K: */
		while (stage_cnt-- != 0) {
		    double kkr = *Kr++;
		    double ddr = *Dr, ddi = *Di;

		    /* Update delay buffers: */
		    *Dr++ = ginr; *Di++ = gini;

		    /* Compute stage outputs: */
		    foutr = finr + ddr * kkr;
		    goutr = ddr + finr * kkr;

		    fouti = fini + ddi * kkr;
		    gouti = ddi + fini * kkr;

		    /* Update for next stage: */
		    finr = foutr; fini = fouti;
		    ginr = goutr; gini = gouti;
		}
	    }

	    /* Copy outputs: */
	    *F++ = foutr;  *Fi++ = fouti;
	    if (G != NULL) {
		*G++ = goutr; *Gi++ = gouti;
	    }
	}

	/* Next filter (we've been incrementing a copy of the pointer): */
	h += Lh;
	if (hi != NULL) {hi += Lh;}

    } /* k (output column) loop */
}


static void Real_IIR_Lattice(
    double F[],  double G[], unsigned int Ly,  unsigned int ky,
    double              x[], const unsigned int Lx, const unsigned int kx,
    double              h[], const unsigned int Lh, const unsigned int kh,
    double              v[], const unsigned int Lv, const unsigned int kv,
    double D[]
)
{
    double  *orig_x  = x;
    double  *orig_h  = h;
    double  *orig_v  = v;
    const unsigned int orig_Ly = Ly;
    const unsigned int Ld = Lh+1;

    /*
     * Compute each column of filter output:
     */
    while (ky-- != 0) {
	double *x_pastend;

	/* Reset for next column: */
	if (kx == 1) x = orig_x;
	if (kh == 1) h = orig_h;
	if (kv == 1) v = orig_v;
	Ly = orig_Ly;

	/* Determine end of input data column.
	 * Note that this relies on the "new" x pointer, so keep
	 * this after the "x=orig_x" line above.  Also, we do not
	 * want to recompute this in the sample loop below:
	 */
	x_pastend = x + Lx;   /* End of input data column       */

	/* Clear the delay buffers: */
	memset((void *)D, 0, Ld*sizeof(double));

	/* Loop over output samples: */
	while (Ly-- != 0) {
	    /*
	     * Purely-real sample loop:
	     */
	    /* NOTE: D is of length Ld = Lh+1 */
	    double *Dp = D+Ld-2;       /* Second to last buffer */
	    double *Kp = h+Lh-1;       /* Last lattice coeff    */

	    /* Get next input sample: */
	    double fin = (x == x_pastend) ? 0.0 : *x++;

	    do {
		fin -= *Dp * *Kp;            /* Setup for next stage */
		*(Dp+1) = *Dp + fin * *Kp--; /* Update buffer value  */
	    } while (--Dp >= D);
	    *D = fin;           /* Update first buffer, g0(n) = f0(n) */

	    /* Copy backward lattice output
	     * No ladder coeffs for backward terms:
	     */
	    if (G != NULL) *G++ = *(D+Ld-1); /* Last buffer sample */

	    /*
	     * Implement ladder filter:
	     */
	    if (Lv == 1) {
		/* Scalar ladder coefficient: */
		*F++ = *D * *v;

	    } else {
		/*
		 * Preset to start of delay buffer and ladder coeffs.
		 * NOTE: There are Ld = Lh+1 delays,
		 *             and Lv <= Ld ladder coeffs.
		 */
		unsigned int taps = Lv;
		double acc = 0.0;
		double *Vp = v;  /* Reset to first ladder coeff */
		Dp = D;          /* Reset to first buffer       */
		while (taps-- != 0) {
		    acc += *Dp++ * *Vp++;
		}
		*F++ = acc; /* Store result, bump output position */
	    }
	}
	/* Next filter (we've been incrementing a copy of the pointer): */
	h += Lh;
	v += Lv;

    } /* end of ky (output column) loop */
}


static void Complex_IIR_Lattice(
    double F[], double Fi[],
    double G[], double Gi[], unsigned int Ly, unsigned int ky,
    double x[], double xi[], const unsigned int Lx, const unsigned int kx,
    double h[], double hi[], const unsigned int Lh, const unsigned int kh,
    double v[], double vi[], const unsigned int Lv, const unsigned int kv,
    double DBuf[]
)
{
    double  *orig_x  = x,  *orig_xi = xi;
    double  *orig_h  = h,  *orig_hi = hi;
    double  *orig_v  = v,  *orig_vi = vi;
    const unsigned int orig_Ly = Ly;
    const unsigned int Ld = Lh+1;

    /*
     * DBuf is a contiguous allocation for the real and imag delay buffers.
     * Make "permanent" pointers to start of each individual buffer:
     */
    double *DPr = DBuf, *DPi = DBuf+Ld;

    /*
     * Compute each column of filter output:
     */
    while (ky-- != 0) {
	double *x_pastend;

	/* Reset for next column: */
	if (kx == 1) {x=orig_x; xi=orig_xi;}
	if (kh == 1) {h=orig_h; hi=orig_hi;}
	if (kv == 1) {v=orig_v; vi=orig_vi;}
	Ly = orig_Ly;

	/* Determine end of input data column.
	 * Note that this relies on the "new" x pointer, so keep
	 * this after the "x=orig_x" line above.  Also, we do not
	 * want to recompute this in the sample loop below:
	 */
	x_pastend = x + Lx;   /* End of input data column       */

	/*
	 * Clear both real and imag delay buffers.
	 * (DPr and DPi are contiguous in memory)
	 */
	memset((void *)DBuf, 0, 2*Ld*sizeof(double));

	/* Loop over output samples: */
	while (Ly-- != 0) {
	    /*
	     * Purely-real sample loop:
	     */
	    double *Dr = DPr+Ld-2;   /* Second to last real buff */
	    double *Di = DPi+Ld-2;   /* Second to last imag buff */
	    double *Kr = h+Lh-1;     /* Last real lattice coeff  */
	    double *Ki = (hi == NULL) ? NULL : hi+Lh-1;  /* Last imag lattice coeff */

	    /* Get next input sample:
	     * NOTE: Always construct a complex input.
	     *       Get imag sample first, so the x==x_pastend comparison
	     *       is executed BEFORE x is updated for real part...
	     */
	    double fini = ((x == x_pastend) || (xi == NULL) ? 0.0 : *xi++ );
	    double finr = ((x == x_pastend) ? 0.0 : *x++);

	    if (Ki != NULL) {
		/* Complex coeffs, K: */
		do {
		    double kkr = *Kr--, kki = *Ki--;
		    double ddr = *Dr, ddi = *Di;
		    /* Don't forget the conjugate on the backward path: */

		    finr -= ddr * kkr - ddi * kki;
		    fini -= ddr * kki + ddi * kkr;
		    *(Dr+1) = ddr + finr * kkr - fini * (-kki);
		    *(Di+1) = ddi + finr * (-kki) + fini * kkr;

		    --Di;
		} while (--Dr >= DPr);

	    } else {
		/* Real coeffs, K: */
		do {
		    double kkr = *Kr--;
		    finr -= *Dr * kkr;
		    fini -= *Di * kkr;
		    *(Dr+1) = *Dr + finr * kkr;
		    *(Di+1) = *Di + fini * kkr;

		    --Di;
		} while (--Dr >= DPr);
	    }
	    *DPr=finr; *DPi=fini;  /* Update first real/imag buffer, g0(n) = f0(n) */

	    /* Copy backward lattice output
	     * No ladder coeffs for backward terms:
	     */
	    if (G != NULL) {
		*G++  = *(DPr+Ld-1); /* Last real buffer sample */
		*Gi++ = *(DPi+Ld-1); /* Last imag buffer sample */
	    }

	    /*
	     *  Implement ladder network:
	     */
	    {
		/*
		 * Preset to start of delay buffer and ladder coeffs.
		 * NOTE: There are Lh+1 delays,
		 *             and Lv <= Lh+1 ladder coeffs.
		 */
		unsigned int taps = Lv;
		double accr=0.0, acci=0.0;
		double *Cr = v;     /* First real ladder coeff  */
		double *Ci = vi;    /* First imag ladder coeff  */

		Dr = DPr;           /* First real buffer sample */
		Di = DPi;           /* First imag buffer sample */
		
		if (Ci == NULL) {
		    /* Purely real ladder: */
		    while (taps-- != 0) {
			accr += *Dr++ * *Cr;
			acci += *Di++ * *Cr++;
		    }
		} else {
		    /* Complex ladder: */
		    while (taps-- != 0) {
			accr += *Dr   * *Cr   - *Di   * *Ci;
			acci += *Dr++ * *Ci++ + *Di++ * *Cr++;
		    }
		}
		*F++  = accr;  /* Store real result */
		*Fi++ = acci;  /* Store imag result */
	    } /* end of ladder computation */

	} /* end of sample loop */

	/* Next filter (we've been incrementing a copy of the pointer): */
	h += Lh;
	if (hi != NULL) {hi += Lh;}
	v += Lv;
	if (vi != NULL) {vi += Lv;}

    } /* end of ky (output column) loop */
}


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
    double *Fr,*Fi, *Gr=NULL,*Gi=NULL;
    int    Fndims, *Fdims;
    double *D;

    double   *ff,*ffi, *gg,*ggi, *xx,*xxi, *hh,*hhi, *vv,*vvi;
    bool     isComplex, xIsComplex, hIsComplex, vIsComplex;
    bool     V_is_scalar, x_is_row, isIIR;
    unsigned int Ld,                /* Delay tap storage */
                 Lx, Lh, Lv, Ly,    /* Lengths           */
                 kx, kh, kv, ky,    /* number of signals */
                 mx, mh, mv, my,    /* # of rows         */
                 nx, nh, nv, ny;    /* # of columns      */
    /*
     *  Check input syntax:
     */
    if (nrhs > 3) {
	mexErrMsgTxt("Too many input arguments.");
    }
    if (nrhs < 2) {
        mexErrMsgTxt("Too few input arguments.");
    }
    if (nlhs > 2) {
        mexErrMsgTxt("Too many return arguments.");
    }

    /*
     *  Make sure inputs are doubles:
     */
    if ( !mxIsDouble(H_IN) || !mxIsDouble(V_IN) ||
                 ((nrhs>2) && !mxIsDouble(X_IN)) ) {
	mexErrMsgTxt("Input arguments must be double-precision arrays.");
    }
    if ( mxIsSparse(H_IN) || mxIsSparse(V_IN) ||
                ((nrhs>2) && mxIsSparse(X_IN)) ) {
	mexErrMsgTxt("Input arguments must be non-sparse arrays.");
    }
    if (             (mxGetNumberOfDimensions(H_IN) > 2) ||
                     (mxGetNumberOfDimensions(V_IN) > 2) ||
        ((nrhs>2) && (mxGetNumberOfDimensions(X_IN) > 2)) ) {
	mexErrMsgTxt("Inputs must be 2-D matrices.");
    }

    /* NOTE:
     *   If x is a SCALAR, then we might want to use the same shape as "h" for
     *   the result if it's a vector.  This is not yet implemented.
     */

    hIsComplex = mxIsComplex(H_IN);
    mh = mxGetM(H_IN);
    nh = mxGetN(H_IN);
    Lh = (mh==1) ? nh : mh;
    kh = (mh==1) ? mh : nh;

    isIIR = (nrhs > 2);
    if (isIIR) {
	vIsComplex = mxIsComplex(V_IN);
	mv = mxGetM(V_IN);
	nv = mxGetN(V_IN);
	Lv = (mv==1) ? nv : mv;
	kv = (mv==1) ? mv : nv;
	
	xIsComplex = mxIsComplex(X_IN);
	mx = mxGetM(X_IN);
	nx = mxGetN(X_IN);
    } else {
	/*
	 * Only 2 inputs: "V" is really "X"...
	 */
	xIsComplex = mxIsComplex(V_IN);
	mx = mxGetM(V_IN);
	nx = mxGetN(V_IN);

	/* V was not passed: */
	Lv = kv = 0; vIsComplex = false;
    }
    x_is_row = (mx==1);
    Lx = x_is_row ? nx : mx;
    kx = x_is_row ? mx : nx;
    V_is_scalar = isIIR && (Lv == 1);

    /*
     * Determine which inputs are complex:
     */
    isComplex = xIsComplex || hIsComplex || vIsComplex;

    /*
     * Get pointers to input and filter:
     * Guarantees NULL imag pointers if x and/or h is real
     */
    hh  = (double *)mxGetPr(H_IN); hhi = (double *)mxGetPi(H_IN);
    if (isIIR) {
	vv = (double *)mxGetPr(V_IN); vvi = (double *)mxGetPi(V_IN);
	xx = (double *)mxGetPr(X_IN); xxi = (double *)mxGetPi(X_IN);
    } else {
	/* Only 2 inputs: "V" is really "X"... */
	vv = vvi = NULL;
	xx = (double *)mxGetPr(V_IN); xxi = (double *)mxGetPi(V_IN);
    }

    /*
     *  Check for empty filter coefficient vectors:
     */
    if ((Lh == 0) || (isIIR && (Lv == 0))) {
	mexErrMsgTxt("Filter coefficient vector cannot be empty.");
    }
    /*
     *  Check sizes of input and filter:
     */
    if (isIIR && !V_is_scalar) {
	if ((kh != 1) || (kv != 1)) {
	    mexErrMsgTxt("K and V must be vectors for IIR lattice-ladders.");
	}
    } else {
	if ( (kx != 1) && (kh != 1) && (kx != kh) ) {
	    mexErrMsgTxt("X and K must have the same number of columns "
			 "if both are non-vectors.");
	}
    }
    /*
     *  Verify that 1 <= Lv <= Lh+1
     *  (We already know that Lv >= 1 due to empty-check above)
     */
    if (Lv > Lh+1) {
	mexErrMsgTxt("For IIR lattice-ladders, length(V) must be <= 1+length(K).");
    }


    /*
     * Determine result matrix size:
     */
    ky = max(max(kx,kh),kv);  /* kv better be set, even if V not passed!      */
    Ly = Lx;                  /* # samples in filter output, per input signal */
    if( x_is_row && (ky == 1) ) {
        my = 1;  /* ky */
	ny = Ly;
    } else {
        my = Ly;
	ny = ky;
    }

    /*
     * Determine lattice buffer size:
     */
    Ld = isIIR ? Lh+1 : Lh;  /* FIR requires Lh taps, IIR requires Lh+1 */
    if (isComplex) Ld *= 2;      /* Double it for complex inputs/coeffs     */
    D = (double *)mxCalloc(Ld, sizeof(double));

    /*
     * Allocate outputs:
     */
    F_OUT = mxCreateDoubleMatrix(my, ny, isComplex ? mxCOMPLEX : mxREAL);
    ff  = (double *)mxGetPr(F_OUT);
    ffi = (double *)mxGetPi(F_OUT);
    if (nlhs > 1) {
	G_OUT = mxCreateDoubleMatrix(my, ny, isComplex ? mxCOMPLEX : mxREAL);	
	gg  = (double *)mxGetPr(G_OUT);
	ggi = (double *)mxGetPi(G_OUT);
    } else {
	gg = ggi = NULL;
    }

    /*
     *  Execute filter:
     */
    if (isComplex) {
	/*
	 *  Input and/or filter is complex
	 */
	if (isIIR) {
	    Complex_IIR_Lattice(ff,ffi, gg,ggi, Ly, ky,
				xx,xxi, Lx, kx,
				hh,hhi, Lh, kh,
				vv,vvi, Lv, kv, D);
	} else {
	    Complex_FIR_Lattice(ff,ffi, gg,ggi, Ly, ky,
				xx,xxi, Lx, kx,
				hh,hhi, Lh, kh, D);
	}
    } else {
	/*
	 * Input and filters are both purely real
	 */
	if (isIIR) {
	    Real_IIR_Lattice(ff, gg, Ly, ky,
			     xx, Lx, kx,
			     hh, Lh, kh,
			     vv, Lv, kv, D);
	} else {
	    Real_FIR_Lattice(ff, gg, Ly, ky,
			     xx, Lx, kx,
			     hh, Lh, kh, D);
	}
    }

    /* Clean up allocation: */
    mxFree(D);

    /*
     * Report flop count:
     */
    {
	int flopMul, flopAdd, mpy;

	if (isIIR) {
	    /*
	     * IIR:
	     *   Lattice-only: (adds/muls)
	     *         2/2, 4/4 if x is complex, 8/8 if k and x are complex
	     *   Lattice-ladder:
	     *         Additional 1/1, 2/2, or 4/4
	     */
	    mpy = 2;
	    if (xIsComplex) mpy *= 2;
	    if (hIsComplex) mpy *= 2;
       	    flopAdd = mpy * Lh*Ly*ky;         /* Lattice */
	    flopAdd += (mpy/2) * Lv*Ly*ky;    /* Ladder  */
	    flopMul = flopAdd;

	} else {
	    /*
	     * FIR: 2/2 (2 adds and 2 muls) per stage, per output sample, per column
	     *      4/4 if x is complex,
	     *      8/8 if x and h are complex (algorithm never has just h complex)
	     */
	    mpy = 2;
	    if (xIsComplex) mpy *= 2;
	    if (hIsComplex) mpy *= 2;
       	    flopMul = flopAdd = mpy*Lh*Ly*ky;
	}

	/* Update flop count: */
        mexAddFlops(flopAdd+flopMul);
    }
    return;
}
