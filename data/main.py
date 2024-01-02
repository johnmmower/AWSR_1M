#! /usr/bin/env python3

import mmap
import numpy as np
from matplotlib.pyplot import *
import threading
import time

from dma import DMA
from controller import Controller, SAMPLES
from pulse import *

DMABASE = 0xA0060000
DSTBASE = 0xB0000000
DSTSIZE = 0x20000000
CTRBASE = 0xA0050000
PLSBASE = 0xA0040000
PLSSIZE = 0x00010000 // 2 # fix dts

pls = Pulse()

dev = open('/dev/mem', 'r+b')
dst = mmap.mmap(dev.fileno(), DSTSIZE, offset=DSTBASE)
src = mmap.mmap(dev.fileno(), PLSSIZE, offset=PLSBASE)

pulse = pls.getPulse()
pc = np.zeros(PLSSIZE//2, dtype=np.int16)
sc = np.zeros(len(pulse)*2, dtype=np.int16)
sc[1::2] = np.real(pulse).astype(np.int16)
sc[0::2] = np.imag(pulse).astype(np.int16)
pc[0:len(sc)] = sc
src[0:len(pc)*2] = pc.tostring()

stall = True
N = 0
lock = threading.Lock()

def pollDma():
    global stall
    global N
    dma = DMA(DMABASE)
    while True:
        with lock:
            if not stall:
                break
            time.sleep(.1)
    N = dma.s2mm_poll(DSTBASE)

    
cnt = Controller(CTRBASE)
cnt.prepare()
t = threading.Thread(target=pollDma)
t.start()
with lock:
    stall = False
time.sleep(.5)
cnt.start()
t.join()
cnt.halt()

print(N)

rx = np.fromstring(dst[16:N-16], dtype=np.int16)
rx = rx[0::2] + 1j * rx[1::2]

src.close()
dst.close()
dev.close()

with open('data.npy', 'wb') as f:
    np.save(f, pulse)
    np.save(f, rx)

