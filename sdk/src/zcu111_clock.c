/*
 * adapted from
 * https://github.com/Xilinx/embeddedsw/blob/master/XilinxProcessorIPLib/drivers/rfdc/examples/
 */

#include "zcu111_clock.h"

#include <xiicps.h>
#include <sleep.h>

#define I2CBUS	1

XIicPs Iic;

void LMK04208ClockConfig(unsigned int LMK04208_CKin[LMK04208_count])
{
	XIicPs_Config *Config_iic;
	int Status;
	u8 tx_array[10];
	u8 rx_array[10];
	u32 ClkRate = 100000;
	int Index;

	Config_iic = XIicPs_LookupConfig(I2CBUS);
	if (NULL == Config_iic) {
		return;
	}

	Status = XIicPs_CfgInitialize(&Iic, Config_iic, Config_iic->BaseAddress);
	if (Status != XST_SUCCESS) {
		return;
	}

	Status = XIicPs_SetSClk(&Iic, ClkRate);
	if (Status != XST_SUCCESS) {
		return;
	}

	/*
	 * 0x02-enable Super clock module 0x20- analog I2C power module slaves
	 */
	tx_array[0] = 0x20;
	XIicPs_MasterSendPolled(&Iic, tx_array, 0x01, 0x74);
	while (XIicPs_BusIsBusy(&Iic))
		;
	usleep(25000);

	/*
	 * Receive the Data.
	 */
	Status = XIicPs_MasterRecvPolled(&Iic, rx_array, 1, 0x74);
	if (Status != XST_SUCCESS) {
		return;
	}

	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(&Iic))
		;


	/*
	 * Function Id.
	 */
	tx_array[0] = 0xF0;
	tx_array[1] = 0x02;
	XIicPs_MasterSendPolled(&Iic, tx_array, 0x02, 0x2F);
	while (XIicPs_BusIsBusy(&Iic))
		;
	usleep(25000);

	/*
	 * Receive the Data.
	 */
	Status = XIicPs_MasterRecvPolled(&Iic, rx_array,
			2, 0x2F);
	if (Status != XST_SUCCESS) {
		return;
	}

	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(&Iic));

	for (Index = 0; Index < LMK04208_count; Index++) {
		tx_array[0] = 0x02;
		tx_array[4] = (u8) (LMK04208_CKin[Index]) & (0xFF);
		tx_array[3] = (u8) (LMK04208_CKin[Index] >> 8) & (0xFF);
		tx_array[2] = (u8) (LMK04208_CKin[Index] >> 16) & (0xFF);
		tx_array[1] = (u8) (LMK04208_CKin[Index] >> 24) & (0xFF);
		Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x05, 0x2F);
		usleep(25000);
		while (XIicPs_BusIsBusy(&Iic))
			;
	}

	sleep(2);
}

void LMX2594ClockConfig(unsigned int LMX2594_CKins[3][LMX2594_count])
{
	XIicPs_Config *Config_iic;
	int Status;
	u8 tx_array[10];
	u8 rx_array[10];
	u32 ClkRate = 100000;
	int Index;

	Config_iic = XIicPs_LookupConfig(I2CBUS);
	if (NULL == Config_iic) {
		return;
	}

	Status = XIicPs_CfgInitialize(&Iic, Config_iic, Config_iic->BaseAddress);
	if (Status != XST_SUCCESS) {
		return;
	}

	Status = XIicPs_SetSClk(&Iic, ClkRate);
	if (Status != XST_SUCCESS) {
		return;
	}

	/*
	 * 0x02-enable Super clock module 0x20- analog I2C power module slaves
	 */
	tx_array[0] = 0x20;
	XIicPs_MasterSendPolled(&Iic, tx_array, 0x01, 0x74);
	while (XIicPs_BusIsBusy(&Iic))
		;
	usleep(25000);

	/*
	 * Receive the Data.
	 */
	Status = XIicPs_MasterRecvPolled(&Iic, rx_array, 1, 0x74);
	if (Status != XST_SUCCESS) {
		return;
	}

	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(&Iic))
		;

	/*
	 * Function Id.
	 */
	tx_array[0] = 0xF0;
	tx_array[1] = 0x02;
	XIicPs_MasterSendPolled(&Iic, tx_array, 0x02, 0x2F);
	while (XIicPs_BusIsBusy(&Iic))
		;
	usleep(25000);

	/*
	 * Receive the Data.
	 */
	Status = XIicPs_MasterRecvPolled(&Iic, rx_array,
			2, 0x2F);
	if (Status != XST_SUCCESS) {
		return;
	}

	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(&Iic));

	tx_array[0]=0x08;
	tx_array[3]=(u8) (0x00);
	tx_array[2]=(u8) (0x00);
	tx_array[1]=(u8) (0x20);
	Status = XIicPs_MasterSendPolled(&Iic,tx_array,0x04,0x2F);
	while (XIicPs_BusIsBusy(&Iic));

	sleep(2);

	tx_array[0]=0x08;
	tx_array[3]=(u8) (0x00);
	tx_array[2]=(u8) (0x00);
	tx_array[1]=(u8) (0x00);
	Status = XIicPs_MasterSendPolled(&Iic,tx_array,0x04,0x2F);
	while (XIicPs_BusIsBusy(&Iic));

	sleep(2);
	for (Index = 0; Index < LMX2594_count; Index++) {
		tx_array[0] = 0x08;
		tx_array[3] = (u8) (LMX2594_CKins[0][Index]) & (0xFF);
		tx_array[2] = (u8) (LMX2594_CKins[0][Index] >> 8) & (0xFF);
		tx_array[1] = (u8) (LMX2594_CKins[0][Index] >> 16) & (0xFF);
		Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
		while (XIicPs_BusIsBusy(&Iic))
			;
		usleep(25000);

	}

	tx_array[0] = 0x08;
	tx_array[3] = (u8) (LMX2594_CKins[0][112]) & (0xFF);
	tx_array[2] = (u8) (LMX2594_CKins[0][112] >> 8) & (0xFF);
	tx_array[1] = (u8) (LMX2594_CKins[0][112] >> 16) & (0xFF);
	Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
	while (XIicPs_BusIsBusy(&Iic))
		;
	usleep(25000);

	tx_array[0]=0x04;
	tx_array[3]=(u8) (0x00);
	tx_array[2]=(u8) (0x00);
	tx_array[1]=(u8) (0x02);
	Status = XIicPs_MasterSendPolled(&Iic,tx_array,0x04,0x2F);
	while (XIicPs_BusIsBusy(&Iic));

	sleep(2);
	tx_array[0]=0x04;
	tx_array[3]=(u8) (0x00);
	tx_array[2]=(u8) (0x00);
	tx_array[1]=(u8) (0x00);
	Status = XIicPs_MasterSendPolled(&Iic,tx_array,0x04,0x2F);
	while (XIicPs_BusIsBusy(&Iic));

	sleep(2);
	for (Index = 0; Index < LMX2594_count; Index++) {
		tx_array[0] = 0x04;
		tx_array[3] = (u8) (LMX2594_CKins[1][Index]) & (0xFF);
		tx_array[2] = (u8) (LMX2594_CKins[1][Index] >> 8) & (0xFF);
		tx_array[1] = (u8) (LMX2594_CKins[1][Index] >> 16) & (0xFF);
		Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
		while (XIicPs_BusIsBusy(&Iic))
			;
		usleep(25000);

	}

	tx_array[0]=0x04;
	tx_array[3] = (u8) (LMX2594_CKins[1][112]) & (0xFF);
	tx_array[2] = (u8) (LMX2594_CKins[1][112] >> 8) & (0xFF);
	tx_array[1] = (u8) (LMX2594_CKins[1][112] >> 16) & (0xFF);
	Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
	while (XIicPs_BusIsBusy(&Iic))
		;
	usleep(25000);

	tx_array[0]=0x01;
	tx_array[3]=(u8) (0x00);
	tx_array[2]=(u8) (0x00);
	tx_array[1]=(u8) (0x02);
	Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
	while (XIicPs_BusIsBusy(&Iic));
	sleep(2);

	tx_array[0]=0x01;
	tx_array[3]=(u8) (0x00);
	tx_array[2]=(u8) (0x00);
	tx_array[1]=(u8) (0x00);
	Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
	while (XIicPs_BusIsBusy(&Iic));
	sleep(2);

	for (Index = 0; Index < LMX2594_count; Index++) {
		tx_array[0] = 0x01;
		tx_array[3] = (u8) (LMX2594_CKins[2][Index]) & (0xFF);
		tx_array[2] = (u8) (LMX2594_CKins[2][Index]>> 8) & (0xFF);
		tx_array[1] = (u8) (LMX2594_CKins[2][Index]>> 16) & (0xFF);
		Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
		while (XIicPs_BusIsBusy(&Iic))
			;
		usleep(25000);
	}

	tx_array[0] = 0x01;
	tx_array[3] = (u8) (LMX2594_CKins[2][112]) & (0xFF);
	tx_array[2] = (u8) (LMX2594_CKins[2][112] >> 8) & (0xFF);
	tx_array[1] = (u8) (LMX2594_CKins[2][112] >> 16) & (0xFF);
	Status = XIicPs_MasterSendPolled(&Iic, tx_array, 0x04, 0x2F);
	while (XIicPs_BusIsBusy(&Iic))
		;
	usleep(25000);
}




