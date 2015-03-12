import numpy as np
import typedbytes as tb
import sys

num_reducers = int(sys.argv[2])

values  = []

for i in range(num_reducers):
  fn = sys.argv[1] + '/F_000%02d.tb' %i
  reader = tb.Input(open(fn, 'rb')).reads()
  for key in reader:
    if key == "F":
      F = reader.next()

np.savetxt(sys.argv[1]+'/F.txt', F)

