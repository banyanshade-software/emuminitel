//
//  MinitelCtl.h
//  emuminitel
//
//  Created by Daniel Braun on 08/03/2024.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EmulCoord;

@interface MinitelCtl : NSObject <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, weak) IBOutlet WKWebView *m1;
@property (nonatomic, weak) EmulCoord *coord;

- (IBAction) test1:(id)sender;
- (IBAction) test2:(id)sender;
- (IBAction) test3:(id)sender;
- (IBAction) test4:(id)sender;

@property (nonatomic) int portNum;
@property (nonatomic) BOOL txOnProgress;
@property (nonatomic) BOOL canRx;


- (void) sendBytesToMinitel:(const uint8_t *)bytes length:(int)len;

@end

NS_ASSUME_NONNULL_END
