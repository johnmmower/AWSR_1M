
import numpy as np

SCLMAX = 2**15 - 100
FS = 215.04e6
BW = 150e6
MAXLEN = 8192
PAD = 32

CONJ = True

def rms(vals):
    return np.sqrt(np.sum(np.abs(vals)**2)/len(vals))

def getAligned(newdata, stable):
    if CONJ:
        rx = np.conj(newdata)
    else:
        rx = np.copy(newdata)
    tx = np.copy(stable)
    Ctxrx = np.correlate(tx, rx, mode='full')
    txrxargmax = np.argmax(np.abs(Ctxrx))
    txrxlag = len(rx) - txrxargmax - 1
    txrxphase = np.angle(Ctxrx[txrxargmax])
    rx = rx[txrxlag:len(tx)+txrxlag]
    rx *= np.exp(1j*txrxphase)
    rx /= rms(rx)
    tx /= rms(tx)
    return rx, tx
    

class Pulse(object):

    def __init__(self, T=1e-6):
        self.T = T
        self.nr = int(round(FS * T)) + 2 * PAD
        assert(self.nr < MAXLEN)
        self.pulse = np.zeros(self.nr + 2 * PAD, dtype=np.complex64)
        f = np.linspace(-.5*BW, .5*BW, self.nr)
        p = 2 * np.pi * np.cumsum(f) / FS
        self.pulse[PAD:PAD+self.nr] = np.exp(-1j*p)
        self.pulse[PAD:PAD+self.nr] *= np.hamming(self.nr)
        self.pulse *= SCLMAX
        self.golden = np.copy(self.pulse)

    def getPulse(self):
        return np.copy(self.pulse)
    
    def getRamPulse(self):
        sc = np.zeros(len(self.pulse)*2, dtype=np.int16)
        sc[1::2] = np.real(self.pulse).astype(np.int16)
        sc[0::2] = np.imag(self.pulse).astype(np.int16)
        return sc

    def massagePulse(self, newdata, rate=0.25):
        rx, tx = getAligned(newdata, self.golden)
        self.pulse /= rms(self.pulse)
        self.pulse += rate * (tx - rx)
        self.pulse *= SCLMAX / np.max(np.abs(self.pulse))
        

