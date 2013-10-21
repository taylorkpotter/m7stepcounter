//
//  MDViewController.h
//  stepster
//
//  Created by John Clem on 9/27/13.
//  Copyright (c) 2013 Mind DIaper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MDViewController : UIViewController <SKPaymentTransactionObserver>

- (void)incrementStepLabelBy:(NSNumber *)count;

@property (nonatomic, weak) IBOutlet UIView *buttonsView;

@end
