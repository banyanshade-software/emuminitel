/*
 * serial.h
 *
 *  Created on: Feb 14, 2024
 *      Author: danielbraun
 */

#ifndef SERIAL_SERIAL_H_
#define SERIAL_SERIAL_H_

#include "../utils/misc.h"
#include "../utils/lf_mqueue.h"
#include "main.h"

#define PORT_VCOM 	0
#define PORT_BLE	1


//int serial_setup(int port, osThreadId task);


int serial_start_rx(int port);

int serial_send_bytes(int port, const uint8_t *b, int len, int needcopy);


#define _NOTIF_UART_RX		0x00000001
#define _NOTIF_UART_TX		0x00000010

#define NOTIFY_UART_RX(_p) (_NOTIF_UART_RX<<(_p))
#define NOTIFY_UART_TX(_p) (_NOTIF_UART_TX<<(_p))

typedef struct serial {
	osThreadId          taskHandle;
	UART_HandleTypeDef *uart;
	DMA_HandleTypeDef  *txdma;

	uint16_t            txbuflen;
	uint8_t            *txbuf;
	volatile uint8_t    txonprogress;
	uint8_t				rxcar;
	mqf_t				*rxqueue;
} serial_t;

#define NUM_SERIALS 4


extern serial_t serials[NUM_SERIALS];

#endif /* SERIAL_SERIAL_H_ */
