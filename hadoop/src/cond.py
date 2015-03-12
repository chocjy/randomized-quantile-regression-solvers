import numpy as np
import typedbytes as tb
import sys

num_reducers = int(sys.argv[2])

data = []
indices = []

for i in range(num_reducers):
  fn = sys.argv[1] + '/PA_000%02d.tb' %i 
  reader = tb.Input(open(fn, 'rb')).reads()
  for ind in reader:
    indices.append(ind)
    data.append(reader.next())

order = np.argsort(indices)
As = np.array(data)
As = As[order,:]

R = np.linalg.qr(As, mode='r')
np.savetxt(sys.argv[1]+'/R.txt', R)

N = np.linalg.inv(R)
np.savetxt(sys.argv[1]+'/N.txt', N)


