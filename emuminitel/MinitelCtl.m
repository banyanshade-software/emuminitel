//
//  MinitelCtl.m
//  emuminitel
//
//  Created by Daniel Braun on 08/03/2024.
//

#import "MinitelCtl.h"

@implementation MinitelCtl {
    WKUserContentController *wkuserctrl;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self loadHtml];
}
- (void) loadHtml
{
    NSURL *u = [[NSBundle mainBundle] URLForResource:@"web/index" withExtension:@"html"];
    NSAssert(u, @"index.html missing");
    NSError *err;
    NSString *ctohtml = [NSString stringWithContentsOfURL:u encoding:NSUTF8StringEncoding error:&err];
    WKNavigation *nv = [_m1 loadHTMLString:ctohtml baseURL:nil];
    NSAssert(nv, @"load failed");
    
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self installJavascript];
    });*/
    wkuserctrl = _m1.configuration.userContentController;
    [wkuserctrl addScriptMessageHandler:self name:@"ctc"];
}

- (void) installJavascript
{
    // hide all info from this blk
    NSString *js = @"Array.from(document.getElementsByClassName('trinfo'), el => el.style.visibility = 'hidden')";
    [self->_m1 evaluateJavaScript:js completionHandler:^(id v, NSError *err) {
        if (err) {
            NSLog(@"js error : %@\n", err);
        }
    }];
    js = @"Array.from(document.getElementsByClassName('track'), el => el.style.stroke = 'darkgray')";
    [self->_m1 evaluateJavaScript:js completionHandler:^(id v, NSError *err) {
        if (err) {
            NSLog(@"js error : %@\n", err);
        }
    }];
    // add callback for turnouts
    js = @"Array.from(document.getElementsByClassName('tncircle'), el => el.addEventListener(\"click\", function () {\
       window.webkit.messageHandlers.ctc.postMessage(\"c\"+el.getAttribute('id'));} ));";
    [self->_m1 evaluateJavaScript:js completionHandler:^(id v, NSError *err) {
        if (err) {
            NSLog(@"js error : %@\n", err);
        }
    }];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self installJavascript];
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message
{
    
}
@end
