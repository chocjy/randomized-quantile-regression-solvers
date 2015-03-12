/**
 * @file   lpfnb.cpp
 * @author Xiangrui Meng <mengxr@stanford.edu>
 * @date   Fri Jan 20 16:24:12 2012
 * 
 * @brief  min c'x s.t. Ax=b, 0<=x<=u.
 * 
 * 
 */

#include <cstring>

#include "mex.h"
#include "matrix.h"

#include "blas.h"

#include "quantreg.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  if( nlhs != 2 )
    mexErrMsgTxt( "Two outputs required." );

  if( nrhs != 4 )
    mexErrMsgTxt( "Four inputs required." );

  double *c = mxGetPr(prhs[0]);
  double *A = mxGetPr(prhs[1]);
  double *b = mxGetPr(prhs[2]);
  double *u = mxGetPr(prhs[3]);
  
  long    p = mxGetM(prhs[1]);
  long    n = mxGetN(prhs[1]);

  if( mxGetM(prhs[0]) != n || mxGetN(prhs[0]) != 1
      || mxGetM(prhs[2]) != p || mxGetN(prhs[2]) != 1
      || mxGetM(prhs[3]) != n || mxGetN(prhs[3]) != 1 )
    mexErrMsgTxt( "Dimensions do not match." );

  plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
  double *x = mxGetPr(plhs[0]);

  plhs[1] = mxCreateDoubleMatrix(p,1,mxREAL);
  double *z = mxGetPr(plhs[1]);

  double beta = 0.99995;
  double eps  = 1e-6;

  double *wn = new double[n*9];
  double *wp = new double[p*(p+3)];
  double *d  = new double[n];

  long   *nit = new long[3];
  long    info;

  memset( wn, 0, sizeof(double)*9*n );
  for( long i=0; i<n; ++i )
    wn[i] = 0.5;

  for( long i=0; i<n; ++i )
    d[i] = 1.0;
  
  rqfnb_( &n, &p, A, c, b, d, u, &beta, &eps, wn, wp, nit, &info );

  long ONE = 1;
  dcopy_( &n, wn, &ONE, x, &ONE );
  dcopy_( &p, wp, &ONE, z, &ONE );
  
  delete[] wn;
  delete[] wp;
  delete[] d;
  delete[] nit;
}
