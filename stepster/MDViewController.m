//
//  MDViewController.m
//  stepster
//
//  Created by John Clem on 9/27/13.
//  Copyright (c) 2013 Mind DIaper. All rights reserved.
//

#import "MDViewController.h"
#import "BounceMenuController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MDViewController () <UIAlertViewDelegate, SKProductsRequestDelegate>

@property (nonatomic, strong) NSNumber *stepsTaken;
@property (nonatomic, weak) IBOutlet UILabel *stepCounterLabel;
@property (nonatomic, weak) IBOutlet UIButton *storeButton;
@property (nonatomic, strong) NSArray *products;

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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.view.frame.size.height < 568) {
        [_buttonsView.subviews[8] removeFromSuperview];
    }

    _stepsTaken = [[NSUserDefaults standardUserDefaults] objectForKey:@"stepsTaken"];
    [_stepCounterLabel setText:[NSString stringWithFormat:@"%ld", (long)[_stepsTaken integerValue]]];

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

- (void)incrementStepLabelBy:(NSNumber *)count
{
    [_stepCounterLabel setText:[NSString stringWithFormat:@"%ld", (long)[count integerValue]]];
}

- (void)incrementStepLabelBy:(NSNumber *)count animated:(BOOL)animated
{
    // needs implementation
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma StoreKit

- (IBAction)doInAppPurchase:(id)sender
{
    NSArray *productIDs = [self productIdentifiers];
    NSLog(@"Product IDs: %@", productIDs);
    [self validateProductIdentifiers:productIDs];
    
}

- (NSArray *)productIdentifiers
{
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"product_ids"
                                          withExtension:@"plist"];
    return [NSArray arrayWithContentsOfURL:url];
}

- (void) validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    self.products = response.products;
    
    for (NSString * invalidProductIdentifier in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid Product ID: %@", invalidProductIdentifier);
    }
    
    if (self.products.count > 0) {
        [self makePurchaseWithProduct:self.products[0]];
    }

}

- (void)makePurchaseWithProduct:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"Updated Transactions");
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"Transaction: %ld", (long)transaction.transactionState);
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            NSLog(@"Already Purchased");
            [_storeButton removeFromSuperview];
        }
    }
}


@end
