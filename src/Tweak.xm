#import "../headers/HeadersTweak.h"

Velvet2PrefsManager *prefsManager;

%hook NCNotificationShortLookViewController

%property (nonatomic, retain) UIView *velvetView;

-(void)viewDidLoad {
    %orig;
    NCNotificationShortLookView *view = (NCNotificationShortLookView *)self.viewForPreview;
    if (!view) return;
    self.velvetView = [[UIView alloc] initWithFrame:view.bounds];
    [self.velvetView.layer addSublayer:[CALayer layer]];
    [self.velvetView.layer addSublayer:[CALayer layer]];
    [view.backgroundMaterialView.superview insertSubview:self.velvetView atIndex:1];
    self.velvetView.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
}

-(void)viewDidLayoutSubviews {
    %orig;
    if (self.viewForPreview.frame.size.width == 0) return;
    [self velvetUpdateStyle];
}

-(void)viewDidAppear:(BOOL)animated {
    %orig;
    NCNotificationShortLookView *view = (NCNotificationShortLookView *)self.viewForPreview;
    if (!view) return;
    NSString *identifier = ((NCNotificationShortLookViewController *)self).notificationRequest.sectionIdentifier;
    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:identifier];
    NCNotificationSeamlessContentView *contentView = [view valueForKey:@"notificationContentView"];
    if (contentView) {
        UIImage *appIcon = contentView.prominentIcon ?: contentView.subordinateIcon;
        NCBadgedIconView *badgedIconView = [contentView valueForKey:@"badgedIconView"];
        UIView *appIconView = badgedIconView.iconView;
        colorizer.appIcon = appIcon;
        [colorizer colorDate:[contentView valueForKey:@"dateLabel"]];
        [colorizer setAppIconCornerRadius:appIconView];
    }
}

%new
-(void)velvetUpdateStyle {
    NCNotificationShortLookView *view = (NCNotificationShortLookView *)self.viewForPreview;
    if (!view) return;
    NSString *identifier = ((NCNotificationShortLookViewController *)self).notificationRequest.sectionIdentifier;
    MTMaterialView *materialView = view.backgroundMaterialView;
    if (!materialView) return;
    NCNotificationViewControllerView *controllerView = [self valueForKey:@"contentSizeManagingView"];
    UIView *stackDimmingView = SYSTEM_VERSION_LESS_THAN(@"16.0") ? [controllerView valueForKey:@"stackDimmingView"] : [view valueForKey:@"stackDimmingOverlayView"];
    NCNotificationSeamlessContentView *contentView = [view valueForKey:@"notificationContentView"];
    if (!contentView) return;
    UILabel *title = [contentView valueForKey:@"primaryTextLabel"];
    UILabel *message = [contentView valueForKey:@"secondaryTextElement"];
    UILabel *dateLabel = [contentView valueForKey:@"dateLabel"];
    NCBadgedIconView *badgedIconView = [contentView valueForKey:@"badgedIconView"];
    UIView *appIconView = badgedIconView.iconView;
    UIImage *appIcon = contentView.prominentIcon ?: contentView.subordinateIcon;
    self.velvetView.frame = materialView.frame;
    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:identifier];
    colorizer.appIcon = appIcon;
    CGFloat defaultCornerRadius = SYSTEM_VERSION_LESS_THAN(@"16.0") ? 19 : 23.5;
    CGFloat cornerRadius = [[prefsManager settingForKey:@"cornerRadiusEnabled" withIdentifier:identifier] boolValue] ? [[prefsManager settingForKey:@"cornerRadiusCustom" withIdentifier:identifier] floatValue] : defaultCornerRadius;
    materialView.layer.cornerRadius = MIN(cornerRadius, CGRectGetHeight(materialView.frame) / 2);
    materialView.layer.continuousCorners = cornerRadius < CGRectGetHeight(materialView.frame) / 2;
    self.velvetView.layer.cornerRadius = MIN(cornerRadius, CGRectGetHeight(self.velvetView.frame) / 2);
    self.velvetView.layer.continuousCorners = cornerRadius < CGRectGetHeight(self.velvetView.frame) / 2;
    view.layer.cornerRadius = MIN(cornerRadius, CGRectGetHeight(view.frame) / 2);
    view.layer.continuousCorners = cornerRadius < CGRectGetHeight(view.frame) / 2;
    if (materialView.superview) {
        materialView.superview.layer.cornerRadius = MIN(cornerRadius, CGRectGetHeight(materialView.superview.frame) / 2);
        materialView.superview.layer.continuousCorners = cornerRadius < CGRectGetHeight(materialView.superview.frame) / 2;
    }
    if (stackDimmingView) {
        stackDimmingView.layer.cornerRadius = MIN(cornerRadius, CGRectGetHeight(stackDimmingView.frame) / 2);
        stackDimmingView.layer.continuousCorners = cornerRadius < CGRectGetHeight(stackDimmingView.frame) / 2;
    }
    stackDimmingView.hidden = [[prefsManager settingForKey:@"stackDimmingViewHidden" withIdentifier:identifier] boolValue];
    [colorizer setAppIconCornerRadius:appIconView];
    [colorizer colorBackground:self.velvetView];
    [colorizer setBackgroundBlur:materialView];
    [colorizer colorBorder:self.velvetView];
    [colorizer colorShadow:materialView];
    [colorizer colorLine:self.velvetView inFrame:materialView.frame];
    [colorizer colorTitle:title];
    [colorizer colorMessage:message];
    [colorizer colorDate:dateLabel];
    [colorizer setAppearance:self.view];
}
%end

%hook NCNotificationSummaryPlatterView
%property (nonatomic, strong) UIView *velvetView;

-(void)didMoveToWindow {
    if (!self.velvetView) {
        self.velvetView = [[UIView alloc] init];
        CALayer *backgroundLayer = [CALayer layer];
        [self.velvetView.layer addSublayer:backgroundLayer];
        [self insertSubview:self.velvetView atIndex:1];
        self.velvetView.clipsToBounds = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
    }
}

-(void)layoutSubviews {
    %orig;
    [self velvetUpdateStyle];
}

%new
-(void)velvetUpdateStyle {
    MTMaterialView *materialView = (MTMaterialView *)self.subviews.firstObject;
    if (materialView) {
        self.velvetView.frame = materialView.frame;
        CGFloat cornerRadius = SYSTEM_VERSION_LESS_THAN(@"16.0") ? 19 : 23.5;
        if ([[prefsManager settingForKey:@"cornerRadiusEnabled" withIdentifier:@"com.noisyflake.velvetFocus"] boolValue]) {
            cornerRadius = [[prefsManager settingForKey:@"cornerRadiusCustom" withIdentifier:@"com.noisyflake.velvetFocus"] floatValue];
        }
        materialView.layer.cornerRadius = MIN(cornerRadius, CGRectGetHeight(self.frame) / 2);
        materialView.layer.continuousCorners = cornerRadius < CGRectGetHeight(self.frame) / 2;
        self.velvetView.layer.cornerRadius = MIN(cornerRadius, CGRectGetHeight(self.velvetView.frame) / 2);
        self.velvetView.layer.continuousCorners = cornerRadius < CGRectGetHeight(self.velvetView.frame) / 2;
        Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:@"com.noisyflake.velvetFocus"];
        [colorizer colorBackground:self.velvetView];
        [colorizer colorBorder:self.velvetView];
        [colorizer colorShadow:materialView];
        [colorizer colorLine:self.velvetView inFrame:materialView.frame];
        NCNotificationSummaryContentView *contentView = [self valueForKey:@"summaryContentView"];
        UILabel *title = [contentView valueForKey:@"summaryTitleLabel"];
        UILabel *message = [contentView valueForKey:@"summaryLabel"];
        [colorizer colorTitle:title];
        [colorizer colorMessage:message];
        [colorizer setAppearance:self];
    }
}
%end

%hook NCNotificationSeamlessContentView

-(void)didMoveToWindow {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
}

-(void)layoutSubviews {
    %orig;
    [self velvetUpdateStyle];
}

%new
-(void)velvetUpdateStyle {
    NCNotificationShortLookViewController *controller = [self _viewControllerForAncestor];
    if (!controller) return;
    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:controller.notificationRequest.sectionIdentifier];
    UILabel *title = [self valueForKey:@"primaryTextLabel"];
    UILabel *message = [self valueForKey:@"secondaryTextElement"];
    UILabel *footer = [self valueForKey:@"footerTextLabel"];
    NCBadgedIconView *badgedIconView = [self valueForKey:@"badgedIconView"];
    [colorizer toggleAppIconVisibility:badgedIconView withTitle:title message:message footer:footer alwaysUpdate:YES];
}
%end

%hook NCNotificationListView
-(void)recycleVisibleViews {}
-(void)_recycleViewIfNecessary:(id)arg1 {}
-(void)_recycleViewIfNecessary:(id)arg1 withDataSource:(id)arg2 {}
%end

%ctor {
    prefsManager = [NSClassFromString(@"Velvet2PrefsManager") sharedInstance];
    if ([[prefsManager objectForKey:@"enabled"] boolValue]) {
        %init;
    }
}