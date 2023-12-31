#! /usr/bin/env python3

import numpy as np
#from matplotlib.pyplot import *
from scipy.signal import firwin
import mmap

PULSE = False
CW = False
RND = True

RMBASE = 0xA0040000
RMSIZE = 0x10000

MAXLEN = 8192

T = 30e-6     # pulse leng
FS = 215.04e6  # sample pd.
BW = 150e6     # bandwidth
NTAPS = 101

SCL = 2**15 - 100

n_r = int(round(T * FS))
if n_r > MAXLEN -32: #?
    print("error too long")
    exit()
print("pulse length %d" % n_r)

s_c = np.zeros(n_r * 2, dtype=np.int16)

if PULSE:
    f = np.linspace(-.5*BW, .5*BW, n_r)
    p = 2 * np.pi * np.cumsum(f) / FS
    s = np.exp(-1j * p)
    s *= np.hamming(len(s))
    s *= SCL
    scr = np.real(s).astype(np.int16)
    sci = np.imag(s).astype(np.int16)
    s_c[1::2] = scr
    s_c[0::2] = sci
elif CW:
    scr = ((SCL / np.sqrt(2)) * np.ones(n_r)).astype(np.int16)
    sci = ((SCL / np.sqrt(2)) * np.ones(n_r)).astype(np.int16)
    s_c[0::2] = sci
    s_c[1::2] = scr
else:
    np.random.seed(0)
    s_r = np.random.randn(n_r)
    s_i = np.random.randn(n_r)
    taps = firwin(NTAPS, FS/BW/2)
    s_r = np.convolve(s_r, taps, mode='same')
    s_i = np.convolve(s_i, taps, mode='same')
    s = np.zeros(n_r, dtype=np.complex64)
    s = s_r + 1j * s_i
    s *= SCL / np.max(np.abs(s))
    scr = (np.real(s)).astype(np.int16)
    sci = (np.imag(s)).astype(np.int16)
    s_c[0::2] = sci
    s_c[1::2] = scr

with open('tx.dat', 'wb') as fid:
    fid.write(s_c.tostring())
        
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

    
'''    
try:
    figure(0)
    plot(scr)
    plot(sci)
    axis([0,n_r,-SCL,SCL])
    xlabel('tick [%.02f ns]' % (1/FS/1e-9))
    ylabel('magnitude')
    title('complex signal')

    figure(1)
    f = np.linspace(-.5*FS, .5*FS, n_r)
    s = np.complex64(scr + 1j*sci)
    S = 20*np.log10(np.abs(np.fft.fftshift(np.fft.fft(s * np.hamming(n_r)))))
    plot(f/1e6, S, 'k')
    axis([-FS/1e6/2, FS/1e6/2, np.max(S)-80, np.max(S)+10])
    xlabel('freq. [MHz]')
    ylabel('mag. [dBr]')
    title('signal spectrum')
    show()
except:
    print("no plot")
'''
