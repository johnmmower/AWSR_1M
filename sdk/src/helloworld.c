
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#include "zcu111_clock.h"

int main()
{
    init_platform();

    print("Hello zcu111\n\r");

    LMK04208ClockConfig(LMK04208_CK_def);
    LMX2594ClockConfig(LMX2594_CKs_def);

    print("Success\n\r");
    cleanup_platform();
    return 0;
}
