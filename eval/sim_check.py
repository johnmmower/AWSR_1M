
import numpy as np
from matplotlib.pyplot import *

Nmon = 16
N = 4096

ins = np.zeros((Nmon, N), dtype=np.complex64)
out = np.zeros(N, dtype=np.complex64)

for i in range(Nmon):
    with open("raw_%02d.dat" % i, "r") as fid:
        for n in range(N):
            l = fid.readline().split(',')
            v = float(l[0]) + 1j*float(l[1])
            ins[i,n] = v

with open("int.dat", "r") as fid:
    for n in range(N):
        l = fid.readline().split(',')
        v = float(l[0]) + 1j*float(l[1])
        out[n] = v

INS = np.zeros((Nmon,N))
for i in range(Nmon):
    INS[i] = 20*np.log10(np.abs(np.fft.fftshift(np.fft.fft(ins[i]*np.hamming(N)))))
INS -= np.max(INS)
    
OUT = 20*np.log10(np.abs(np.fft.fftshift(np.fft.fft(out*np.hamming(N)))))
OUT -= np.max(OUT)

Fs = 215.04
f = np.linspace(-Fs/2, Fs/2, N)

for i in range(Nmon):
    plot(f, INS[i],'k')
plot(f, OUT, 'r')
axis([f[0], f[-1], -65, 5])
show()
