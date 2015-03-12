import numpy as np
import typedbytes as tb
import sys

num_reducers = int(sys.argv[2])

keys = []
data = []

for i in range(num_reducers):
  print i
  fn = sys.argv[1] + '/PA_000%02d.tb' %i 
  reader = tb.Input(open(fn, 'rb')).reads()
  for ind in reader:
    keys.append(ind)
    data += reader.next()

As = np.array(data)
print As.shape

R = np.linalg.qr(As, mode='r')
np.savetxt(sys.argv[1]+'/R.txt', R)

N = np.linalg.inv(R)
np.savetxt(sys.argv[1]+'/N.txt', N)


