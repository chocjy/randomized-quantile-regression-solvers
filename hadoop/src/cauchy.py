import numpy as np
import json as json
import typedbytes as tb

from utils import Block_Mapper

class Sparse_Cauchy_Mapper(Block_Mapper):
    """
    Cauchy random projection
    """
    def __init__(self):
        Block_Mapper.__init__(self, 1024)
        self.As = None

    def parse(self, row):
        return [float(v) for v in row.split()]

    def process(self):
        if self.sz == 0:
            return iter([])
        A = np.array(self.data)
        m, n = A.shape
        s = int(np.ceil(2*n*np.log(n)))
        C = np.random.standard_cauchy((s, m))
        if self.As is None:
            self.As  = np.dot(C, A)
        else:
            self.As += np.dot(C, A)
        return iter([])

    def close(self):
        if self.As is not None:
            for i, row in enumerate(self.As):
                yield i, row
            #yield 'As', self.As

class Sparse_Cauchy_Reducer:
    """
    Cauchy random projection
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
    job.additer(Sparse_Cauchy_Mapper, Sparse_Cauchy_Reducer)
    job.run()

