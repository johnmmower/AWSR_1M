/*
 * adapted from
 * https://github.com/Xilinx/embeddedsw/blob/master/XilinxProcessorIPLib/drivers/rfdc/examples/
 */

#ifndef _ZCU111_CLOCK_H_
#define _ZCU111_CLOCK_H_

#include "zcu111_clock_config.h"

void LMK04208ClockConfig(unsigned int LMK04208_CKin[LMK04208_count]);
void LMX2594ClockConfig(unsigned int LMX2594_CKins[3][LMX2594_count]);

#endif
