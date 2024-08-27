#import "../headers/HeadersTweak.h"

@implementation Velvet2Colorizer

- (instancetype)initWithIdentifier:(NSString *)identifier {
	Velvet2Colorizer *colorizer = [super init];
	self.identifier = identifier;
	self.manager = [Velvet2PrefsManager sharedInstance];
	return colorizer;
}

- (UIColor*)iconColor {
	if (!_iconColor) {
		NSArray *iconColors = [[CCColorCube new] extractColorsFromImage:self.appIcon flags:CCAvoidWhite|CCOnlyBrightColors count:1];
		_iconColor = iconColors.count ? iconColors[0] : nil;
	}
	return _iconColor;
}

- (void)colorBackground:(UIView *)backgroundView {
	UIColor *backgroundColor;
	BOOL backgroundEnabled = [[self.manager settingForKey:@"backgroundEnabled" withIdentifier:self.identifier] boolValue];

	if (backgroundEnabled) {
		NSString *backgroundType = [self.manager settingForKey:@"backgroundType" withIdentifier:self.identifier];
		if ([backgroundType isEqual:@"color"]) {
			backgroundColor = [self.manager colorForKey:@"backgroundColor" withIdentifier:self.identifier];
		} else if ([backgroundType isEqual:@"gradient"]) {
			NSArray *gradientColors = @[(id)[self.manager colorForKey:@"backgroundGradient1" withIdentifier:self.identifier].CGColor, (id)[self.manager colorForKey:@"backgroundGradient2" withIdentifier:self.identifier].CGColor];
			backgroundColor = [UIColor colorFromGradient:gradientColors withDirection:[self.manager settingForKey:@"backgroundGradientDirection" withIdentifier:self.identifier] inFrame:backgroundView.frame];
		} else if ([backgroundType isEqual:@"icon"]) {
			backgroundColor = self.iconColor ? [self.iconColor colorWithAlphaComponent:[self.manager alphaValueForKey:@"backgroundIconAlpha" withIdentifier:self.identifier]] : nil;
		}
	}
	backgroundView.backgroundColor = backgroundColor;
}

- (void)setBackgroundBlur:(UIView *)materialView {
	BOOL hideBackground = [[self.manager settingForKey:@"backgroundBlurHidden" withIdentifier:self.identifier] boolValue];
	materialView.alpha = hideBackground ? 0 : 1;
	materialView.hidden = hideBackground ? YES : NO;
}

- (void)colorBorder:(UIView *)borderView {
	UIColor *borderColor;
	BOOL borderEnabled = [[self.manager settingForKey:@"borderEnabled" withIdentifier:self.identifier] boolValue];

	if (borderEnabled) {
		NSString *borderType = [self.manager settingForKey:@"borderType" withIdentifier:self.identifier];
		if ([borderType isEqual:@"color"]) {
			borderColor = [self.manager colorForKey:@"borderColor" withIdentifier:self.identifier];
		} else if ([borderType isEqual:@"gradient"]) {
			NSArray *gradientColors = @[(id)[self.manager colorForKey:@"borderGradient1" withIdentifier:self.identifier].CGColor, (id)[self.manager colorForKey:@"borderGradient2" withIdentifier:self.identifier].CGColor];
			borderColor = [UIColor colorFromGradient:gradientColors withDirection:[self.manager settingForKey:@"borderGradientDirection" withIdentifier:self.identifier] inFrame:borderView.frame flipY:YES];
		} else if ([borderType isEqual:@"icon"]) {
			borderColor = self.iconColor ? [self.iconColor colorWithAlphaComponent:[self.manager alphaValueForKey:@"borderIconAlpha" withIdentifier:self.identifier]] : nil;
		}
	}
	borderView.layer.borderWidth = borderColor ? [[self.manager settingForKey:@"borderWidth" withIdentifier:self.identifier] floatValue] : 0;
	borderView.layer.borderColor = borderColor ? borderColor.CGColor : nil;
}

- (void)colorShadow:(UIView *)shadowView {
	UIColor *shadowColor;
	BOOL shadowEnabled = [[self.manager settingForKey:@"shadowEnabled" withIdentifier:self.identifier] boolValue];

	if (shadowEnabled) {
		NSString *shadowType = [self.manager settingForKey:@"shadowType" withIdentifier:self.identifier];
		if ([shadowType isEqual:@"color"]) {
			shadowColor = [self.manager colorForKey:@"shadowColor" withIdentifier:self.identifier];
		} else if ([shadowType isEqual:@"icon"]) {
			shadowColor = self.iconColor ? [self.iconColor colorWithAlphaComponent:[self.manager alphaValueForKey:@"shadowIconAlpha" withIdentifier:self.identifier]] : nil;
		}
	}
	shadowView.layer.shadowRadius = shadowColor ? [[self.manager settingForKey:@"shadowWidth" withIdentifier:self.identifier] floatValue] : 0;
	shadowView.layer.shadowOffset = CGSizeZero;
	shadowView.layer.shadowColor = shadowColor ? shadowColor.CGColor : nil;
	shadowView.layer.shadowOpacity = 1;
}

- (void)colorLine:(UIView *)lineView inFrame:(CGRect)frame {
	NSString *position = [self.manager settingForKey:@"linePosition" withIdentifier:self.identifier];
	CGFloat size = [[self.manager settingForKey:@"lineWidth" withIdentifier:self.identifier] floatValue];
	
	CGRect (^adjustFrame)(CGRect) = ^(CGRect frame) {
		CGFloat x = [position isEqual:@"right"] || [position isEqual:@"leftRight"] ? frame.size.width - size : 0;
		CGFloat y = [position isEqual:@"bottom"] || [position isEqual:@"topBottom"] ? frame.size.height - size : 0;
		CGFloat width = [position isEqual:@"top"] || [position isEqual:@"bottom"] || [position isEqual:@"topBottom"] ? frame.size.width : size;
		CGFloat height = [position isEqual:@"left"] || [position isEqual:@"right"] || [position isEqual:@"leftRight"] ? frame.size.height : size;
		return CGRectMake(x, y, width, height);
	};
	
	lineView.layer.sublayers[0].frame = adjustFrame(lineView.layer.sublayers[0].frame);

	if ([position isEqual:@"topBottom"] || [position isEqual:@"leftRight"]) {
		lineView.layer.sublayers[1].frame = adjustFrame(lineView.layer.sublayers[0].frame);
	} else {
		lineView.layer.sublayers[1].frame = CGRectZero;
	}

	UIColor *lineColor;
	BOOL lineEnabled = [[self.manager settingForKey:@"lineEnabled" withIdentifier:self.identifier] boolValue];

	if (lineEnabled) {
		NSString *lineType = [self.manager settingForKey:@"lineType" withIdentifier:self.identifier];
		if ([lineType isEqual:@"color"]) {
			lineColor = [self.manager colorForKey:@"lineColor" withIdentifier:self.identifier];
		} else if ([lineType isEqual:@"gradient"]) {
			NSArray *gradientColors = @[(id)[self.manager colorForKey:@"lineGradient1" withIdentifier:self.identifier].CGColor, (id)[self.manager colorForKey:@"lineGradient2" withIdentifier:self.identifier].CGColor];
			lineColor = [UIColor colorFromGradient:gradientColors withDirection:[self.manager settingForKey:@"lineGradientDirection" withIdentifier:self.identifier] inFrame:lineView.layer.sublayers[0].frame flipY:YES];
		} else if ([lineType isEqual:@"icon"]) {
			lineColor = self.iconColor ? [self.iconColor colorWithAlphaComponent:[self.manager alphaValueForKey:@"lineIconAlpha" withIdentifier:self.identifier]] : nil;
		}
	}

	lineView.layer.sublayers[0].backgroundColor = lineColor ? lineColor.CGColor : nil;
	lineView.layer.sublayers[1].backgroundColor = lineColor ? lineColor.CGColor : nil;
}

- (void)colorTitle:(UILabel*)title {
	UIColor *titleColor;
	BOOL titleEnabled = [[self.manager settingForKey:@"titleEnabled" withIdentifier:self.identifier] boolValue];

	if (titleEnabled) {
		NSString *titleType = [self.manager settingForKey:@"titleType" withIdentifier:self.identifier];
		if ([titleType isEqual:@"color"]) {
			titleColor = [self.manager colorForKey:@"titleColor" withIdentifier:self.identifier];
		} else if ([titleType isEqual:@"icon"]) {
			titleColor = self.iconColor ? [self.iconColor colorWithAlphaComponent:[self.manager alphaValueForKey:@"titleIconAlpha" withIdentifier:self.identifier]] : nil;
		}
	}
	title.textColor = titleColor ? titleColor : [UIColor.labelColor colorWithAlphaComponent:0.9];
}

- (void)colorMessage:(UILabel*)message {
	UIColor *messageColor;
	BOOL messageEnabled = [[self.manager settingForKey:@"messageEnabled" withIdentifier:self.identifier] boolValue];

	if (messageEnabled) {
		NSString *messageType = [self.manager settingForKey:@"messageType" withIdentifier:self.identifier];
		if ([messageType isEqual:@"color"]) {
			messageColor = [self.manager colorForKey:@"messageColor" withIdentifier:self.identifier];
		} else if ([messageType isEqual:@"icon"]) {
			messageColor = self.iconColor ? [self.iconColor colorWithAlphaComponent:[self.manager alphaValueForKey:@"messageIconAlpha" withIdentifier:self.identifier]] : nil;
		}
	}
	message.textColor = messageColor ? messageColor : [UIColor.labelColor colorWithAlphaComponent:0.9];
}

- (void)colorDate:(UILabel*)date {
	UIColor *dateColor;
	BOOL dateEnabled = [[self.manager settingForKey:@"dateEnabled" withIdentifier:self.identifier] boolValue];

	if (dateEnabled) {
		NSString *dateType = [self.manager settingForKey:@"dateType" withIdentifier:self.identifier];
		if ([dateType isEqual:@"color"]) {
			dateColor = [self.manager colorForKey:@"dateColor" withIdentifier:self.identifier];
		} else if ([dateType isEqual:@"icon"]) {
			dateColor = self.iconColor ? [self.iconColor colorWithAlphaComponent:[self.manager alphaValueForKey:@"dateIconAlpha" withIdentifier:self.identifier]] : nil;
		}
	}
	date.textColor = dateColor ? dateColor : [UIColor.labelColor colorWithAlphaComponent:0.5];
}

- (void)setAppIconCornerRadius:(UIView*)appIcon {
	appIcon.clipsToBounds = YES;
	CGFloat cornerRadius = [[self.manager settingForKey:@"appIconCornerRadiusCircle" withIdentifier:self.identifier] boolValue] ? appIcon.frame.size.height / 2 : 0;
	appIcon.layer.cornerRadius = cornerRadius;
}

- (void)toggleAppIconVisibility:(UIView*)appIcon withTitle:(UILabel*)title message:(UILabel*)message footer:(UILabel*)footer alwaysUpdate:(BOOL)alwaysUpdate {
	BOOL shouldHide = [[self.manager settingForKey:@"appIconHidden" withIdentifier:self.identifier] boolValue];
	BOOL hideIcon = shouldHide && (!appIcon.hidden || alwaysUpdate);
	
	CGFloat offset = hideIcon ? -appIcon.frame.size.width - 8 : appIcon.frame.size.width + 8;
	appIcon.alpha = hideIcon ? 0 : 1;
	appIcon.hidden = hideIcon ? YES : NO;

	CGRect (^adjustFrame)(CGRect) = ^(CGRect frame) {
		CGFloat x = hideIcon ? frame.origin.x + offset : frame.origin.x;
		CGFloat width = hideIcon ? frame.size.width - offset : frame.size.width;
		return CGRectMake(x, frame.origin.y, width, frame.size.height);
	};
	
	title.frame = adjustFrame(title.frame);
	message.frame = adjustFrame(message.frame);
	if (footer) footer.frame = adjustFrame(footer.frame);
}

- (void)setAppearance:(UIView*)view {
	NSString *appearance = [self.manager settingForKey:@"appearance" withIdentifier:self.identifier];
	view.overrideUserInterfaceStyle = [appearance isEqualToString:@"dark"] ? UIUserInterfaceStyleDark : [appearance isEqualToString:@"light"] ? UIUserInterfaceStyleLight : UIUserInterfaceStyleUnspecified;
}

@end
