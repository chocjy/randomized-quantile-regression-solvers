import numpy as np
import numpy.linalg as npl
import json as json
import typedbytes as tb

from utils import Block_Mapper

class Const_Mapper(Block_Mapper):
    """
    Construct well-conditioned basis and compute the leverage scores
    """
    def __init__(self):
        import os
        Block_Mapper.__init__(self, 4096)
        fn = self.params["mtx"]
        self.N = np.loadtxt(fn)
        self.lambda_sum = 0

    def parse(self, row):
        return [float(v) for v in row.split()]

    def process(self):
        As = np.array(self.data)
        m, n = As.shape
        #AN = npl.lstsq(self.R.T, As.T)[0].T  # solving A/R
        AN = np.dot(As, self.N) 
        q = np.sum(np.abs(AN), 1)   # sum(q) < O(n^{2.5})
        self.lambda_sum += sum(q)
 
        return iter([])
  
    def close(self):
        yield "ps", self.lambda_sum


class Const_Reducer:
    def __call__(self, key, values):
        yield key, sum(values)
#        data = np.array([v for v in values])
#        yield key, data.tolist()

if __name__ == '__main__':
    import dumbo
    job = dumbo.Job()
    job.additer(Const_Mapper, Const_Reducer)
    job.run()

