//
//  LWHomeViewController.h
//  WeatherLazy
//
//  Created by John Lanier and Arthur Pan on 10/10/15.
//  Copyright © 2015 WeatherLazy Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWHomeViewController : UIViewController

- (void)updateWeatherInfo;

- (void)weatherUpdateStarted;
- (void)weatherUpdateFailed;

@end
