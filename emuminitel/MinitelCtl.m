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
    NSURL *u = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"web"];
    NSURL *u0 = [u URLByDeletingLastPathComponent];
    NSAssert(u, @"index.html missing");
    NSError *err;
    NSString *mntlhtml = [NSString stringWithContentsOfURL:u encoding:NSUTF8StringEncoding error:&err];
    WKNavigation *nv = [_m1 loadHTMLString:mntlhtml baseURL:u0];
    NSAssert(nv, @"load failed");
    
    
    wkuserctrl = _m1.configuration.userContentController;
    [wkuserctrl addScriptMessageHandler:self name:@"ctrl"];
}

- (void) installJavascript
{
    NSString *js;
#if 0
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
#endif
    // keyboard from minitel
    js = @"function minitelFromStr(s) { window.webkit.messageHandlers.ctrl.postMessage(s) }";
    [_m1 evaluateJavaScript:js completionHandler:^(id v, NSError *err) {
        if (err) {
            NSLog(@"js error : %@\n", err);
        }
    }];
}

- (void) sendStringToMinitel:(NSString *)s
{
    s = [s stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString *js = [NSString stringWithFormat:@"minitelSendString('%@');", s];
    [_m1 evaluateJavaScript:js completionHandler:^(id v, NSError *err) {
        if (err) {
            NSLog(@"js error : %@\n", err);
        }
    }];

}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self installJavascript];
    if ((1)) [self performSelector:@selector(sendExample) withObject:nil afterDelay:1];
    [_m1 setNeedsLayout:YES];
    [_m1 setNeedsDisplay:YES];
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message
{
    NSString *s = message.body;
    NSLog(@"rx len %d : %@", (int) s.length, s);
}

- (void) sendExample
{
    NSString *s=@"hopla on se reveille car \"longtemps\" 'je me suis leve de bonne heure' comme disait l'autre";
    [self sendStringToMinitel:s];
}


- (IBAction) test1:(id)sender
{
    [self sendStringToMinitel:@" Longtemps, je me suis couché de bonne heure. Parfois, à peine ma bougie éteinte, mes yeux se fermaient si vite que je n’avais pas le temps de me dire : « Je m’endors. » Et, une demi-heure après, la pensée qu’il était temps de chercher le sommeil m’éveillait ; je voulais poser le volume que je croyais avoir encore dans les mains et souffler ma lumière ; je n’avais pas cessé en dormant de faire des réflexions sur ce que je venais de lire, mais ces réflexions avaient pris un tour un peu particulier ; il me semblait que j’étais moi-même ce dont parlait l’ouvrage : une église, un quatuor, la rivalité de François Ier et de Charles Quint."];
}
- (IBAction) test2:(id)sender
{
    [self sendStringToMinitel:@"plop"];
}

@end
