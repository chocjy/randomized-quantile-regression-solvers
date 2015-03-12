import numpy as np
#import scipy
import json as json
import typedbytes as tb

from utils import Block_Mapper

class Cauchy_Mapper(Block_Mapper):
    """
    Sparse Cauchy random projection
    """
    def __init__(self):
        Block_Mapper.__init__(self, 4096)
        self.As = None

    def parse(self, row):
        return [float(v) for v in row.split()]

    def process(self):
        A = np.array(self.data)
        m, n = A.shape
        t = int(np.ceil(2*n**2*(np.log(n))**2))
        rt = np.random.randint(t, size = m)
        C = np.random.standard_cauchy(m)

        #Pi = scipy.sparse.coo_matrix(C, (rt,range(m)), shape=(t,m))

        for i in range(m):
            yield rt[i], C[i] * A[i,:]

        #PA = np.zeros((t,n))
        #for i in range(m):
        #  PA[rt[i],:] += C[i] * A[i,:]

        #if self.As is None:
        #    self.As = PA
        #else:
        #    self.As += PA
        #return iter([])

    #def close(self):
    #    if self.As is not None:
    #        for i, row in enumerate(self.As):
    #            yield i, row

class Cauchy_Reducer:
    """
    Sparse Cauchy random projection
    """
    def __call__(self, key, values):
        #As = values.next()
        #for v in values:
        #    As += v
        #yield 'As', As
        row = values.next()
        for v in values:
            row += v
        yield key, row.tolist()

if __name__ == '__main__':
    import dumbo
    job = dumbo.Job()
    job.additer(Cauchy_Mapper, Cauchy_Reducer)
    job.run()
