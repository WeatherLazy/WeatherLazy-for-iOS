//
//  LWUnitsPromptCell.m
//  WeatherLazy
//
//  Created by John Lanier and Arthur Pan on 10/17/15.
//  Copyright © 2015 WeatherLazy Team. All rights reserved.
//

#import "LWUnitsPromptCell.h"
#import "LWSettingsStore.h"

@interface LWUnitsPromptCell ()

@property (weak, nonatomic) IBOutlet UISwitch *celsiusSwitch;

@end

@implementation LWUnitsPromptCell

- (IBAction)celsiusSwitch:(id)sender {
    [LWSettingsStore sharedStore].useCelciusDegrees = ![LWSettingsStore sharedStore].useCelciusDegrees;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.celsiusSwitch.on = [LWSettingsStore sharedStore].useCelciusDegrees;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.celsiusSwitch.on = [LWSettingsStore sharedStore].useCelciusDegrees;
}

@end
