/*
 * gpio.h
 *
 *  Created on: 2019. 11. 29.
 *      Author: duwon
 */

#ifndef SRC_GPIO_H_
#define SRC_GPIO_H_



int GpioPsConfig(void);
void GpioLedControl(u32 data);
u32	GpioSw(u32 pin);

#endif /* SRC_GPIO_H_ */
