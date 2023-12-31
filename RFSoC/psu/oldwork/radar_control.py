#! /usr/bin/env python3

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

STATUS_REG_OFF            = 0x04 # RO                                                                                             
BUF_ERR_CH0_BIT = 0
TRG_ERR_CH0_BIT = 1
BUF_ERR_CH1_BIT = 2
TRG_ERR_CH1_BIT = 3

NEXTSEC_REG_OFF           = 0x08 # WO                                                                                             
TXDELAYM1_REG_OFF         = 0x0C # WO                                                                                             
TXONM1_REG_OFF            = 0x10 # WO                                                                                             
PRFCNTM1_REG_OFF          = 0x14 # WO                                                                                             
INTCNTM1_ANTSEQ_REG_OFF   = 0x18 # WO < intcntm1, 8'b0, antseq >                                                                  
AZI_REG_OFF               = 0x1C # WO < hghazi, lowazi >                                                                          
CFG_REG_OFF               = 0x20 # WO < 16'b0, cfg >                                                                              
SAMPSM1_SAMPS_CH0_REG_OFF = 0x24 # WO < sampsm1, samps >                                                                          
SHIFT_CH0_REG_OFF         = 0x28 # WO < 16'b0, shift >                                                                            
DELAYM1_CH0_REG_OFF       = 0x2C # WO                                                                                             
SAMPSM1_SAMPS_CH1_REG_OFF = 0x30 # WO < sampsm1, samps >                                                                          
SHIFT_CH1_REG_OFF         = 0x34 # WO < 16'b0, shift >                                                                            
DELAYM1_CH1_REG_OFF       = 0x38 # WO                                                                                             
CH1_CH0_MAXLEN_REG_OFF    = 0x3C # RO < ch1_len, ch0_len >                                                                        
BUILDTIME_REG_OFF         = 0x40 # RO     

REG_ADDRESS = 0xA0050000

FS = 215.04e6
PRF = 4000
TXDELAY = 2e-6
TXONOVER = 2e-6
PULSEDURATION = 40e-6
CONFIG = 0xBABE
SAMPLES = 10000
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


dev = open('/dev/mem', 'r+b')
mem = mmap.mmap(dev.fileno(), 64*1024, offset=REG_ADDRESS)

def readReg(offset):
    return unpack('<I', mem[offset:offset+4])[0]

def writeReg(offset, data):
    mem[offset:offset+4] = pack('<I', data)

# ensure stop
writeReg(CONTROL_REG_OFF, 0)
    
print("build date: %s" % getHwBuildStr(readReg(BUILDTIME_REG_OFF)))

# set txdelaym1, ~500ns
txdelaym1 = int(round(FS*TXDELAY)-1)
writeReg(TXDELAYM1_REG_OFF, txdelaym1)

# set txonm1, txdelay + pulse + 100ns
txonm1 = txdelaym1 + int(round((PULSEDURATION+TXONOVER)*FS))
writeReg(TXONM1_REG_OFF, txonm1)

# set prf
prfm1 = int(round(FS/PRF)-1) 
writeReg(PRFCNTM1_REG_OFF, prfm1)

# set intcntm1 and antseq  CAREFUL
writeReg(INTCNTM1_ANTSEQ_REG_OFF, (INT - 1) << 16)

# set azi CAREFUL
writeReg(AZI_REG_OFF, 0)

# set config
writeReg(CFG_REG_OFF, CONFIG)

# set samples
writeReg(SAMPSM1_SAMPS_CH0_REG_OFF, ((SAMPLES-1) << 16) | SAMPLES)

# set shift
writeReg(SHIFT_CH0_REG_OFF, SHIFT)

# set rx delay, none
writeReg(DELAYM1_CH0_REG_OFF, 15)

# setup start
cntrl = (1 << RESET_FIFO_BIT)
writeReg(CONTROL_REG_OFF, cntrl)
cntrl = (1 << RUNTX_BIT) | (1 << USEPA_BIT) | (1 << RUNRX_CH0_BIT)
writeReg(CONTROL_REG_OFF, cntrl)


print("enter to start")
input()

cntrl |= (1 << RUNSTART_BIT)
writeReg(CONTROL_REG_OFF, cntrl)

print("started, cntrl-C to stop")

while True:
    try:
        sleep(.25)
    except KeyboardInterrupt:
        break

writeReg(CONTROL_REG_OFF, 0)

mem.close()
dev.close()

