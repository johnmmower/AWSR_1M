
import numpy as np
from matplotlib.pyplot import *
from scipy.io import savemat

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
rlorig = getFrame('rx_norf.dat')

tx = np.copy(txorig)

# fix phase
rx = np.conj(np.copy(rxorig))
rl = np.conj(np.copy(rlorig))

Ctxrx = np.correlate(tx, rx, mode='full')
txrxargmax = np.argmax(np.abs(Ctxrx))
txrxlag = len(rx) - txrxargmax - 1

Ctxrl = np.correlate(tx, rl, mode='full')
txrlargmax = np.argmax(np.abs(Ctxrl))
txrllag = len(rl) - txrlargmax - 1
                              
zpad = 20

tx = np.append(np.zeros(zpad, dtype=np.complex64), tx)
tx = np.append(tx, np.zeros(zpad, dtype=np.complex64))
rx = rx[(txrxlag-zpad)::]
rx = rx[0:len(tx)]
rl = rl[(txrllag-zpad)::]
rl = rl[0:len(tx)]

rx *= np.exp(1j*np.angle(Ctxrx[txrxargmax]))
rl *= np.exp(1j*np.angle(Ctxrl[txrlargmax]))

def rms(vals):
    return np.sqrt(np.sum(np.abs(vals)**2)/len(vals))

rx /= rms(rx)
tx /= rms(tx)
rl /= rms(rl)

savemat("data.mat", {'tx':tx, 'rx':rx, 'rl':rl, 'zpad':zpad})


