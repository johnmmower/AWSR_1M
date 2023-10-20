
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

  XRFdc_MultiConverter_Sync_Config ADC_Sync_Config;
  XRFdc_MultiConverter_Sync_Config DAC_Sync_Config;

  XRFdc_MultiConverter_Init(&DAC_Sync_Config, 0, 0, XRFDC_TILE_ID0);
  DAC_Sync_Config.Tiles = 0x3;
  Status = XRFdc_MultiConverter_Sync(RFdcInstPtr, XRFDC_DAC_TILE, &DAC_Sync_Config);
  if (Status == XRFDC_MTS_OK)
    printf("INFO : DAC Multi-Tile-Sync completed successfully\n");
  else{
    printf("ERROR : DAC Multi-Tile-Sync did not complete successfully. Error code is %u \n", Status);
    return XRFDC_FAILURE;
  }

  XRFdc_MultiConverter_Init(&ADC_Sync_Config, 0, 0, XRFDC_TILE_ID0);
  ADC_Sync_Config.Tiles = 0x1;
  Status = XRFdc_MultiConverter_Sync(RFdcInstPtr, XRFDC_ADC_TILE, &ADC_Sync_Config);
  if (Status == XRFDC_MTS_OK)
    printf("INFO : ADC Multi-Tile-Sync completed successfully\n");
  else{
    printf("ERROR : ADC Multi-Tile-Sync did not complete successfully. Error code is %u \n", Status);
    return XRFDC_FAILURE;
  }

  return XRFDC_SUCCESS;
  

  /*
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
  */
}


#endif

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
  
