#import <TargetConditionals.h>
#import <UIKit/UIKit.h>

// Local maxima as found during the image analysis. We need this class for ordering by cell hit count.
@interface CCLocalMaximum : NSObject

@property (assign, nonatomic) unsigned int hitCount;     // Hit count of the cell
@property (assign, nonatomic) unsigned int cellIndex;    // Linear index of the cell
@property (assign, nonatomic) CGFloat red;               // Average color of cell
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat brightness;        // Maximum color component value of average color 

@end

typedef NS_ENUM(NSUInteger, CCFlags) {
    CCOnlyBrightColors   = 1 << 0,
    CCOnlyDarkColors     = 1 << 1,
    CCOnlyDistinctColors = 1 << 2,
    CCOrderByBrightness  = 1 << 3,
    CCOrderByDarkness    = 1 << 4,
    CCAvoidWhite         = 1 << 5,
    CCAvoidBlack         = 1 << 6,
};

// The color cube is made out of these cells
typedef struct CCCubeCell {
    unsigned int hitCount;
    CGFloat redAcc;
    CGFloat greenAcc;
    CGFloat blueAcc;
} CCCubeCell;

@interface CCColorCube : NSObject

- (NSArray<UIColor *> * _Nullable)extractColorsFromImage:(UIImage * _Nonnull)image flags:(CCFlags)flags;
- (NSArray<UIColor *> * _Nullable)extractColorsFromImage:(UIImage * _Nonnull)image flags:(CCFlags)flags avoidColor:(UIColor * _Nonnull)avoidColor;
- (NSArray<UIColor *> * _Nullable)extractBrightColorsFromImage:(UIImage * _Nonnull)image avoidColor:(UIColor * _Nonnull)avoidColor count:(NSUInteger)count;
- (NSArray<UIColor *> * _Nullable)extractDarkColorsFromImage:(UIImage * _Nonnull)image avoidColor:(UIColor * _Nonnull)avoidColor count:(NSUInteger)count;
- (NSArray<UIColor *> * _Nullable)extractColorsFromImage:(UIImage * _Nonnull)image flags:(CCFlags)flags count:(NSUInteger)count;

@end