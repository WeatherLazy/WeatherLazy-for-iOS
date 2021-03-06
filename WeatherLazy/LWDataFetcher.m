//
//  LWDataFetcher.m
//  WeatherLazy
//
//  Created by John Lanier and Arthur Pan on 10/10/15.
//  Copyright © 2015 WeatherLazy Team. All rights reserved.
//

#import "LWDataFetcher.h"
#import "LWDailyForecast.h"
#import "LWWeatherStore.h"
#import "LWWeatherUpdateManager.h"



@import CoreLocation;

@interface LWDataFetcher () <CLLocationManagerDelegate>

@property (nonatomic) NSURLSession *session;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) void (^dataFetchCompletionHandler)(NSError *);

@property (nonatomic) BOOL ProcedeAfterLocationUpdateAllowed;

@end

@implementation LWDataFetcher

#pragma mark - Initialiazation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ProcedeAfterLocationUpdateAllowed = YES;
        NSURLSessionConfiguration *config =
            [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }

    }
    return self;
}

#pragma mark - BeginUpdatingWeather

- (void)beginUpdatingWeatherWithCompletionHandler:(void (^)(NSError *))completionHandler
{
    self.dataFetchCompletionHandler = completionHandler;
    [self.locationManager requestLocation];
    
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        //NSLog(@"ALWAYS LOCATION STATUS REGISTERED!!!!!!");
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        //NSLog(@" LOCATION STATUS NOT DETERMINED!!!!!!");
    } else if (status == kCLAuthorizationStatusDenied) {
        //NSLog(@"DENIED LOCATION STATUS !!!!!!");
        [self displayLocationStatusAuthorizationAlert];
        
    } else {
        //NSLog(@"UNEXPECTED LOCATION AUTHORIZATION STATUS: %d", status);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    if (!self.ProcedeAfterLocationUpdateAllowed) {
        return;
    }
    self.ProcedeAfterLocationUpdateAllowed = NO;
    
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(allowProcedingAfterLocationUpdate)
                                   userInfo:nil
                                    repeats:NO];
    
    //NSLog(@"LOCATION UPDATED AND PROCEDING");
    [self fetchJSONDataForLocation:[locations lastObject]];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        //NSLog(@"LazyWether does not have correct location authorization status");
    }
    //NSLog(@"Location Request Failed: \n %@", error.debugDescription);
    self.dataFetchCompletionHandler(error);
}

- (void)allowProcedingAfterLocationUpdate {
    self.ProcedeAfterLocationUpdateAllowed = YES;
}

#pragma mark - Fetch JSON Data

- (void)fetchJSONDataForLocation:(CLLocation *)location
{
    double latitude  = location.coordinate.latitude;
    double longitude = location.coordinate.longitude;
    
    NSString *requestString = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%f,%f",self.key,latitude,longitude];
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask =
        [self.session dataTaskWithRequest:req completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
    
             if (error) {
                 //NSLog(@"JSON Request Failed: \n %@", error.debugDescription);
                 self.dataFetchCompletionHandler(error);
             } else {
                 [self SetLocalityForWeatherStore:location];
                 
                 NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:nil];
                 ////NSLog(@"JSON DATA = %@",jsonObject);
                 if (!jsonObject) {
                     NSError *jsonError = [NSError errorWithDomain:@"JSON Data returned was null, incorrect API key or problems on their end may be the culprit"
                                                          code:-1
                                                      userInfo:nil];
                     self.dataFetchCompletionHandler(jsonError);
                 }

                 [self SendRelevantDataToWeatherStore:jsonObject];
             }
         }];
    
    [dataTask resume];
}

#pragma mark - Store Data in WeatherStore

- (void)SendRelevantDataToWeatherStore:(NSDictionary *)jsonData
{
    NSMutableArray *newWeatherStoreForecasts = [[NSMutableArray alloc] init];
    
    NSArray *dailyData = jsonData[@"daily"][@"data"];
    for (NSMutableDictionary *day in dailyData) {
        
        NSNumber *precipProbabilityPointer = day[@"precipProbability"];
        NSInteger precipProbability = precipProbabilityPointer.floatValue *100;
        NSNumber *highPointer = day[@"temperatureMax"];
        NSInteger high = highPointer.integerValue;
        NSNumber *lowPointer  = day[@"temperatureMin"];
        NSInteger low = lowPointer.integerValue;
        NSString *summary = day[@"summary"];
        
        NSNumber *unixTimeStamp = day[@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([unixTimeStamp doubleValue])];
        
        LWDailyForecast *newForecast = [[LWDailyForecast alloc] initWithPrecipitationProbability:precipProbability
                                                                                 HighTemperature:high
                                                                                  LowTemperature:low
                                                                                         Summary:summary
                                                                                            Date:date];
        [newWeatherStoreForecasts addObject:newForecast];
    }
    [[LWWeatherStore sharedStore] setNewForecasts:newWeatherStoreForecasts];
    
    self.dataFetchCompletionHandler(nil);
}

- (void)SetLocalityForWeatherStore:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *locationPlacemark = [placemarks lastObject];
            [LWWeatherStore sharedStore].localityOfForecasts = locationPlacemark.locality;
            
        } else {
            //NSLog(@"Reverse Geocoding Failed: \n %@", error.debugDescription);
            [LWWeatherStore sharedStore].localityOfForecasts = nil;
        }
    } ];
}

#pragma mark - Accessors for API Key

- (NSString *)key
{
    //
    //
    //
    //
    //     MAKE SURE THIS IS UP TO DATE!!!!!!!!!
    //
    return @"55186fbb801b8b0d88a6c093a4c39208";
    //
    //
    //
    //
    //
    //
}

- (void)setKey:(NSString *)key
{
    @throw [NSException exceptionWithName:@"Can't Modify Key"
                                   reason:@"Key is to be a constant]"
                                 userInfo:nil];
}

- (void) displayLocationStatusAuthorizationAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location Services Disabled"
                                                                             message:@"WeatherLazy can't work properly without location sevices. You'll have to change this manually in settings."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    //We add buttons to the alert controller by creating UIAlertActions:
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction) {
        NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingsUrl]) {
            [[UIApplication sharedApplication] openURL:settingsUrl];
        }
    }];
    
    [alertController addAction:actionOk];
    [alertController addAction:settingsAction];
    UIViewController* rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    [rootVC presentViewController:alertController animated:YES completion:nil];
}

@end
