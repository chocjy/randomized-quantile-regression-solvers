import numpy as np
import numpy.linalg as npl
import json as json
import typedbytes as tb

from utils import Block_Mapper
from quantreg_lf import quantreg_lossfunc

class Quant_Func_Mapper(Block_Mapper):
    def __init__(self):
        import os
        Block_Mapper.__init__(self, 524288)
        fn1 = self.params["X"]
        fn2 = self.params["tau_vec"]
        self.X = np.loadtxt(fn1)
        self.tau_vec = np.loadtxt(fn2)
        if self.X.ndim == 1:
            n, = self.X.shape
            self.F = 0
        else:
            n, nx = self.X.shape
            self.F = np.zeros(nx)
        
    def parse(self, row):
        return [float(v) for v in row.split()]

    def process(self):
        #if self.sz == 0:
        #    return iter([])
        As = np.array(self.data)
        AX = np.dot(As, self.X)
        self.F += quantreg_lossfunc(-AX, self.tau_vec)
        return iter([])

    def close(self):
        rd = np.random.random() * 100
        key = np.ceil(rd)
        yield key, self.F

class Quant_Func_Reducer:
    def __call__(self, key, values):
        F = values.next()
        for v in values:
            F += v
        yield key, F

class Sum_Mapper:
    def __call__(self, records):
        F = records.next()[1]
        for row in records:
            F += row[1]

        yield 'F', F

class Sum_Reducer:
    def __call__(self, key, values):
        F = values.next()
        for v in values:
            F += v
        yield key, F.tolist()


if __name__ == '__main__':
    import dumbo
    job = dumbo.Job()
    job.additer(Quant_Func_Mapper, Quant_Func_Reducer)
    job.additer(Sum_Mapper, Sum_Reducer)
    job.run()
    
