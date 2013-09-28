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

@implementation MDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    NSLog(@"Did Finish Launching");

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
    
    if ([CMStepCounter isStepCountingAvailable] && resignActiveDate) {
        NSDate *currentDate = [NSDate date];
        
        CMStepCounter *stepCounter = [CMStepCounter new];
        [stepCounter queryStepCountStartingFrom:resignActiveDate
                                             to:currentDate
                                        toQueue:[NSOperationQueue mainQueue]
                                    withHandler:^(NSInteger numberOfSteps, NSError *error)
         {
             [[NSUserDefaults standardUserDefaults] setInteger:numberOfSteps forKey:@"missingSteps"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             NSLog(@"Missing Steps: %lu", (long)numberOfSteps);
             [(MDViewController *)self.window.rootViewController addMissingSteps];
         }];
    }

    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    NSLog(@"Will Terminate");
}

@end
