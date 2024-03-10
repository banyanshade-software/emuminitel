/*
 * serial.c
 *
 *  Created on: Feb 14, 2024
 *      Author: danielbraun
 */


#include <stdint.h>
#include <string.h>
#include "serial.h"

#include "serial.h"
#include "../utils/misc.h"
#include "main.h"
#include "../utils/itm_debug.h"


extern UART_HandleTypeDef hlpuart1;
extern UART_HandleTypeDef huart1;
extern UART_HandleTypeDef huart3;
extern UART_HandleTypeDef huart4;
extern UART_HandleTypeDef huart5;


extern DMA_HandleTypeDef hdma_lpuart1_tx;
extern DMA_HandleTypeDef hdma_usart1_tx;
extern DMA_HandleTypeDef hdma_usart3_tx;
extern DMA_HandleTypeDef hdma_uart4_tx;
extern DMA_HandleTypeDef hdma_uart5_tx;

extern osThreadId comTaskHandle;
extern osThreadId bleTaskHandle;


LFMQUEUE_DEF_C(q1, uint8_t, 32, 1)
LFMQUEUE_DEF_C(q3, uint8_t, 32, 1)
LFMQUEUE_DEF_C(q4, uint8_t, 32, 1)
LFMQUEUE_DEF_C(q5, uint8_t, 32, 1)

#define COMMON_INIT .taskHandle=NULL,  .txonprogress=0


serial_t serials[NUM_SERIALS] = {
		{ COMMON_INIT,  .uart=&huart1,   .txdma=&hdma_usart1_tx,   .rxqueue=&q1,  .txbuf=NULL, .txbuflen=0 },
		{ COMMON_INIT,  .uart=&huart3,   .txdma=&hdma_usart3_tx,   .rxqueue=&q3,  .txbuf=NULL, .txbuflen=0 },
		{ COMMON_INIT,  .uart=&huart4,   .txdma=&hdma_uart4_tx,    .rxqueue=&q4,  .txbuf=NULL, .txbuflen=0 },
		{ COMMON_INIT,  .uart=&huart5,   .txdma=&hdma_uart5_tx,    .rxqueue=&q5,  .txbuf=NULL, .txbuflen=0 },
	//{ COMMON_INIT,  .uart=&hlpuart1, .txdma=&hdma_lpuart1_tx,  .rxqueue=rxbuf0,  .rxbuflen=sizeof(rxbuf0), .txbuf=NULL, .txbuflen=0 },

};



int serial_start_rx(int port)
{
	serial_t *s = &serials[port];
	/*
	 * we have to receive char by char, to find \r
	 */
	HAL_StatusTypeDef rc = HAL_UART_Receive_IT(s->uart,  &(s->rxcar), 1);
	if (rc != HAL_OK) {
		itm_debug2(DBG_SERIAL|DBG_ERR, "Ustrt", rc, s->uart->ErrorCode);
	}
	return rc;
}

 int serial_send_bytes(int port, const uint8_t *b, int len, int needcopy)
{
	serial_t *s = &serials[port];

	while (s->txonprogress) {
		itm_debug2(DBG_SERIAL, "Tx BLK", port, len);
		uint32_t notif = 0;
		xTaskNotifyWait(0, NOTIFY_UART_TX(port), &notif, portMAX_DELAY);
	}

 	s->txonprogress = 1;
 	HAL_StatusTypeDef rc;
 	if (needcopy) {
 		if (len > s->txbuflen) {
 			itm_debug3(DBG_ERR|DBG_SERIAL, "tx big", port, len, s->txbuflen);
 			return -1;
 		}
 	 	memcpy(s->txbuf, b, len);
 		rc = HAL_UART_Transmit_DMA(s->uart, s->txbuf, len);
 	} else {
 		rc = HAL_UART_Transmit_DMA(s->uart, b, len);
 	}
	if (rc != HAL_OK) {
		itm_debug1(DBG_SERIAL|DBG_ERR, "TxErr", rc);
	 	s->txonprogress = 0;
		return -1;
	}
	return 0;
}

 int serial_tx_onprogress(int port)
 {
		serial_t *s = &serials[port];
		return (s->txonprogress) ? 1 : 0;
 }

//void HAL_UART_TxHalfCpltCallback(UART_HandleTypeDef *huart);
void HAL_UART_TxCpltCallback(_UNUSED_ UART_HandleTypeDef *huart)
{
	int port = -1;
	for (int p=0; p<NUM_SERIALS; p++) {
		if (serials[p].uart == huart) {
			port = p;
			break;
		}
	}
	if (port < 0) {
		itm_debug1(DBG_ERR|DBG_SERIAL, "bad uart", (int)huart);
		return;
	}

	serial_t *s = &serials[port];
	s->txonprogress = 0;

	BaseType_t higher=0;
	if (!s->taskHandle) {
		itm_debug1(DBG_ERR, "notask", port);
		return;
	}
	xTaskNotifyFromISR(s->taskHandle, NOTIFY_UART_TX(port), eSetBits, &higher);
	portYIELD_FROM_ISR(higher);
}


static void bh(void)
{
}


void HAL_UARTEx_RxFifoFullCallback(_UNUSED_  UART_HandleTypeDef *huart)
{
	itm_debug1(DBG_SERIAL, "RxFifoFull", 0);
	bh();
}
void HAL_UART_RxHalfCpltCallback(_UNUSED_ UART_HandleTypeDef *huart)
{
	itm_debug1(DBG_SERIAL, "RxHalfCplt", 0);
	bh();
}
void HAL_UART_RxCpltCallback(_UNUSED_ UART_HandleTypeDef *huart)
{
	int port = -1;
	for (int p=0; p<NUM_SERIALS; p++) {
		if (serials[p].uart == huart) {
			port = p;
			break;
		}
	}
	if (port < 0) {
		itm_debug1(DBG_ERR|DBG_SERIAL, "bad uart", (int)huart);
		return;
	}

	serial_t *s = &serials[port];
	itm_debug2(DBG_SERIAL, "RX char", port, s->rxcar);
	mqf_write(s->rxqueue, &(s->rxcar));
	serial_start_rx(port);

	BaseType_t higher=0;
	if (!s->taskHandle) {
		itm_debug1(DBG_ERR, "notask", port);
		return;
	}
	xTaskNotifyFromISR(s->taskHandle, NOTIFY_UART_RX(port), eSetBits, &higher);
	portYIELD_FROM_ISR(higher);
}



void HAL_UARTEx_RxEventCallback(_UNUSED_ UART_HandleTypeDef *huart, _UNUSED_ uint16_t Size)
{
	itm_debug1(DBG_SERIAL, "RxEvent", Size);
	bh();
}
void HAL_UART_ErrorCallback(_UNUSED_ UART_HandleTypeDef *huart)
{
	itm_debug1(DBG_ERR|DBG_SERIAL, "RxErr", huart->ErrorCode);
	bh();
	if (__HAL_UART_GET_FLAG(huart, UART_FLAG_PE) != RESET) {
		__HAL_UART_CLEAR_FLAG(huart, UART_CLEAR_PEF); /* Clear PE flag */
	} else if (__HAL_UART_GET_FLAG(huart, UART_FLAG_FE) != RESET) {
		__HAL_UART_CLEAR_FLAG(huart, UART_CLEAR_FEF); /* Clear FE flag */
	} else if (__HAL_UART_GET_FLAG(huart, UART_FLAG_NE) != RESET) {
		__HAL_UART_CLEAR_FLAG(huart, UART_CLEAR_NEF); /* Clear NE flag */
	} else if (__HAL_UART_GET_FLAG(huart, UART_FLAG_ORE) != RESET) {
		__HAL_UART_CLEAR_FLAG(huart, UART_CLEAR_OREF); /* Clear ORE flag */
	}
	//_start_rx(0);
}

