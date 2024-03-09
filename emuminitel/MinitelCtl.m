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
    [wkuserctrl addScriptMessageHandler:self name:@"kbd"];
    [wkuserctrl addScriptMessageHandler:self name:@"ctrlflow"];
}

- (void) installJavascript
{
    NSString *js;

    // keyboard from minitel
    js = @"function minitelFromStr(s) { window.webkit.messageHandlers.kbd.postMessage(s) }";
    [_m1 evaluateJavaScript:js completionHandler:^(id v, NSError *err) {
        if (err) {
            NSLog(@"js error : %@\n", err);
        }
    }];
    js = @"function minitelFromDone() { window.webkit.messageHandlers.ctrlflow.postMessage('') }";
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
    if ((0)) [self performSelector:@selector(sendExample) withObject:nil afterDelay:1];
    [self performSelector:@selector(refreshScreen) withObject:nil afterDelay:1];
}

- (void) refreshScreen
{
    NSView *v = _m1.superview;
    [_m1 setNeedsLayout:YES];
    [_m1 setNeedsDisplay:YES];
    
    [v setNeedsLayout:YES];
    [v setNeedsDisplay:YES];
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message
{
    NSString *s = message.body;
    NSString *t = message.name;
    
    NSLog(@"rx %@ len %d : %@", t, (int) s.length, s);
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
    NSString *s = @"%0C%1FAA%0E%1B%40%1BT%20%12EX%1BA%1BP%1BZ%20%1BG%40%5E_%12IT%1B%40%1BW%1BYT0%20%12E%1BQ%12K%1FBA%0E%1B%40%1BT%20%12C%40%5E%1BA%1BP%1BZ%20%1BG%40%5E_%12LT%1B%40%1BW%1BYT%20%12D%1BQ%12K%1FCA%0E%1B%40%1BT%20%12BH%1BA%1BP%1BZ%20%12B%1BG_%12OT%1B%40%1BW%1BYT%20%12C%1BQ%12K%1FDA%0E%1B%40%1BT%20%12B%1BA%1BP%1BZ%12B%1BG%40X_%12P0%1B%40%1BW%1BY4%20%12B%1BQ%12K%1FEA%0E%1B%40%1BT%20%20%1BA%1BP%1BZ%12B%1BGH%25%5B_%12PU%09%1B%40%1BW%1BY%20%12B%1BQ%12K%1FFA%0E%1B%40%1BT%20%20%1BA%1BP%1BZ%12C%1BG%24_%12R%09%1B%40%1BW%1BY5%20%20%1BQ%12K%1FGA%0E%1B%40%1BT%20%20%1BA%1BP%1BZ%12C%1BG(_%12R5%1B%40%1BW%1BY5%20%20%1BQ%12K%1FHA%0E%1B%40%1BT%20%20%1BA%1BP%1BZ%12D%1BG_%12R5%1B%40%1BW%1BY5%20%20%1BQ%12K%1FIA%0E%1B%40%1BT%20%20%1BA%1BP%1BZ%12D%1BG_%12D%3F%27%23%12B%2B_%12B%3F%2F%23%12B!%1B%40%1BW%1BY%5D%20%20%1BQ%12K%1FJA%0E%1B%40%1BT%20%20%1BA%1BP%1BZ%12D%1BG_%12C%27%40P%1BA%20%20%1BG%5C0J_%5D%40P%09%09%5C%09%09%1B%40%1BW%1BY%20%20%1BQ%12K%1FKA%0E%1B%40%1BT%20%20%1BG%1BP%1BZH%1BA%20%1BG%406%5B_%12B8%27%40%1BA%20%1BG%40P4%22__VXPPRXU%1B%40%1BW%1BY5%20%1BQ%12K%1FLA%0E%1B%40%1BT%20%20%1BG%1BP%1BZJ42_%12J%5D%5D_%12H%1B%40%1BW%1BY5%20%1BQ%12K%1FMA%0E%1B%40%1BT%20%12B%1BG%1BP%1BZ_7_%12T%3D%1B%40%1BW%1BY5%20%1BQ%12K%1FNA%0E%1B%40%1BT%20%12B%1BG%1BP%1BZJ%5DZ_O_%12QU%1B%40%1BW%1BY%20%20%1BQ%12K%1FOA%0E%1B%40%1BT%20%12C%1BG%1BP%1BZ_V7C_%12GK_%12C%3F_%12C5%1B%40%1BW%1BY%20%20%1BQ%12K%1FPA%0E%1B%40%1BT%20%12C%1BG%1BP%1BZJ_%12JVQ0%1BA%20%20%1BG%40%5E_%12B5%1B%40%1BW%1BY%20%20%1BQ%12K%1FQA%0E%1B%40%1BT%20%12D%1BG%1BP%1BZO_%12GO_%12CU%5C_%12D5%1B%40%1BW%1BY%20%20%1BQ%12K%1FRA%0E%1B%40%1BT%20%12E%1BG%1BP%1BZ%22_%12EE_%12K%1B%40%1BW%1BY5%20%20%1BQ%12K%1FSA%0E%1B%40%1BT%20%12F%1BG%1BP%1BZ*_%12F7%27%23%1BA%20%12C%1BG!%22__%1B%40%1BW%1BY5%20%20%1BQ%12K%1FTA%0E%1B%40%1BT%20%12F%1BG%1BP%1BZOO_%12DE%5CS%2F%2C%2C-%2FX%5E_7%1B%40%1BW%1BY%25%20%20%1BQ%12K%1FUA%0E%1B%40%1BT%20%12C%40%5E%1BQ_%1BW!K%1BG%1BP%1BZK_%12GPPX%5E__%27%25%1B%40%1BW%1BY%20%12B%1BQ%12K%1FVA%0E%1B%40%1BT%20%20P%5C%1BQ_%12B%1BW%20%20%2B%1BG%1BP%1BZ_%12BW%5B_%12I%1B%40%1BW%1BYT%20%12B%1BQ%12K%1FWA%0E%1B%40%1BQ_%12F%1BW%20%12B%2B%1BG%1BP%1BZ%3F%2F%27_%12H7!%09%09%1B%40%1BW%1BY%5CP%1BQ%20%12J%1FXA%0E%1B%40%1BQ_%12F%1BW%20%12C%2B%09%09%1BG%1BP%1BZ%22%2B%2F%12E%27%09%09%09%09%09%09%09%1B%40%1BQ%1BY%5CP%20%12G%1FF%5E%0E%1BP%1BA_%0B%08_%1FE_%0E%1BP%20%12F%1FF_%0E%1BP%20%12F%1FF_%1BO%1BH51%2C%1FFd%1BO%1BH7";
    s = [s  stringByRemovingPercentEncoding];
    [self sendStringToMinitel:s];
}

@end
