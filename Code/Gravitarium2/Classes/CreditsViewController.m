//
//  CreditsViewController.m
//  Gavitarium2
//
//  Created by Robert Neagu on 6/1/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import "CreditsViewController.h"


@implementation CreditsViewController

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissModalViewControllerAnimated: TRUE];
}

-(NSString *) title {
    return @"Credits";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Rotation

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - UI Actions

- (IBAction)link11:(id)sender {
    NSURL *url = [[NSURL alloc ] initWithString: @"http://www.twitter.com/airfire"];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

- (IBAction)link12:(id)sender {
    NSURL *url = [[NSURL alloc ] initWithString: @"http://www.facebook.com/airfire83"];
    [[UIApplication sharedApplication] openURL:url]; 
    [url release];
}

- (IBAction)link21:(id)sender {
    NSURL *url = [[NSURL alloc ] initWithString: @"http://www.facebook.com/silentstrikemusic"];
    [[UIApplication sharedApplication] openURL:url]; 
    [url release];
}

- (IBAction)link22:(id)sender {
    NSURL *url = [[NSURL alloc ] initWithString: @"http://www.soundcloud.com/silent-strike"];
    [[UIApplication sharedApplication] openURL:url]; 
    [url release];
}

- (IBAction)link23:(id)sender {
    NSURL *url = [[NSURL alloc ] initWithString: @"http://itunes.apple.com/artist/silent-strike/id307245210"];
    [[UIApplication sharedApplication] openURL:url]; 
    [url release];
}

@end
