//
//  scNotConnectedViewController.m
//  Soundcloud
//
//  Created by Nicholas Krut on 8/20/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import "scNotConnectedViewController.h"
#import "SCUI.h"
#import <QuartzCore/QuartzCore.h>

@interface scNotConnectedViewController ()

@end

@implementation scNotConnectedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidLayoutSubviews
{
    CAGradientLayer *gradient = [[self.view.layer sublayers] objectAtIndex:0];
    if (![gradient isKindOfClass:[CAGradientLayer class]])
        gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0xff6600) CGColor], (id)[UIColorFromRGB(0xff3300) CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissAfterLogin
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) login:(id) sender
{
    SCAccount *account = [SCSoundCloud account];
    if (account != nil)
    {
        [self performSelector:@selector(dismissAfterLogin) withObject:nil afterDelay:1.0f];
    } else {
        SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
            if (SC_CANCELED(error)) {
                NSLog(@"Canceled!");
            } else if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
            } else {
                [self performSelector:@selector(dismissAfterLogin) withObject:nil afterDelay:1.0f];
            }
        };
        
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
            SCLoginViewController *loginViewController;
            
            loginViewController = [SCLoginViewController
                                   loginViewControllerWithPreparedURL:preparedURL
                                   completionHandler:handler];
            [self presentViewController:loginViewController animated:YES completion:nil];
        }];
    }
}

@end
