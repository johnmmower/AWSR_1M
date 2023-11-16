
#include <stdio.h>

#include "zcu111_clock_setup.h"
#include "zcu111_xrfdc_iface.h"

void main()
{
  Zcu111ClockSetup();
  setupXrfdc();
}
