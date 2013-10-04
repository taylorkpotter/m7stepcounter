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

@end

@implementation MDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    BounceMenuController *bounceMenuController = [[BounceMenuController alloc] init];
    
    // create view controllers from code
    MDViewController* vc1 = [[MDViewController alloc] initWithNibName:@"MDViewController" bundle:nil];
    vc1.view.backgroundColor = [UIColor colorWithRed:0.21f green:0.33f blue:0.53f alpha:1.00f];
//    vc1.tabBarItem.image = [UIImage imageNamed:@"tabBar"];
    
    
    // set the view controllers for the bounc menu
    NSArray* controllers = [NSArray arrayWithObjects:vc1, nil];
    bounceMenuController.viewControllers = controllers;
    bounceMenuController.delegate = self;
    
    self.window.rootViewController = bounceMenuController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
//    NSLog(@"Will Resign Active");
    // save the current timestamp to query against on re-launch
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"resignActiveDate"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"missingSteps"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    NSLog(@"Did Enter Background");

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    NSLog(@"Will Enter Foreground");

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // compare the current time with the stored timestamp and get any steps taken
    
    NSDate *resignActiveDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"resignActiveDate"];
    
    if ([CMStepCounter isStepCountingAvailable]) {
        NSDate *currentDate = [NSDate date];
        if (!resignActiveDate) {
            resignActiveDate = [NSDate date];
        }
        
        CMStepCounter *stepCounter = [CMStepCounter new];
        [stepCounter queryStepCountStartingFrom:resignActiveDate
                                             to:currentDate
                                        toQueue:[NSOperationQueue mainQueue]
                                    withHandler:^(NSInteger numberOfSteps, NSError *error)
         {
             [[NSUserDefaults standardUserDefaults] setInteger:numberOfSteps forKey:@"missingSteps"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             NSLog(@"Missing Steps: %lu", (long)numberOfSteps);
             [(MDViewController*)[[(BounceMenuController *)self.window.rootViewController viewControllers] objectAtIndex:0] addMissingSteps];
         }];
    }

    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    NSLog(@"Will Terminate");
}

- (BOOL)bouncMenuController:(BounceMenuController *)controller shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)bouncMenuController:(BounceMenuController *)controller didSelectViewController:(UIViewController *)viewController {
    NSLog(@"selected view controller: %@", viewController);
}


@end
