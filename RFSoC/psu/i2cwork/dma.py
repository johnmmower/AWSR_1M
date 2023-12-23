import numpy as np
import mmap
from struct import pack, unpack
import time

class DMA(object):

    def __init__(self, base):
        self.dev = open('/dev/mem', 'r+b')
        self.mem = mmap.mmap(self.dev.fileno(), 64*1024, offset=base)


    def __del__(self):
        self.mem[0x30:0x34] = pack('<I', 1 << 0)
        self.mem.close()
        self.dev.close()

    def s2mm_poll(self, dest):
        self.mem[0x30:0x34] = pack('<I', 1 << 2)
        while True:
            print('loop')
            time.sleep(.1)
            if not unpack('<I', self.mem[0x30:0x34])[0] & (1 << 2):
                break
        self.mem[0x30:0x34] = pack('<I', 1 << 0)
        self.mem[0x4C:0x50] = pack('<I', dest >> 32)
        self.mem[0x48:0x4C] = pack('<I', dest & 0xFFFFFFFF)
        self.mem[0x58:0x5C] = pack('<I', 2**26-1)
        while not unpack('<I', self.mem[0x34:0x38])[0] & (1<<1):
            pass
        return unpack('<I', self.mem[0x58:0x5C])[0]


if __name__ == "__main__":

    dmabase = 0xA0060000
    dstbase = 0xB0000000
    membase = 0xB0000000
    memsize = 0x20000000

    dev = open('/dev/mem', 'r+b')
    mem = mmap.mmap(dev.fileno(), memsize, offset=membase)
    #mem[0:8192] = np.zeros(4096, dtype=np.int16)
    
    dma = DMA(dmabase)
    N = dma.s2mm_poll(dstbase)

    time.sleep(1)
    
    with open('rx.dat', 'wb') as fid:
        fid.write(mem[0:N])
    
    print('done with %d bytes' % N)

    
