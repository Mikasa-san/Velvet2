#import "../headers/HeadersPreferences.h"

@implementation Velvet2SettingsController

- (NSArray *)specifiers {
	if (!_specifiers) {
        _specifiers = [self visibleSpecifiersFromPlist:@"Settings"];
	}

	return _specifiers;
}

@end