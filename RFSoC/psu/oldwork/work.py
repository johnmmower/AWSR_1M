
import numpy as np
from matplotlib.pyplot import *

def getFrame(fname):
    with open(fname, 'rb') as fid:
        Nbytes = fid.seek(0,2)
        fid.seek(0)
        dat = fid.read(Nbytes)
    dat = dat[16::]
    data = np.fromstring(dat, dtype=np.int16)
    return data[0::2] + 1j * data[1::2]

txorig = getFrame('tx.dat')
rxorig = getFrame('rx.dat')


plot(np.real(rxorig))
plot(np.imag(rxorig))
show()


'''
tx = np.copy(txorig)

# fix phase
rx = np.conj(np.copy(rxorig))

Ctxrx = np.correlate(txorig, np.conj(rxorig), mode='full')
cargmax = np.argmax(np.abs(Ctxrx))
lag = len(rx) - cargmax - 1
tx = np.append(np.zeros(lag, dtype=np.complex64), tx)
tx = np.append(tx, np.zeros(len(rx)-len(tx), dtype=np.complex64))

ang = np.angle(Ctxrx[cargmax])
rx *= np.exp(1j*ang)

rx = rx[tx!=np.abs(0)]
tx = tx[tx!=np.abs(0)]

def rms(vals):
    return np.sqrt(np.sum(np.abs(vals)**2)/len(vals))

rx /= rms(rx)
tx /= rms(tx)
RX = 20*np.log10(np.abs(rx))
TX = 20*np.log10(np.abs(tx))


figure(0)
plot(TX, np.angle(tx/rx), '*k')
axis([-30,10,-np.pi,np.pi])
title('AM-PM')
xlabel(r'TX [dB]')
ylabel(r'phase [$\pi$]')
show()

figure(2)
plot(np.arange(len(tx)), np.abs(tx),'k')
plot(np.arange(len(rx)), np.abs(rx),'r')
show()



figure(0)
plot(TX, RX,'*k')

figure(1)
plot(np.angle(tx[tx!=np.abs(0)]), np.angle(rx), '*k')

figure(2)
plot(np.arange(len(tx)), np.abs(tx),'k')
plot(np.arange(len(rx)), np.abs(rx),'r')

figure(3)
FS = 215.04
f = np.linspace(-.5*FS,.5*FS,len(tx))
FRX = 20*np.log10(np.abs(np.fft.fftshift(np.fft.fft(rx))))
FTX = 20*np.log10(np.abs(np.fft.fftshift(np.fft.fft(tx))))
plot(f,FTX,'k')
plot(f,FRX,'r')

show()
'''


