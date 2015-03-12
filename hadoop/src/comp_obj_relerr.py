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

    F_opt = np.loadtxt(opt_fn)
    F = np.loadtxt(file_dir + '/F/F.txt')

    n = len(F)

    ntau = 3
    nx = n/3

    relerr_obj_mat = np.zeros((nx, ntau))

    for i in range(ntau):
        for j in range(nx):
            f = F[j*ntau + i]
            f_opt = F_opt[i]

            relerr_obj_mat[j,i] = npl.norm(f-f_opt)/npl.norm(f_opt)

    quartiles_obj = np.zeros((2,ntau))

    for i in range(ntau):
        quartiles_obj[:,i] = ComputeQuartiles(relerr_obj_mat[:,i])

    np.savetxt(file_dir + '/quar_obj.txt', quartiles_obj)

