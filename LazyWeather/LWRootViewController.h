//
//  RootViewController.h
//  LazyWeather
//
//  Created by John Lanier and Arthur Pan on 10/15/15.
//  Copyright © 2015 LazyWeather Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

