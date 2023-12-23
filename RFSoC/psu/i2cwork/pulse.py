
import numpy as np
#from matplotlib.pyplot import *
import mmap

CW = False

RMBASE = 0xA0040000
RMSIZE = 0x10000

MAXLEN = 8192

T = 1e-6     # pulse leng
FS = 215.04e6  # sample pd.
BW = 150e6     # bandwidth

SCL = 2**15 - 100
#SCL //= 10

if not CW:
    n_r = int(round(T * FS))

    if n_r > MAXLEN -32: #?
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

data = np.zeros(MAXLEN*2, dtype=np.int16)
    
if not CW:
    data[4:4+len(s_c)] = s_c
else:
    data[0::2] = SCL

mem[0:MAXLEN*4] = data.tostring()
    
mem.close()
dev.close()
