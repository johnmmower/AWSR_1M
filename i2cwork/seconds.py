
import mmap
from struct import pack
import time

BASE = 0xA0050000
SIZE = 0x80

dev = open('/dev/mem', 'r+b')
mem = mmap.mmap(dev.fileno(), SIZE, offset=BASE)

lst = int(time.time())
while True:
    try:
        nws = int(time.time())
        if (lst != nws):
            time.sleep(0.5)
            nxtsec = (nws + 1) & 0xFFFFFFFF
            mem[8:12] = pack('<I', nxtsec)
            print("wrote next sec %d" % nxtsec)
        lst = nws
        time.sleep(0.1)
    except KeyboardInterrupt:
        break

mem.close()
dev.close()


        



