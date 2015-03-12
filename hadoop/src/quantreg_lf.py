import numpy as np

def quantreg_lossfunc(X, tau_vec):
  m, n = X.shape
  Y = np.zeros((m, n))

  for i in range(n):
    for j in range(m):
      x = X[j,i]
      tau = tau_vec[i]
      if x > 0:
        Y[j,i] = tau * x
      else:
        Y[j,i] = (tau -1) * x
 
  result = np.sum(Y, 0)

  return result


if __name__ == "__main__":
    A = np.array(range(6)).reshape(3,2)
    tau_vec = [0.5, 0.75]
  
    result = quantreg_lossfunc(A, tau_vec)

    print result 

