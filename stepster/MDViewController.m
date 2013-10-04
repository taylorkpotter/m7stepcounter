//
//  MDViewController.m
//  stepster
//
//  Created by John Clem on 9/27/13.
//  Copyright (c) 2013 Mind DIaper. All rights reserved.
//

#import "MDViewController.h"
#import "BounceMenuController.h"
#import <CoreMotion/CoreMotion.h>

@interface MDViewController () <UIAlertViewDelegate>
{
  
    __weak IBOutlet UILabel *stepCounterLabel;
    NSOperationQueue *stepsQueue;
    NSInteger stepsTaken;
}
@property (nonatomic, strong) CMStepCounter *stepCounter;

@end

@implementation MDViewController

- (IBAction)resetCounter:(id)sender
{
    NSLog(@"Resetting Counter");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset Steps Counter?"
                                                        message:@"Do you really want to reset your steps counter to zero? This action is permanent yo"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Reset", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reset"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"stepsTaken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        stepsTaken = [[NSUserDefaults standardUserDefaults] integerForKey:@"stepsTaken"];
        [stepCounterLabel setText:[NSString stringWithFormat:@"%ld", (long)stepsTaken]];
    }
}

- (IBAction)changeColor:(id)sender
{
    NSLog(@"Changing color");
    CGFloat r,g,b,a;
    self.view.backgroundColor = [(UIButton *)sender backgroundColor];
    [self.view.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    
    [[NSUserDefaults standardUserDefaults] setFloat:r forKey:@"bgR"];
    [[NSUserDefaults standardUserDefaults] setFloat:g forKey:@"bgG"];
    [[NSUserDefaults standardUserDefaults] setFloat:b forKey:@"bgB"];
    [[NSUserDefaults standardUserDefaults] setFloat:a forKey:@"bgA"];
    
//    self.view.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1.f];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
    
    [stepCounterLabel setText:[NSString stringWithFormat:@"%ld", (long)stepsTaken]];

    CGFloat bgR;
    CGFloat bgG;
    CGFloat bgB;
    CGFloat bgA;
    
    @try {
        bgR = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgR"];
        bgG = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgG"];
        bgB = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgB"];
        bgA = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgA"];
        self.view.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:bgA];
    }
    @catch (NSException *exception) {
        
    }

    
    NSLog(@"Will Appear");
    if ([CMStepCounter isStepCountingAvailable]) {
        [_stepCounter startStepCountingUpdatesToQueue:stepsQueue
                                             updateOn:1
                                          withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                              if (error) {
                                                  NSLog(@"Error recording steps: %@", error);
                                              } else {
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                      stepsTaken += numberOfSteps;
                                                      [[NSUserDefaults standardUserDefaults] setInteger:stepsTaken forKey:@"stepsTaken"];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                      [stepCounterLabel setText:[NSString stringWithFormat:@"%ld", (long)stepsTaken]];
                                                  }];
                                              }
                                              
                                          }];
    } else {
        NSLog(@"alert, tell the user to turn on motion if they want to use the app");
    }
}

- (void)addMissingSteps
{
//    NSLog(@"adding %lu missing steps", [[NSUserDefaults standardUserDefaults] integerForKey:@"missingSteps"]);
    
    stepsTaken = [[NSUserDefaults standardUserDefaults] integerForKey:@"stepsTaken"];
    NSInteger oldSteps = stepsTaken;
    NSInteger missingSteps = [[NSUserDefaults standardUserDefaults] integerForKey:@"missingSteps"];
    if (missingSteps > 0) {
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Missing Steps: %ld", (long)missingSteps] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alertView show];
        
        stepsTaken = stepsTaken + missingSteps;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"missingSteps"];
        [[NSUserDefaults standardUserDefaults] setInteger:stepsTaken forKey:@"stepsTaken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    for (int i=oldSteps; i<stepsTaken; i++) {
        [stepCounterLabel setText:[NSString stringWithFormat:@"%ld", (long)oldSteps+i]];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
