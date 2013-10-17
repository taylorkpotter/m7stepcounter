//
//  MDAppDelegate.m
//  stepster
//
//  Created by John Clem on 9/27/13.
//  Copyright (c) 2013 Mind DIaper. All rights reserved.
//

#import "MDAppDelegate.h"
#import "MDViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "BounceMenuController.h"

@interface MDAppDelegate () <BounceMenuControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *stepsQueue;
@property (nonatomic, strong) CMStepCounter *stepCounter;
@property (nonatomic, strong) NSNumber *stepsTaken;
@property (nonatomic, strong) MDViewController* vc1;

@end

@implementation MDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    BounceMenuController *bounceMenuController = [[BounceMenuController alloc] init];
    _stepsQueue = [[NSOperationQueue alloc] init];
    
    // Setup step counting
    [self setupStepCounter];
    
    // create view controllers from code
    _vc1 = [[MDViewController alloc] initWithNibName:@"MDViewController" bundle:nil];
    _vc1.view.backgroundColor = [UIColor colorWithRed:0.21f green:0.33f blue:0.53f alpha:1.00f];
    
    // set the view controllers for the bounce menu
    NSArray* controllers = [NSArray arrayWithObjects:_vc1, nil];
    bounceMenuController.viewControllers = controllers;
    bounceMenuController.delegate = self;
    
    self.window.rootViewController = bounceMenuController;
    [self.window makeKeyAndVisible];
    
    [self performSelector:@selector(addSteps:fromInterval:) withObject:nil afterDelay:4.0];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Will Resign Active");
    // save the current timestamp to query against on re-launch
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"resignActiveDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)bouncMenuController:(BounceMenuController *)controller shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)bouncMenuController:(BounceMenuController *)controller didSelectViewController:(UIViewController *)viewController {
    NSLog(@"selected view controller: %@", viewController);
}

#pragma mark - Step Counting

- (void)addSteps:(NSInteger)steps fromInterval:(NSTimeInterval)interval
{
    // compare the current time with the stored timestamp and get any steps taken
    NSDate *resignActiveDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"resignActiveDate"];
    
    if ([CMStepCounter isStepCountingAvailable]) {
        NSDate *currentDate = [NSDate date];
        if (!resignActiveDate) {
            resignActiveDate = [NSDate date];
        }
        
        [_stepCounter queryStepCountStartingFrom:resignActiveDate
                                             to:currentDate
                                        toQueue:_stepsQueue
                                    withHandler:^(NSInteger numberOfSteps, NSError *error)
         {
             NSLog(@"Adding %lu Steps", numberOfSteps);
             
             _stepsTaken = [NSNumber numberWithInteger:numberOfSteps+[_stepsTaken integerValue]];
             [[NSUserDefaults standardUserDefaults] setObject:_stepsTaken forKey:@"stepsTaken"];
             [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"resignActiveDate"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [self performSelectorOnMainThread:@selector(updateLabelWithSteps:) withObject:_stepsTaken waitUntilDone:NO];
         }];
    }
}

- (void)updateLabelWithSteps:(NSNumber *)steps
{
    [_vc1 incrementStepLabelBy:_stepsTaken];
    [self performSelector:@selector(addSteps:fromInterval:) withObject:nil afterDelay:4.0];
}

- (BOOL)setupStepCounter
{
    NSLog(@"Did Load");
    _stepsTaken = [[NSUserDefaults standardUserDefaults] objectForKey:@"stepsTaken"];
    _stepsQueue = [[NSOperationQueue alloc] init];
    
    if ([CMStepCounter isStepCountingAvailable]) {
        _stepCounter = [[CMStepCounter alloc] init];
        return TRUE;
    } else {
        NSLog(@"alert, tell the user to turn on motion if they want to use the app");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Step Counting Not Available!" message:@"If you turned off Motion Activity in your device's Privacy Settings, please turn it back on to continue.  If you are using a device without Step Counting capabilities, enjoy the background colors." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return FALSE;
    }
}

@end
