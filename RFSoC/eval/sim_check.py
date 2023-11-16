
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

SC = 0 #20*np.log10( N * N * np.sqrt(2) )
        
INS = np.zeros((Nmon,N))
for i in range(1):#(Nmon):
    INS[i] = 20*np.log10(np.abs(np.fft.fftshift(np.fft.fft(ins[i])))) - SC
#INS -= np.max(INS)
    
OUT = 20*np.log10(np.abs(np.fft.fftshift(np.fft.fft(out)))) - SC
#OUT -= np.max(OUT)

mx = np.ceil(max(np.max(INS), np.max(OUT))/5)*5
mn = mx - 50
ml = np.argmax(OUT)

Fs = 215.04
f = np.linspace(-Fs/2, Fs/2, N)

for i in range(Nmon):
    plot(f, INS[i],'k')
plot(f, OUT, 'r')
axis([f[0], f[-1], mn, mx])
annotate('%.1f dB' % np.max(OUT), xy=(f[ml], OUT[np.argmax(OUT)]), arrowprops=dict(arrowstyle='->'), xytext=(20, mx-5))
annotate('%.1f dB' % np.max(INS), xy=(f[ml], INS[0,np.argmax(INS[0])]), arrowprops=dict(arrowstyle='->'), xytext=(-35, mx-5))
xlabel('MHz')
ylabel('relative power dB')
show()
