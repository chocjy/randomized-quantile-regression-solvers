import numpy as np
import numpy.linalg as npl
import json as json
import typedbytes as tb

from utils import Block_Mapper


class Sample_Mapper(Block_Mapper):
    """
    Random sampling
    """
    def __init__(self):
        #import os
        Block_Mapper.__init__(self, 32768)

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

        ss = 2*n**3*np.log(n)**2
        p = q * ss / self.sum_lev
        p[p>1.0] = 1.0

        for i in xrange(m):
            coin = np.random.rand()
            if coin < p[i]:
                yield i, (As[i, :]/p[i]).tolist()


class Sample_Reducer:
    def __call__(self, key, values):
        data = [v for v in values]
        SAb = np.array(data)
        
        yield key, SAb.tolist()

if __name__ == '__main__':
    import dumbo
    job = dumbo.Job()
    job.additer(Sample_Mapper, Sample_Reducer)
    job.run()

