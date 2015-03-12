import numpy as np
import sys

R = np.eye(int(sys.argv[2]))
np.savetxt(sys.argv[1]+'/R.txt', R)

