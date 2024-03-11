/*
 * misc.c
 *
 *  Created on: Feb 14, 2024
 *      Author: danielbraun
 */


#include <stdint.h>
#include "misc.h"

#ifndef MINITEL_SIMULATOR
#include "stm32g4xx_hal.h"
//#include "cmsis_os.h"
#endif //MINITEL_SIMULATOR



#ifndef MINITEL_SIMULATOR
#endif //MINITEL_SIMULATOR


void flash_led(void)
{
#ifndef MINITEL_SIMULATOR

#ifndef BOARD_LED_GPIO_Port
#ifdef  LD2_GPIO_Port
#define BOARD_LED_GPIO_Port LD2_GPIO_Port
#endif
#endif


#ifndef BOARD_LED_Pin
#ifdef  LD2_Pin
#define BOARD_LED_Pin LD2_Pin
#endif
#endif

#ifdef BOARD_LED_Pin
	HAL_GPIO_TogglePin(BOARD_LED_GPIO_Port,BOARD_LED_Pin);
	//HAL_GPIO_TogglePin(GPIOC,GPIO_PIN_13);
#endif

#endif /* MINITEL_SIMULATOR */
}




#ifndef MINITEL_SIMULATOR

static const char *_fatal = NULL;
void FatalError(const char *short4lettersmsg, _UNUSED_ const char *longmsg)
{
	if (!_fatal) {
		_fatal = short4lettersmsg;
		//_fatal_code = errcode;
		__disable_irq();
		for (;;) {
			// stop
		}
	}
}

#else //MINITEL_SIMULATOR

void FatalError(const char *short4lettersmsg, _UNUSED_ const char *longmsg)
{
    abort();
}
#endif //MINITEL_SIMULATOR

