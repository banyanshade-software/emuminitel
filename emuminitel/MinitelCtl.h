//
//  MinitelCtl.h
//  emuminitel
//
//  Created by Daniel Braun on 08/03/2024.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MinitelCtl : NSObject <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, weak) IBOutlet WKWebView *m1;



@end

NS_ASSUME_NONNULL_END
