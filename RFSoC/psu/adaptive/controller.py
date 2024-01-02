
import mmap
from struct import pack, unpack
from time import sleep

CONTROL_REG_OFF           = 0x00 # RW
RUNSTART_BIT   = 0
RUNTX_BIT      = 1
USEPA_BIT      = 2
RUNRX_CH0_BIT  = 3
RUNRX_CH1_BIT  = 4
RESET_FIFO_BIT = 5
ALLOW_CAL0_BIT = 6
ALLOW_CAL1_BIT = 7

STATUS_REG_OFF            = 0x04 # RO
BUF_ERR_CH0_BIT = 0
TRG_ERR_CH0_BIT = 1
BUF_ERR_CH1_BIT = 2
TRG_ERR_CH1_BIT = 3

NEXTSEC_REG_OFF           = 0x08 # RW
TXDELAYM1_REG_OFF         = 0x0C # RW
TXONM1_REG_OFF            = 0x10 # RW
PRFCNTM1_REG_OFF          = 0x14 # RW
INTCNTM1_ANTSEQ_REG_OFF   = 0x18 # RW < intcntm1, 8'b0, antseq >
AZI_REG_OFF               = 0x1C # RW < hghazi, lowazi >
CFG_REG_OFF               = 0x20 # RW < 16'b0, cfg >
SAMPSM1_SAMPS_CH0_REG_OFF = 0x24 # RW < sampsm1, samps >
SHIFT_CH0_REG_OFF         = 0x28 # RW < 16'b0, shift >
DELAYM1_CH0_REG_OFF       = 0x2C # RW
SAMPSM1_SAMPS_CH1_REG_OFF = 0x30 # RW < sampsm1, samps >
SHIFT_CH1_REG_OFF         = 0x34 # RW < 16'b0, shift >
DELAYM1_CH1_REG_OFF       = 0x38 # RW

CH1_CH0_MAXLEN_REG_OFF    = 0x3C # RO < ch1_len, ch0_len >

BUILDTIME_REG_OFF         = 0x40 # RO     

FS = 215.04e6
PRF = 4000
TXDELAY = 1e-6
TXONOVER = 0e-6
PULSEDURATION = 2e-6
CONFIG = 0xBABE
SAMPLES = int((TXDELAY+TXONOVER+PULSEDURATION)*1.25*FS)
INT = 8192
SHIFT = 1 << 9

def getHwBuildStr(ts):
    secs = ts & 0x3F
    mins = (ts >> 6) & 0x3F
    hours = (ts >> 12) & 0x1F
    years = (ts >> 17) & 0x3F
    months = (ts >> 23) & 0xF
    days = (ts >> 27) & 0x1F
    return "20%02d%02d%02d-%02d%02d%02d" % (years, months, days, hours, mins, secs)

class Controller(object):

    def __init__(self, base):
        self.dev = open('/dev/mem', 'r+b')
        self.mem = mmap.mmap(dev.fileno(), 64*1024, offset=base)
        self.setup()

    def __del__(self):
        self.halt()
        self.mem.close()
        self.dev.close()

    def halt(self):
        self.writeReg(CONTROL_REG_OFF, 0)

    def prepare(self):
        cntrl = (1 << RESET_FIFO_BIT)
        self.writeReg(CONTROL_REG_OFF, cntrl)
        cntrl = (1 << RUNTX_BIT) | (1 << USEPA_BIT) | (1 << RUNRX_CH0_BIT)
        self.writeReg(CONTROL_REG_OFF, cntrl)

    def start(self):
        cntrl = self.readReg(CONTROL_REG_OFF)
        cntrl |= (1 << RUNSTART_BIT)
        writeReg(CONTROL_REG_OFF, cntrl)
                
    def getHwDate(self):
        return getHwBuildStr(self.readReg(BUILDTIME_REG_OFF)))
        
    def setup(self):
        self.halt()
        # set txdelaym1, ~500ns
        txdelaym1 = int(round(FS*TXDELAY)-1)
        self.writeReg(TXDELAYM1_REG_OFF, txdelaym1)
        # set txonm1, txdelay + pulse + 100ns
        txonm1 = txdelaym1 + int(round((PULSEDURATION+TXONOVER)*FS))
        self.writeReg(TXONM1_REG_OFF, txonm1)
        # set prf
        prfm1 = int(round(FS/PRF)-1) 
        self.writeReg(PRFCNTM1_REG_OFF, prfm1)
        # set intcntm1 and antseq  CAREFUL
        self.writeReg(INTCNTM1_ANTSEQ_REG_OFF, (INT - 1) << 16)
        # set azi CAREFUL
        self.writeReg(AZI_REG_OFF, 0)
        # set config
        self.writeReg(CFG_REG_OFF, CONFIG)
        # set samples
        self.writeReg(SAMPSM1_SAMPS_CH0_REG_OFF, ((SAMPLES-1) << 16) | SAMPLES)
        # set shift
        self.writeReg(SHIFT_CH0_REG_OFF, SHIFT)
        # set rx delay, none
        self.writeReg(DELAYM1_CH0_REG_OFF, 15)
        
    def readReg(self, offset):
        return unpack('<I', self.mem[offset:offset+4])[0]

    def writeReg(self, offset, data):
        self.mem[offset:offset+4] = pack('<I', data)
