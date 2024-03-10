/*
 * miniteltask.c
 *
 *  Created on: Mar 9, 2024
 *      Author: danielbraun
 */




#include <stdint.h>
//#include <string.h>

#include "miniteltask.h"

#include "../utils/misc.h"
#include "../utils/itm_debug.h"
// #include "../utils/lf_mqueue.h"

#include "../serial/serial.h"

#include "minitels.h"
#include "main.h"


#define NUM_MINITELS NUM_SERIALS



void StartMainTask(void const * argument)
{
	minitel_init_all();

  /* Infinite loop */
	for (;;) {
		itm_debug1(DBG_MTEL, "-wait c", 0);
		uint32_t notif = 0;
		xTaskNotifyWait(0, 0xFFFFFFFF, &notif, 1000);

		for (int i=0; i<NUM_MINITELS; i++) {
			if (notif & NOTIFY_UART_TX(i)) {
				minitel_processtxdone(i);
			}
			if (notif & NOTIFY_UART_RX(i)) {
				minitel_processrx(i);
			}

			uint32_t t = HAL_GetTick();
			minitel_tick(i, t);

		}

	}
}

