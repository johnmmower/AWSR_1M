
import numpy as np
from matplotlib.pyplot import *

fname = 'rx.dat'

with open(fname, 'rb') as fid:
    Nbytes = fid.seek(0,2)
    fid.seek(0)
    dat = fid.read(Nbytes)


data = dat[16::]
data = np.fromstring(data, dtype=np.int16)

data = data[0::2] + 1j * data[1::2]

plot(np.real(data));plot(np.imag(data));show()
