//
//  HelpViewController.m
//  Gavitarium2
//
//  Created by Robert Neagu on 5/29/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

@synthesize theImage = _theImage;

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissModalViewControllerAnimated: TRUE];
}

-(NSString *) title {
    return @"Help";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.theImage.image = [UIImage imageNamed: @"helpPhone.png"];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
       self.theImage.image = [UIImage imageNamed: @"helpPad.png"];        
    }
}

#pragma mark - Rotation

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setTheImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [_theImage release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
