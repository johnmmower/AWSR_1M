
#ifndef _ZCU111_XRFDC_IFACE_H_
#define _ZCU111_XRFDC_IFACE_H_

#include <stdio.h>
#include <metal/sys.h>

#include <rfdc/xrfdc.h>

#define RFDCDEVICEID 0

#define XRFDC_ADC_TILE 0U
#define XRFDC_DAC_TILE 1U


int setupXrfdc()
{
  int Status;
  XRFdc RFdcInst;  
  struct metal_device *deviceptr = NULL;
  
  XRFdc_Config *ConfigPtr;

  struct metal_init_params init_param = METAL_INIT_DEFAULTS;
  XRFdc *RFdcInstPtr = &RFdcInst;
  
  if (metal_init(&init_param)) {
    printf("ERROR: Failed to run metal initialization\n");
    return XRFDC_FAILURE;
  }
  
  ConfigPtr = XRFdc_LookupConfig(RFDCDEVICEID);
  if (ConfigPtr == NULL) {
    printf("ERROR: Failed to lookup RFDC config\n");
    return XRFDC_FAILURE;
  }

  Status = XRFdc_RegisterMetal(RFdcInstPtr, RFDCDEVICEID, &deviceptr);
  if (Status != XRFDC_SUCCESS) {
    printf("ERROR: Failed to register metal\n");
    return XRFDC_FAILURE;
  }

  Status = XRFdc_CfgInitialize(RFdcInstPtr, ConfigPtr);
  if (Status != XRFDC_SUCCESS) {
    printf("ERROR: Failed to RFDC config init\n");
    return XRFDC_FAILURE;
  }

  Status = XRFdc_Reset(RFdcInstPtr, XRFDC_ADC_TILE, 0);
  if (Status != XRFDC_SUCCESS) {
    printf("ERROR: Failed rfdc reset adc\n");
    return XRFDC_FAILURE;
  }
  
  Status = XRFdc_Reset(RFdcInstPtr, XRFDC_DAC_TILE, 1);
  if (Status != XRFDC_SUCCESS) {
    printf("ERROR: Failed rfdc reset dac\n");
    return XRFDC_FAILURE;
  }

  //Status = XRFdc_SetupFIFO(RFdcInstPtr, XRFDC_DAC_TILE, 1, 1);

  /*
  Status = XRFdc_StartUp(RFdcInstPtr, XRFDC_ADC_TILE, -1);
  if (Status != XRFDC_SUCCESS) {
    printf("ERROR: Failed rfdc startup adc\n");
    return XRFDC_FAILURE;
  }
  
  Status = XRFdc_StartUp(RFdcInstPtr, XRFDC_DAC_TILE, -1);
  if (Status != XRFDC_SUCCESS) {
    printf("ERROR: Failed rfdc startup dac\n");
    return XRFDC_FAILURE;
  }
  */
  
}


#endif
