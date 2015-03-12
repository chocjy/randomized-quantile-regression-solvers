import numpy as np
import sys
from quantreg import quantreg_ipm
from quantreg_lf import quantreg_lossfunc

if __name__ == "__main__":
    Ab = np.loadtxt(sys.argv[1])
    A  = Ab[:,:-1]
    b  = Ab[:,-1]
    tau_vec = [0.5, 0.75, 0.95]
    
    X  = quantreg_ipm(A, b, tau_vec)
    X  = np.vstack([X, -np.ones(len(tau_vec))])
    np.savetxt(sys.argv[2], X) 
    
    F = quantreg_lossfunc(-np.dot(Ab,X), tau_vec)
    np.savetxt(sys.argv[3], F)

