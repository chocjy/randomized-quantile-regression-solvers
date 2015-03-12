import numpy as np
import numpy.linalg as npl
import sys

def ComputeQuartiles(arr):
    length = float(len(arr))
    order = np.argsort(arr)
    tmp = arr[order]
    ind = [round(length/4), round(3*length/4)]
    return tmp[ind]

if __name__ == "__main__":

    opt_fn = sys.argv[1]
    file_dir = sys.argv[2]

    X_opt = np.loadtxt(opt_fn)
    X = np.loadtxt(file_dir + '/X/X.txt')

    X = X[:-1,:]
    m, n = X.shape

    ntau = 3
    nx = n/3

    relerr_sol_l2_mat = np.zeros((nx, ntau))
    relerr_sol_l1_mat = np.zeros((nx, ntau))
    relerr_sol_inf_mat = np.zeros((nx, ntau))

    for i in range(ntau):
        for j in range(nx):
            x = X[:,j*ntau + i]
            x_opt = X_opt[:,i]

            relerr_sol_l2_mat[j,i] = npl.norm(x-x_opt)/npl.norm(x_opt)
            relerr_sol_l1_mat[j,i] = npl.norm(x-x_opt, 1)/npl.norm(x_opt, 1)
            relerr_sol_inf_mat[j,i] = npl.norm(x-x_opt, np.inf)/npl.norm(x_opt, np.inf)

    quartiles_sol_l2 = np.zeros((2,ntau))
    quartiles_sol_l1 = np.zeros((2,ntau))
    quartiles_sol_inf = np.zeros((2,ntau))

    for i in range(ntau):
        quartiles_sol_l2[:,i] = ComputeQuartiles(relerr_sol_l2_mat[:,i])
        quartiles_sol_l1[:,i] = ComputeQuartiles(relerr_sol_l1_mat[:,i])
        quartiles_sol_inf[:,i] = ComputeQuartiles(relerr_sol_inf_mat[:,i])

    np.savetxt(file_dir + '/quar_sol_l2.txt', quartiles_sol_l2)
    np.savetxt(file_dir + '/quar_sol_l1.txt', quartiles_sol_l1)
    np.savetxt(file_dir + '/quar_sol_inf.txt', quartiles_sol_inf)


