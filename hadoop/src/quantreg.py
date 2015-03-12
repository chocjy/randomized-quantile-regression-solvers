import numpy as np
import numpy.linalg as npl

def quantreg_ipm(A, b, tau):
    """
    IPM for quantile regression
    """
    from rqfnb import rqfnb
    
    n, p = A.shape
    rhs  = np.sum(A, 0)
    u    = np.ones(n)
    d    = np.ones(n)

    beta = 0.99995
    eps  = 1e-6

    wn   = 0.5 * np.ones([n, 9])
    wp   = np.zeros([p, p+3])
    nit  = np.zeros(3, np.int)
    info = 0

    wn_, wp_, nit_, info_ = rqfnb(A.T, -b, rhs*(1-tau), d, u, beta, eps, wn, wp, nit, info)
    x = -wp_[:,0].copy()
    
    return x

if __name__ == '__main__':
    n = 1000
    p = 10
    A       = np.random.randn(n, p)
    x_exact = np.random.rand(p)
    b       = np.dot(A, x_exact) + np.random.laplace(0.0, 1.0, n)
    tau     = 0.5
    tmp     = quantreg_ipm(A, b, tau)
    x1      = tmp[:,1]
    x2      = npl.lstsq(A, b)[0]
    print 'relerr_1: ', npl.norm(x1-x_exact)/npl.norm(x_exact)
    print 'relerr_2: ', npl.norm(x2-x_exact)/npl.norm(x_exact)
