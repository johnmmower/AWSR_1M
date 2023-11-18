
import numpy as np
#from matplotlib.pyplot import *
import mmap

RMBASE = 0xA0040000
RMSIZE = 0x10000

MAXLEN = 8192

T = 16*650e-9     # pulse leng
FS = 215.04e6  # sample pd.
BW = 150e6     # bandwidth

SCL = 2**15 - 100

n_r = int(round(T * FS))

if n_r > MAXLEN:
    print("error too long")
    exit()

f = np.linspace(-.5*BW, .5*BW, n_r)
p = 2 * np.pi * np.cumsum(f) / FS
s = np.exp(-1j * p)
s *= np.hamming(len(s))
s *= SCL
s_r = np.real(s).astype(np.int16)
s_i = np.imag(s).astype(np.int16)
s_c = np.zeros(n_r * 2, dtype=np.int16)
s_c[1::2] = s_r
s_c[0::2] = s_i

try:
    plot(s_r)
    plot(s_i)
    show()
except:
    print("no plot")

dev = open('/dev/mem', 'r+b')
mem = mmap.mmap(dev.fileno(), RMSIZE, offset=RMBASE)
mem[0:MAXLEN*4] = np.zeros(MAXLEN*2, dtype=np.int16).tostring()
mem[0:(len(s_c)*2)] = s_c.tostring()
    
