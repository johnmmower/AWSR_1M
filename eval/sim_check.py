
import numpy as np
from matplotlib.pyplot import *

fname = "sim.dat"

with open(fname, 'r') as fid:
    for N, line in enumerate(fid):
        pass

ins = np.zeros(N, dtype=np.complex)
out = np.zeros(N, dtype=np.complex)

with open(fname, 'r') as fid:
    for N, line in enumerate(fid):
        print(line)

    
