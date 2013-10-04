//
//  BounceMenuController.h
//  BounceExample
//
//  Created by Benjamin Vogelzang on 9/25/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"

@class BounceMenuController;

@protocol BounceMenuControllerDelegate <NSObject>

- (BOOL)bouncMenuController:(BounceMenuController *)controller shouldSelectViewController:(UIViewController *)viewController;
- (void)bouncMenuController:(BounceMenuController *)controller didSelectViewController:(UIViewController *)viewController;

@end


@interface BounceMenuController : UIViewController <ADBannerViewDelegate>

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) id <BounceMenuControllerDelegate> delegate;

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *menuButtonColor;

@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@end
