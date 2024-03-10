/*
 * minitels.h
 *
 *  Created on: Mar 10, 2024
 *      Author: danielbraun
 */

#ifndef APP_MINITELS_H_
#define APP_MINITELS_H_

typedef struct minitel minitel_t;


void minitel_init_all(void);

void minitel_processtxdone(int mntidx);
void minitel_processrx(int mntidx);
void minitel_tick(int mntidx, uint32_t tick);


#endif /* APP_MINITELS_H_ */
