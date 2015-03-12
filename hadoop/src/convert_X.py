import numpy as np
import typedbytes as tb
import sys

num_reducers = int(sys.argv[2])

tau_vec = []
s_vec   = []
values  = []

for i in range(num_reducers):
  fn = sys.argv[1] + '/X_000%02d.tb' %i
  reader = tb.Input(open(fn, 'rb')).reads()
  for key in reader:
    tau_vec += [0.5, 0.75, 0.95]
    s_vec.append(key[1])
    values += reader.next()

X = np.array(values).T

m, n = X.shape
X = np.vstack([X, -np.ones([1, n])])

np.savetxt(sys.argv[1]+'/sv.txt', s_vec)
np.savetxt(sys.argv[1]+'/tv.txt', tau_vec)
np.savetxt(sys.argv[1]+'/X.txt', X)

