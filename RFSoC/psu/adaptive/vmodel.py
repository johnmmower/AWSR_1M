
import numpy as np
from matplotlib.pyplot import *
from pulse import *

class VModel(object):
    
    vars = np.array([
    0.0951,   -0.2569,    0.0465,   -0.0013,    0.3094,    0.0701,   -0.0229,   -0.0008,    0.2443,   -0.0534,
    0.0101,    0.0030,    0.3306,   -0.0043,    0.0073,    0.0001,    0.2758,    0.0229,    0.0018,   -0.0007,
    0.1105,    0.0422,   -0.0109,    0.0004,    0.4804,   -0.0702,    0.0382,   -0.0004,   -0.2864,   -0.0981,
    0.0173,    0.0020,   -0.2526,    0.0199,   -0.0001,   -0.0011,   -0.1491,   -0.0228,    0.0078,    0.0002,
    -0.1570,  -0.0188,    0.0001,   -0.0008,    0.0680,   -0.0115,   -0.0060,    0.0011,   -0.1609,   -0.0554,
    0.0131,    0.0039,    0.3293,    0.0578,   -0.0060,   -0.0016,    0.0119,   -0.0173,    0.0068,   -0.0002,
    0.0067,   -0.0010,    0.0063,   -0.0001,    0.1180,    0.0239,    0.0016,    0.0008,   -0.0196,    0.0144,
    0.0023,    0.0002,   -0.0655,   -0.0295,    0.0185,   -0.0020,    0.1388,   -0.0265,   -0.0096,    0.0016,
    -0.1596,  -0.0187,    0.0022,    0.0001,   -0.1010,    0.0054,   -0.0014,    0.0000,   -0.0726,   -0.0118,
    -0.0036,   0.0007,    0.0056,   -0.0151,   -0.0018,   -0.0004,    0.0454,   -0.0375,    0.0130,    0.0010,
    0.1636,    0.0049,    0.0075,    0.0013,    0.0178,   -0.0005,    0.0036,   -0.0009,   -0.0665,   -0.0016,
    0.0034,    0.0002,   -0.0029,    0.0148,    0.0025,   -0.0002,    0.0553,    0.0006,    0.0007,    0.0002,
    0.0731,    0.0243,   -0.0093,   -0.0015,    0.0692,   -0.0016,   -0.0025,   -0.0006,   -0.1077,   -0.0096,
    0.0015,    0.0004,   -0.0149,    0.0028,    0.0007,    0.0002,   -0.0562,   -0.0054,   -0.0018,    0.0001,
    -0.0542,  -0.0025,   -0.0005,   -0.0000
    ])

    Nlag = 6
    Npwr = 4
    
    def __init__(self):
        self.clear()

    def clear(self):
        self.mem = np.zeros(self.Nlag, dtype=np.complex64)

    def update(self, nv):
        self.mem[1::] = self.mem[0:self.Nlag-1]
        self.mem[0] = nv
        val = 0+0j
        for l in range(self.Nlag):
            for ll in range(self.Nlag):
                for k in range(self.Npwr):
                    coef = self.vars[ll * self.Npwr + l * self.Nlag * self.Npwr + k]
                    dtrm = self.mem[l]
                    ptrm = np.abs(self.mem[ll])**k
                    val += coef * dtrm * ptrm
        return val


if __name__ == "__main__":

    np.random.seed(0)
    
    T = 1e-6
    p = Pulse(T)
    v = VModel()
    v.clear()
    pads = 64

    Vnr = 500
    
    N = 10
    R = .5

    trials = np.zeros((N, len(p.getPulse())+2*pads), dtype=np.complex64)
    
    for t in range(N):
        print(t)
        a = p.getPulse()
        a /= 25000
        b = np.zeros(len(a)+2*pads, dtype=np.complex64)
        for i in range(len(a)):
            b[pads+i] = v.update(a[i])
        b += (np.max(np.abs(b))/Vnr) * (np.random.randn(len(b)) + 1j * np.random.randn(len(b)))
        b = np.conj(b)

        trials[t,:] = b
        
        p.massagePulse(b,rate=R)



def getCxx(vals):
    cxx = np.correlate(vals,vals,mode='full')
    CXX = 20*np.log10(np.abs(cxx))
    CXX -= np.max(CXX)
    return CXX

c = 3e8
FS = 215.04e6

gold = np.copy(p.golden)
gold = np.append(gold, np.zeros(len(trials[0])-len(gold), dtype=np.complex64))
gold /= 2 * rms(gold)
gscl = np.max(np.abs(gold))
gold /= gscl



figure(0)
l = []
tm = np.arange(0,len(gold)) / FS / 1e-6
for t in range(N):
    col = (.5*(N-t)/N, .5*(N-t)/N, .5*(N-t)/N)
    lw = 2 if t == (N-1) else 1
    trial = trials[t]
    trial /= 2 * rms(trial)
    trial /= gscl
    plot(tm, np.abs(trials[t]), color=col, lw=lw)
    l.append('trial %d' % (t+1))
plot(tm, np.abs(gold), '--k')
axis([0, 2, -.05, 1.05])
xlabel(r'time [$us$]')
ylabel('normalized magnitude')
title('transmitted pulse adaptation')
savefig('simulated_pulse.png')

figure(1)
dm = np.arange(-len(b)+1, len(b)) * c / FS / 2
l = []
for t in range(N):
    col = (.5*(N-t)/N, .5*(N-t)/N, .5*(N-t)/N)
    lw = 2 if t == (N-1) else 1
    plot(dm, getCxx(trials[t]), color=col, lw=lw)
    l.append('trial %d' % (t+1))

plot(dm, getCxx(gold), '--k')
l.append('exact')
legend(l, loc='upper left')
xlabel('meters')
ylabel('dB')
axis([-10,10,-75,5])
title(r'compressed response $R=%.02f$' % R)
savefig('simulated_response.png')

show()
