//
//  ModelController.h
//  WeatherLazy
//
//  Created by John Lanier and Arthur Pan on 10/15/15.
//  Copyright © 2015 WeatherLazy Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPageViewModelController : NSObject <UIPageViewControllerDataSource>

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(UIViewController *)viewController;

@end

