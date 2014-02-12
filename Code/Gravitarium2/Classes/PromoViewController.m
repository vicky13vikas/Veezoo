//
//  PromoViewController.m
//  Gavitarium2
//
//  Created by Robert Neagu on 12/13/12.
//
//

#import "PromoViewController.h"
#import "AVAudio.h"

@interface PromoViewController ()

@property (retain, nonatomic) IBOutlet UINavigationBar *btnClose;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navItem;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PromoViewController

@synthesize url = _url;

#pragma mark - Load

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    //Load request
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.url]]];
    
    //Play sound
    [[AVAudio sharedAudio] playSound: @"notification"];
    
    //Mute music
    [[AVAudio sharedAudio] setMusicVolume: 0];
}


#pragma mark - UIWebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return TRUE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Finished loading page...");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error: %@", [error localizedDescription]);
}

#pragma mark - UIActions

- (IBAction)closeTapped:(id)sender {
    //Unmute music
    [[AVAudio sharedAudio] setMusicVolume: 1];
    
    //Dismiss
    [self dismissModalViewControllerAnimated: TRUE];
}

#pragma mark - Unload

- (void)viewDidUnload {
    [self setBtnClose:nil];
    [self setNavBar:nil];
    [self setWebView:nil];
    [self setNavItem:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [_url release];
    [_btnClose release];
    [_navBar release];
    [_webView release];
    [_navItem release];
    [super dealloc];
}

@end
