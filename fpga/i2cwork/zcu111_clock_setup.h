
#ifndef _ZCU111_CLOCK_SETUP_H_
#define _ZCU111_CLOCK_SETUP_H_

#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <dirent.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>

#define XIIC_BLOCK_MAX	16
#define I2C_SMBUS_WRITE	0
#define I2C_SMBUS_I2C_BLOCK  6

#define IICBUS 1
#define IIC_LMK04028_ADDR 0x02
#define IIC_LMX2594_A_ADDR 0x08
#define IIC_LMX2594_B_ADDR 0x04
#define IIC_LMX2594_C_ADDR 0x01

#include "zcu111_clock_config.h"

static inline void IicWriteData(int XIicDevFile, unsigned char command,
				unsigned char length,
				const unsigned char *values)
{
  struct i2c_smbus_ioctl_data args;
  unsigned char Block[XIIC_BLOCK_MAX];
  int Index;
  for (Index = 1; Index <= length; Index++)
    Block[Index] = values[Index-1];
  Block[0] = length;
  args.read_write = I2C_SMBUS_WRITE;
  args.command = command;
  args.size = I2C_SMBUS_I2C_BLOCK;
  args.data = &Block;
  ioctl(XIicDevFile,I2C_SMBUS,&args);
}

void LMX2594ClockConfig(unsigned int LMX2594_CKins[3][LMX2594_count])
{
  int XIicDevFile;
  int Dev, Index;
  char XIicDevFilename[20];
  unsigned char tx_array[3];
  unsigned char commands[3] = {IIC_LMX2594_A_ADDR, IIC_LMX2594_B_ADDR, IIC_LMX2594_C_ADDR};
  
  sprintf(XIicDevFilename, "/dev/i2c-%d", IICBUS);
  XIicDevFile = open(XIicDevFilename, O_RDWR);

  ioctl(XIicDevFile, I2C_SLAVE_FORCE, 0x74);
  IicWriteData(XIicDevFile, 0x20, 0, tx_array);
  
  ioctl(XIicDevFile, I2C_SLAVE_FORCE, 0x2f);

  for(Dev=0; Dev<3; Dev++) {

    tx_array[2] = 0x2;
    tx_array[1] = 0;
    tx_array[0] = 0;
    IicWriteData(XIicDevFile, commands[Dev], 3, tx_array);
    usleep(100000);
    tx_array[2] = 0;
    IicWriteData(XIicDevFile, commands[Dev], 3, tx_array);
    usleep(100000);

    for(Index=0; Index<LMX2594_count; Index++) {
      tx_array[2] = (unsigned char)(LMX2594_CKins[Dev][Index] & 0xFF);
      tx_array[1] = (unsigned char)((LMX2594_CKins[Dev][Index] >> 8) & 0xFF);
      tx_array[0] = (unsigned char)((LMX2594_CKins[Dev][Index] >> 16) & 0xFF);
      IicWriteData(XIicDevFile, commands[Dev], 3, tx_array);
      usleep(1000);
    }
        
    usleep(100000);
    tx_array[2] = (unsigned char)((LMX2594_CKins[Dev][LMX2594_count-1] & 0xFF) | (1 << 3));
    IicWriteData(XIicDevFile, commands[Dev], 3, tx_array);
    /*
    usleep(100000);
    tx_array[2] = (unsigned char)(((LMX2594_CKins[Dev][LMX2594_count-1] & 0xFF) | (1 << 3)) & ~(1 << 14));
    IicWriteData(XIicDevFile, commands[Dev], 3, tx_array);
    */
  }

}

void LMK04208ClockConfig(unsigned int LMK04208_CKin[LMK04208_count])
{
  int XIicDevFile;
  int Index;
  char XIicDevFilename[20];
  unsigned char tx_array[4];
  
  sprintf(XIicDevFilename, "/dev/i2c-%d", IICBUS);
  XIicDevFile = open(XIicDevFilename, O_RDWR);

  ioctl(XIicDevFile, I2C_SLAVE_FORCE, 0x74);
  IicWriteData(XIicDevFile, 0x20, 0, tx_array);
  
  ioctl(XIicDevFile, I2C_SLAVE_FORCE, 0x2f);
  
  for (Index = 0; Index < LMK04208_count; Index++) {
    tx_array[3] = (unsigned char) (LMK04208_CKin[Index]) & (0xFF);
    tx_array[2] = (unsigned char) (LMK04208_CKin[Index] >> 8) & (0xFF);
    tx_array[1] = (unsigned char) (LMK04208_CKin[Index] >> 16) & (0xFF);
    tx_array[0] = (unsigned char) (LMK04208_CKin[Index] >> 24) & (0xFF);
    IicWriteData(XIicDevFile, IIC_LMK04028_ADDR, 4, tx_array);
    usleep(1000);
  }

  close(XIicDevFile);
}

void LMK04208ClockDisSys(unsigned int LMK04208_CKin[LMK04208_count])
{
  int ids[3] = {0,1,3};
  int Index;
  int Check;
  int XIicDevFile;
  char XIicDevFilename[20];
  unsigned char tx_array[4];

  sprintf(XIicDevFilename, "/dev/i2c-%d", IICBUS);
  XIicDevFile = open(XIicDevFilename, O_RDWR);

  ioctl(XIicDevFile, I2C_SLAVE_FORCE, 0x74);
  IicWriteData(XIicDevFile, 0x20, 0, tx_array);

  ioctl(XIicDevFile, I2C_SLAVE_FORCE, 0x2f);

  for (Index=0; Index<5; Index++) 
    for (Check=0; Check<3; Check++) 
      if (Index == Check) {
	unsigned int val = LMK04208_CKin[ids[Index]] | (1 << 31);
	tx_array[3] = (unsigned char) (val) & (0xFF);
	tx_array[2] = (unsigned char) (val >> 8) & (0xFF);
	tx_array[1] = (unsigned char) (val >> 16) & (0xFF);
	tx_array[0] = (unsigned char) (val >> 24) & (0xFF);
	IicWriteData(XIicDevFile, IIC_LMK04028_ADDR, 4, tx_array);
	usleep(1000);
	break;
      }

  close(XIicDevFile);
}

void Zcu111ClockSetup()
{
  LMK04208ClockConfig(LMK04208_CK_def);
  LMX2594ClockConfig(LMX2594_CKs_def);
  //LMK04208ClockDisSys(LMK04208_CK_def);
}

#endif
