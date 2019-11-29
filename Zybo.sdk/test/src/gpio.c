/*
 * gpio.c
 *
 *  Created on: 2019. 11. 29.
 *      Author: duwon
 */

#include "xgpiops.h"
#include "gpio.h"

static XGpioPs mio_pmod;


int GpioPsConfig(void)
{
	XGpioPs_Config *GpioConfigPtr;

	//GPIO Initialization
	GpioConfigPtr = XGpioPs_LookupConfig(0);
	XGpioPs_CfgInitialize(&mio_pmod, GpioConfigPtr,GpioConfigPtr->BaseAddr);

	//LD 7
	XGpioPs_SetDirectionPin(&mio_pmod, 7, 1);
	XGpioPs_SetOutputEnablePin(&mio_pmod, 7, 1);
	XGpioPs_WritePin(&mio_pmod, 7, 0x1);

	//SW 50
	XGpioPs_SetDirectionPin(&mio_pmod, 50, 0);
	XGpioPs_SetOutputEnablePin(&mio_pmod, 50, 0);


	return XST_SUCCESS;
}

void GpioLedControl(u32 data)
{
	if (data)
		XGpioPs_WritePin(&mio_pmod, 7, 0x1);
	else
		XGpioPs_WritePin(&mio_pmod, 7, 0x0);
}

u32	GpioSw(u32 pin)
{
	return XGpioPs_ReadPin(&mio_pmod, pin);
}
