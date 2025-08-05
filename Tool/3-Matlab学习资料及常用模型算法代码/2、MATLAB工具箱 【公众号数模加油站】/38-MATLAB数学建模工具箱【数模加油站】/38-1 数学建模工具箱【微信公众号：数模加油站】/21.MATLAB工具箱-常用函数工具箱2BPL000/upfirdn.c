/*

  UPFIRDN.C	  a MEX-file to perform multirate filtering
  
  The calling syntax is:

			y = upfirdn(x, h, p, q)


  Jim McClellan    21-Jan-95



  On PC platforms, must be compiled with /Alfw and /Gs option to generate
  proper code.
*/

/* $Revision: 1.9 $ */
/* Copyright (c) 1988-98 by The MathWorks, Inc. */

#include <math.h>
#include "mex.h"

/*
 * Input Arguments
 */
#define	X_IN	prhs[0]
#define	H_IN	prhs[1]
#define	P_IN	prhs[2]
#define	Q_IN	prhs[3]
/*
 * Output Arguments
 */
#define	Y_OUT	plhs[0]

#ifndef max
#define	max(A, B) ((A)>(B) ? (A) : (B))
#endif
#ifndef min
#define	min(A, B) ((A)<(B) ? (A) : (B))
#endif

/*
 * Determine the Greatest Common Denominator (GCD):
 */
int gcd(
   int a,
   int b
)
{
    int  t;
    while (b>0)  {
	t = b;
	b = a%b;
	a = t;
    }
    return(a);
}

/*
 * =================================================
 */
static void upfirdn(
    double y[],  unsigned int Ly,  unsigned int ky, 
    double x[],  unsigned int Lx,  unsigned int kx, 
    double h[],  unsigned int Lh,  unsigned int kh, 
    int p,
    int q
)
{
    int r, rpq_offset, k, Lg;
    int iv, ig, igv, iw;
    double  *pw;
    double  *pv, *pvend;
    double  *pvhi, *pvlo, *pvt;
    double  *pg, *pgend;
    double  *pghi, *pglo, *pgt;
    unsigned int kmax = max(kh,kx);

    iv  = q;
    ig  = iw = p;
    igv = p*q;

    for (k=0; k<kmax; k++) {
	pvend = x + Lx;
	pgend = h + Lh;

	for (r=0; r<p; r++) {
	    pw = y + r;
	    pg = h + ( (r*q)%p );
	    Lg = pgend - pg;
	    Lg = (Lg%p) ? Lg/p+1 : Lg/p ;
	    rpq_offset = (r*q)/p;
	    pv = x + rpq_offset;

	    /*
	     * PSEUDO-CODE for CONVOLUTION with GENERAL INCREMENTS:
	     *
	     *   w[n] = v[n] * g[n]
	     *
	     * Given:
	     *   pointers:   pg, pv, and pw
	     *   or arrays:  g[ ], v[ ], and w[ ]
	     *   increments: ig, iv, and iw
	     *   end points: h+Lh, x+Lx
	     */

   	    /*
	     * Region #1 (running onto the data):
	     */
	    pglo = pg;
	    pghi = pg + p*rpq_offset;
	    pvlo = x;
	    pvhi = pv;
	    while ((pvhi<pvend) && (pghi<pgend)) {
		double acc = 0.0;
		pvt = pvhi;
		pgt = pglo;
		while (pgt <= pghi) {
		    acc += (*pgt) * (*pvt--);
		    pgt += ig;
		}
		*pw  += acc;
		pw   += iw;
		pvhi += iv;
		pghi += igv;
	    }

	    /*
	     * Do we need to drain rest of signal?
	     */
	    if (pvhi < pvend)  {
		/*
		 * Region #2 (complete overlap):
		 */
		while (pghi >= pgend) {
		    pghi -= ig;
		}
		while (pvhi < pvend)  {
		    double acc = 0.0;
		    pvt = pvhi;
		    pgt = pglo;
		    while (pgt <= pghi) {
			acc += (*pgt) * (*pvt--);
			pgt += ig;
		    }
		    *pw  += acc;
		    pw   += iw;
		    pvhi += iv;
		}

	    } else if (pghi < pgend)  {
		/*
		 * Region #2a (drain out the filter):
		 */
		while (pghi < pgend)  {
		    double acc = 0.0;
		    pvt = pvlo;     /* pvlo is still equal to x */
		    pgt = pghi;
		    while( pvt < pvend ) {
			acc += (*pgt) * (*pvt++);
			pgt -= ig;
		    }
		    *pw += acc;
		    pw += iw;
		    pghi += igv;
		    pvhi += iv;
		}
	    }

	    while (pghi >= pgend) {
		pghi -= ig;
	    }
	    pvlo = pvhi - Lg + 1;

#ifdef USE_ASSERTIONS
	    mexPrintAssertion(pvlo>x,__FILE__,__LINE__);
#endif
	    while (pvlo < pvend)  {
		/*
		 *  Region #3 (running off the data):
		 */
		double acc = 0.0;
		pvt = pvlo;
		pgt = pghi;
		while (pvt < pvend) {
		    acc += (*pgt) * (*pvt++);
		    pgt -= ig;
		}
		*pw += acc;
		pw += iw;
		pvlo += iv;
	    }

	} /* end of r loop */

	/*
	 *  Prepare for next signal column:
	 */
	if (kx!=1) x+=Lx;
	if (kh!=1) h+=Lh;
	y += Ly;
    }
}

/*
 * =================================================
 */
void mexFunction(
    int           nlhs,
    mxArray       *plhs[],
    int	          nrhs,
    const mxArray *prhs[]
    )
{
    double   *yy,*yyi,  *xx,*xxi, *hh,*hhi;
    int      pp, qq, x_is_row, isComplex, xIsComplex, hIsComplex;
    unsigned int kk,
                 Lx, Lh, Ly,    /* Lengths           */
                 kx, kh, ky,    /* number of signals */
                 mx, mh, my,    /* # of rows         */
                 nx, nh, ny;    /* # of columns      */

    /*
     * Check for proper number of arguments:
     */
    if (nrhs<2) {
        mexErrMsgTxt("Too few input arguments");
    }
    if (nlhs>1) {
    	mexErrMsgTxt("Too many output arguments");
    }

    /*
     * Check the dimensions of X and H:
     */
    mx = mxGetM(X_IN);
    nx = mxGetN(X_IN);
    if (!mxIsDouble(X_IN) || (mxGetNumberOfDimensions(X_IN) != 2) || 
        mxIsSparse(X_IN) ) {
        mexErrMsgTxt("X must be a full 2D double-precision matrix.");
    }
    if (mxIsEmpty(X_IN)) {
        mexErrMsgTxt("X must be non-empty.");
    }
    x_is_row = (mx==1);
    Lx =  x_is_row ? nx : mx;
    kx =  x_is_row ? mx : nx;
    
    mh = mxGetM(H_IN);
    nh = mxGetN(H_IN);
    if (!mxIsDouble(H_IN) || (mxGetNumberOfDimensions(H_IN) != 2) || 
        mxIsSparse(H_IN) ) {
        mexErrMsgTxt("H must be a full 2D double-precision matrix.");
    }
    if (mxIsEmpty(H_IN)) {
        mexErrMsgTxt("H must be non-empty.");
    }
    Lh = (mh==1) ? nh : mh;
    kh = (mh==1) ? mh : nh;

    /*
     * Determine which inputs are complex:
     */
    xIsComplex = mxIsComplex(X_IN);
    hIsComplex = mxIsComplex(H_IN);
    isComplex = (xIsComplex || hIsComplex);

    /*
     * Get pointers to input and filter:
     */
    xx = (double *)mxGetPr(X_IN);
    hh = (double *)mxGetPr(H_IN);
    if (isComplex)  {
       xxi = (double *)mxGetPi(X_IN);
       hhi = (double *)mxGetPi(H_IN);
    }

    /*
     * Supply defaults for P and Q:
     */
    if (nrhs<4) {
	qq = 1;
    } else {
        if (!mxIsDouble(Q_IN)) {
            mexErrMsgTxt("Q must be a double-precision matrix.");
        }
        if (mxIsEmpty(Q_IN)) {
            mexErrMsgTxt("Q must be non-empty.");
        }
        qq = mxGetScalar(Q_IN);
    }
    if (nrhs<3) {
	pp = 1;
    } else {
        if (!mxIsDouble(P_IN))  {
            mexErrMsgTxt("P must be a double-precision matrix.");
        }
        if (mxIsEmpty(P_IN)) {
            mexErrMsgTxt("P must be non-empty.");
        }
        pp = mxGetScalar(P_IN);
    }
    if ( pp<1 || qq<1 ) {
    	mexErrMsgTxt("P and Q must be positive integers");
    }
    if (gcd(pp,qq) != 1) {
        char str[100];
        sprintf(str,"P and Q are not relatively prime"
                   " (greatest common factor = %d)\n", gcd(pp,qq));
        mexWarnMsgTxt( str );
    }

    /*
     *  Check sizes of input and filter:
     */
    if ((kx>1) && (kh>1) && (kx!=kh))  {
        mexErrMsgTxt("X and H must have same number of columns, if more than one");
    }
    ky = max(kx,kh);

    /*
     * Create return array:
     */
    Ly = pp*(Lx-1) + Lh;
    Ly = (Ly%qq) ? Ly/qq + 1 : Ly/qq ;

    if( x_is_row && (ky == 1) ) {
        my = 1;
	ny = Ly;
    } else {
        my = Ly;
	ny = ky;
    }

    if (isComplex) {
	/*
	 *  Input and/or filter is complex
	 */
	Y_OUT = mxCreateDoubleMatrix(my, ny, mxCOMPLEX);
	yy  = (double *)mxGetPr(Y_OUT);
	yyi = (double *)mxGetPi(Y_OUT);

	if (xIsComplex && hIsComplex) {
	    /*
	     * Both input and filter are complex.
	     *
	     * Real part of output:
	     */
	    upfirdn(yy, Ly, ky, xxi, Lx, kx, hhi, Lh, kh, pp, qq );
	    for (kk=0; kk < my*ny; kk++) {
		yy[kk] = -yy[kk];  /* account for j-squared */
	    }
	    upfirdn(yy, Ly, ky, xx,  Lx, kx, hh, Lh, kh, pp, qq );
	    /*
	     * Imaginary part of output:
	     */
	    upfirdn(yyi, Ly, ky, xxi, Lx, kx, hh, Lh, kh, pp, qq );
	    upfirdn(yyi, Ly, ky, xx, Lx, kx, hhi, Lh, kh, pp, qq );
	    
	} else if (xIsComplex) {
	    /*
	     * Just input is complex:
	     */
	    upfirdn(yy,  Ly, ky, xx,  Lx, kx, hh, Lh, kh, pp, qq );
	    upfirdn(yyi, Ly, ky, xxi, Lx, kx, hh, Lh, kh, pp, qq );
	} else {
	    /*
	     * Just filter is complex:
	     */
	    upfirdn(yy,  Ly, ky, xx, Lx, kx, hh,  Lh, kh, pp, qq );
	    upfirdn(yyi, Ly, ky, xx, Lx, kx, hhi, Lh, kh, pp, qq );
	}
	
    } else {
	/*
	 * Input and filters are both purely real
	 */
	Y_OUT = mxCreateDoubleMatrix(my, ny, mxREAL);
	yy = (double *)mxGetPr(Y_OUT);
	upfirdn( yy, Ly, ky, xx, Lx, kx, hh, Lh, kh, pp, qq );
    }
    
    /*
     * Report flop count:
     */
    {
	int flopCount, flopAdd, flopMul;
	int i;
	
	flopAdd = flopMul = 0;
	for (i=0; i<pp; i++) {
	    /*
	     * Assuming polyphase interpolator:
	     */
	    int Li = ((int)Lh - 1 - ((i*qq)%pp))/pp + 1;
	    flopAdd += max(((int)Lx-1),0)*max(Li-1,0);
	    flopMul += Li*Lx;
	}
	flopCount = (flopMul + flopAdd)/qq;      
	if (xIsComplex) flopCount*=2;
	if (hIsComplex) flopCount*=2;

        flopCount = flopCount*max(kh,kx);

	/* Update flop count: */
        mexAddFlops(flopCount);
    }
    return;
}
