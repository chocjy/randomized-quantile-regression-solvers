import numpy as np
import typedbytes as tb
import sys

sum_norm = 0

fn = sys.argv[1] + '/partial_sums.tb' 
reader = tb.Input(open(fn, 'rb')).reads()
key = reader.next()
sum_norm = reader.next()

np.savetxt(sys.argv[1]+'/sum_lev.txt', np.array([sum_norm]))

