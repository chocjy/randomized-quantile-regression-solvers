import numpy as np
import numpy.linalg as npl
import json as json
import typedbytes as tb

from quantreg import quantreg_ipm
from utils import Block_Mapper


class Sample_Mapper(Block_Mapper):
    """
    Random sampling
    """
    def __init__(self):
        #import os
        Block_Mapper.__init__(self, 16384)

        self.nx = float(self.params["nx"])
        self.ss = float(self.params["s"])

        fn = self.params["sl"]
        self.sum_lev = float(np.loadtxt(fn))
        fn = self.params["mtx"]
        self.N = np.loadtxt(fn)

    def parse(self, row):
        return [float(v) for v in row.split()]

    def process(self):
        As = np.array(self.data)
        m, n = As.shape
        #AN = npl.lstsq(self.R.T, As.T)[0].T  # solving A/R
        AN = np.dot(As, self.N)
        q = np.sum(np.abs(AN), 1)   # sum(q) < O(n^{2.5})

        p = q * self.ss / self.sum_lev
        p[p>1.0] = 1.0

        for k in xrange(self.nx):
            coins = np.random.rand(m)
            ii = coins < p
            yield k, np.dot(np.diag(1/p[ii]), As[ii,]).tolist()
                
    """
    def __call__(self, records):
        #result = [[float(v) for v in row.split()] for row in value]
        #result = [v[1] for v in records]
        #data = np.array(result)
        #if data.shape[1] < 50:
        q = []
        As = []

        for data in records:
            lr = data[1]
            q.append(lr[0])
            As.append(lr[1:])

        As = np.array(As)
        q  = np.array(q)
        m, n = As.shape
        p = q * self.ss / self.sum_norm
        p[p>1.0] = 1.0

        for j in xrange(self.ntau):
            for k in xrange(self.nx):
                for i in xrange(m):
                    coin = np.random.rand()
                    if coin < p[i]:
                        yield [k, self.tau_vec[j]], (As[i, :]/p[i]).tolist()
   
"""

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
    job = dumbo.Job()
    job.additer(Sample_Mapper, Solve_Reducer)
    job.run()

