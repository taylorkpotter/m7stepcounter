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

@property (nonatomic, strong) NSOperationQueue *stepsQueue;
@property (nonatomic, strong) CMStepCounter *stepCounter;
@property (nonatomic, strong) NSNumber *stepsTaken;
@property (nonatomic, weak) IBOutlet UILabel *stepCounterLabel;

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
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"stepsTaken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _stepsTaken = [[NSUserDefaults standardUserDefaults] objectForKey:@"stepsTaken"];
        [_stepCounterLabel setText:[NSString stringWithFormat:@"%d", [_stepsTaken intValue]]];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)setupStepCounter
{
    NSLog(@"Did Load");
    _stepsTaken = [[NSUserDefaults standardUserDefaults] objectForKey:@"stepsTaken"];
    _stepsQueue = [[NSOperationQueue alloc] init];
    [_stepsQueue setMaxConcurrentOperationCount:2];

    if ([CMStepCounter isStepCountingAvailable]) {
        _stepCounter = [[CMStepCounter alloc] init];
        [_stepCounter startStepCountingUpdatesToQueue:_stepsQueue
                                             updateOn:5
                                          withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                              NSDate *resignActiveDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"resignActiveDate"];
                                              
                                              CMStepCounter *stepCounter = [CMStepCounter new];
                                              [stepCounter queryStepCountStartingFrom:resignActiveDate
                                                                                   to:timestamp
                                                                              toQueue:_stepsQueue
                                                                          withHandler:^(NSInteger numberOfSteps, NSError *error)
                                               {
                                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                       [[NSUserDefaults standardUserDefaults] setInteger:numberOfSteps forKey:@"missingSteps"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:@"resignActiveDate"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       NSLog(@"Missing Steps: %lu", (long)numberOfSteps);
                                                       [self addMissingSteps];
                                                   }];
                                               }];
                                          }];
        return TRUE;
    } else {
        NSLog(@"alert, tell the user to turn on motion if they want to use the app");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Step Counting Not Available!" message:@"If you turned off Motion Activity in your device's Privacy Settings, please turn it back on to continue.  If you are using a device without Step Counting capabilities, enjoy the background colors." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return FALSE;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.view.frame.size.height < 568) {
        [_buttonsView.subviews[8] removeFromSuperview];
    }

    _stepsTaken = [[NSUserDefaults standardUserDefaults] objectForKey:@"stepsTaken"];
    [_stepCounterLabel setText:[NSString stringWithFormat:@"%d", [_stepsTaken intValue]]];

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

}

- (void)addMissingSteps
{
    if (!_stepCounter) {
        [self setupStepCounter];
    }
    NSInteger missingSteps = [[NSUserDefaults standardUserDefaults] integerForKey:@"missingSteps"];
    if (missingSteps > 0) {
        NSLog(@"Adding %ld missing steps", missingSteps);
        [self incrementStepLabelBy:missingSteps];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"missingSteps"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)incrementStepLabelBy:(NSInteger)count
{
    _stepsTaken = [NSNumber numberWithInteger:([_stepsTaken integerValue] + count)];
    [[NSUserDefaults standardUserDefaults] setObject:_stepsTaken forKey:@"stepsTaken"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSOperationQueue *labelQueue = [[NSOperationQueue alloc] init];
    [labelQueue setMaxConcurrentOperationCount:1];
    
    int currentCount = [_stepsTaken intValue];
    NSOperation *updateOperation;
    
    for (int i=0; i<count; i++)
    {
        updateOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self updateLabelWithString:[NSString stringWithFormat:@"%d", currentCount + i]];
        }];
        
        [labelQueue addOperations:@[updateOperation] waitUntilFinished:YES];
    }
    
}

- (void)updateLabelWithString:(NSString *)counterString
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_stepCounterLabel setText:counterString];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
