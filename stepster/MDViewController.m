//
//  MDViewController.m
//  stepster
//
//  Created by John Clem on 9/27/13.
//  Copyright (c) 2013 Mind DIaper. All rights reserved.
//

#import "MDViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface MDViewController ()
{
  
    __weak IBOutlet UILabel *stepCounterLabel;
    NSOperationQueue *stepsQueue;
    NSInteger stepsTaken;
}
@property (nonatomic, strong) CMStepCounter *stepCounter;

@end

@implementation MDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Did Load");
    stepsQueue = [[NSOperationQueue alloc] init];
    
    if ([CMStepCounter isStepCountingAvailable]) {
        _stepCounter = [[CMStepCounter alloc] init];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Will Appear");
    if ([CMStepCounter isStepCountingAvailable]) {
        [_stepCounter startStepCountingUpdatesToQueue:stepsQueue
                                             updateOn:1
                                          withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                              if (error) {
                                                  NSLog(@"Error recording steps: %@", error);
                                              } else {
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                      stepsTaken += 1;
                                                      [[NSUserDefaults standardUserDefaults] setInteger:stepsTaken forKey:@"stepsTaken"];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                      [stepCounterLabel setText:[NSString stringWithFormat:@"%ld      steps", (long)stepsTaken]];
                                                  }];
                                              }
                                              
                                          }];
    } else {
        NSLog(@"alert, tell the user to turn on motion if they want to use the app");
    }
}

- (void)addMissingSteps
{
    NSLog(@"adding %lu missing steps", [[NSUserDefaults standardUserDefaults] integerForKey:@"missingSteps"]);
    
    stepsTaken = [[NSUserDefaults standardUserDefaults] integerForKey:@"stepsTaken"];
    NSInteger missingSteps = [[NSUserDefaults standardUserDefaults] integerForKey:@"missingSteps"];
    if (missingSteps > 0) {
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Missing Steps: %ld", (long)missingSteps] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alertView show];
        
        stepsTaken = stepsTaken + missingSteps;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"missingSteps"];
        [[NSUserDefaults standardUserDefaults] setInteger:stepsTaken forKey:@"stepsTaken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [stepCounterLabel setText:[NSString stringWithFormat:@"%ld      steps", (long)stepsTaken]];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
