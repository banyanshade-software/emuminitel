//
//  EmulCoord.m
//  emuminitel
//
//  Created by Daniel Braun on 10/03/2024.
//

#import "EmulCoord.h"
#include "serial.h"
#include "minitels.h"

uint32_t SimuTick = 0;


static MinitelCtl *ctrl[NUM_SERIALS];
serial_t serials[NUM_SERIALS];

int serial_start_rx(int port)
{
    MinitelCtl *m = ctrl[port];
    if (!m) return -1;
    m.canRx = YES;
    return 0;
}

int serial_send_bytes(int port, const uint8_t *b, int len, int needcopy)
{
    MinitelCtl *m = ctrl[port];
    if (!m) return -1;
    [m sendBytesToMinitel:b length:len];
    return 0;
}
int serial_tx_onprogress(int port)
{
    MinitelCtl *m = ctrl[port];
    if (!m) return -1;
    return 0;
}


uint32_t notif = 0;

void minitel_tx_done(int port)
{
    if (port<0) return;
    notif |= NOTIFY_UART_TX_DONE(port);
}
void minitel_rx_char(int port, uint8_t car)
{
    if (port<0) return;
    notif |= NOTIFY_UART_RX(port);
    serial_t *s = &serials[port];
    mqf_t *m = s->rxqueue;
    mqf_write(m, (void *)&car);
}


@implementation EmulCoord {
    NSTimer *timer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    int i = 0;
    if (NUM_SERIALS<4) abort();
    ctrl[i++] = self.m0;
    ctrl[i++] = self.m1;
    ctrl[i++] = self.m2;
    ctrl[i++] = self.m3;
    
    for (int i=0; i<NUM_SERIALS; i++) {
        ctrl[i].coord = self;
        ctrl[i].portNum = i;
    }
    for (int i=0; i<NUM_SERIALS; i++) {
        mqf_t *q = malloc(sizeof(mqf_t));
        q->num = 32;
        q->msgsiz = 1;
        q->maxuse = 0;
        q->silentdrop = 0;
        q->msgbuf = malloc(q->num); // msgsiz 1
        q->head = 0;
        q->tail = 0;
        serials[i].rxqueue = q;
    }
    minitel_init_all();
    
    NSTimeInterval interv = 0.2;
    NSDate *d = [[NSDate now]dateByAddingTimeInterval:1];
    timer = [[NSTimer alloc]initWithFireDate:d interval:interv repeats:YES block:^(NSTimer *tim) {
        //NSLog(@"plop");
        static uint32_t t=0;
        t++;
        SimuTick = t*200;
        
        for (int i=0; i<NUM_SERIALS; i++) {
            if (notif & NOTIFY_UART_TX_DONE(i)) {
                minitel_processtxdone(i);
            }
            if (notif & NOTIFY_UART_RX(i)) {
                minitel_processrx(i);
            }
        }
        notif = 0;
        if (0==(t%5)) {
            // 1s tick
            for (int i=0; i<NUM_SERIALS; i++) {
                if (!ctrl[i]) continue;
                minitel_tick(i, SimuTick);
            }
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
@end
