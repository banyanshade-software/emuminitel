//
//  EmulCoord.h
//  emuminitel
//
//  Created by Daniel Braun on 10/03/2024.
//

#import <Foundation/Foundation.h>
#import "MinitelCtl.h"
NS_ASSUME_NONNULL_BEGIN

@interface EmulCoord : NSObject

@property (nonatomic, weak) IBOutlet MinitelCtl *m0;
@property (nonatomic, weak) IBOutlet MinitelCtl *m1;
@property (nonatomic, weak) IBOutlet MinitelCtl *m2;
@property (nonatomic, weak) IBOutlet MinitelCtl *m3;


@end

void minitel_tx_done(int port);
void minitel_rx_char(int port, uint8_t car);

NS_ASSUME_NONNULL_END
