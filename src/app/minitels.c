/*
 * minitels.c
 *
 *  Created on: Mar 10, 2024
 *      Author: danielbraun
 */



#include <stdint.h>
#include <string.h>

#include "minitels.h"

#include "../utils/misc.h"
#include "../utils/itm_debug.h"
#include "../utils/lf_mqueue.h"
#include "../serial/serial.h"

// state
typedef enum {
	state_init = 0,
	state_q1_tx,
	state_q1,
} __attribute((packed)) minitel_state_t;

typedef struct minitel {
	uint32_t lasttick;
	minitel_state_t state;
} __attribute((packed)) minitel_t;

static minitel_t minitels[NUM_SERIALS];

#define SET_STATE(_idx, _m, _newstate) do {                      \
	itm_debug3(DBG_MTEL, "state", _idx, (_m)->state, _newstate); \
	(_m)->state = (_newstate);                                   \
} while(0)


void minitel_init_all(void)
{
	memset(minitels, 0, sizeof(minitels));
}

void minitel_processtxdone(int mntidx)
{
	minitel_t *m = &minitels[mntidx];
	switch (m->state) {
	case state_q1_tx:
		SET_STATE(mntidx, m, state_q1);
		break;
	case state_init:
	case state_q1:
	}
}

static void minitel_process_rxchar(int mntidx, minitel_t *m, uint8_t car);

void minitel_processrx(int mntidx)
{
	minitel_t *m   = &minitels[mntidx];
	serial_t  *ser = &serials[mntidx];
	for (;;) {
		uint8_t  c;
		int rc = mqf_read(ser->rxqueue, &c);
		if (rc) break;
		minitel_process_rxchar(mntidx, m, c);
	}
}

static void minitel_process_rxchar(int mntidx, minitel_t *m, uint8_t car)
{
	switch (m->state) {
	case state_init:
	case state_q1_tx:
		itm_debug3(DBG_MTEL, "ign car", mntidx, m->state, car);
		break;
	case state_q1:
		itm_debug2(DBG_MTEL, "id car", mntidx,  car);
		break;

	}
}


// PRO1 ESC 39
// ! 29 ! PRO1 7B ({)        ! Lecture ROM (Identification du terminal).          !

//static const uint8_t mnt_ping[] = { 0x1B, 0x39, 0x7B };
static const uint8_t mnt_ping[] = "coucou";

void minitel_tick(int mntidx, uint32_t tick)
{
	minitel_t *m = &minitels[mntidx];

	switch(m->state) {
	case state_init:
		serial_send_bytes(mntidx, mnt_ping, sizeof(mnt_ping), 0);
		SET_STATE(mntidx, m, state_q1_tx);
		break;
	default:
		break;
	}
}
