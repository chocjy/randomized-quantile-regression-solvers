import numpy as np
import numpy.linalg as npl
import json as json
import typedbytes as tb

from utils import Block_Mapper
from quantreg import quantreg_ipm


class Unif_Samp_Mapper(Block_Mapper):
    """
    Random sampling uniformly
    """
    def __init__(self):
        import os
        Block_Mapper.__init__(self, 32768)

        self.nx = float(self.params["nx"])
        self.ss = float(self.params["s"])
        self.size = float(self.params["num_row"])

    def parse(self, row):
        return [float(v) for v in row.split()]

    def process(self):
        As = np.array(self.data)
        m, n = As.shape

        p = np.ones(m) / self.size * self.ss
        for k in xrange(self.nx):
            coins = np.random.rand(m)
            ii = coins < p
            yield k, np.dot(np.diag(1/p[ii]), As[ii,]).tolist()


class Solve_Reducer:
    """
    Solve the subproblem
    """
    def __init__(self):
        self.tau_vec = [0.5, 0.75, 0.95]
        self.ntau = len(self.tau_vec)

    def __call__(self, key, values):
        #SAb = np.array([v for v in values])

        data = []
        for v in values:
            data += v

        SAb = np.array(data)
        m, n = SAb.shape

        x = np.zeros((n-1, self.ntau))
        for i in range(self.ntau):
            x[:,i] = quantreg_ipm(SAb[:,:n-1], SAb[:, n-1], self.tau_vec[i])

        key = [key, m]
        yield key, x.T.tolist()


if __name__ == '__main__':
    import dumbo
    dumbo.run(Unif_Samp_Mapper, Solve_Reducer)
