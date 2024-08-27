#import "../headers/Velvet2/ColorDetection.h"

@implementation CCLocalMaximum
@end

#define COLOR_CUBE_RESOLUTION 30
#define BRIGHT_COLOR_THRESHOLD 0.6
#define DARK_COLOR_THRESHOLD 0.4
#define DISTINCT_COLOR_THRESHOLD 0.2
#define CCAvoidSimilarColors (1 << 5) // Declare CCAvoidSimilarColors as a flag
#define CELL_INDEX(r,g,b) (r+g*COLOR_CUBE_RESOLUTION+b*COLOR_CUBE_RESOLUTION*COLOR_CUBE_RESOLUTION)
#define CELL_COUNT COLOR_CUBE_RESOLUTION*COLOR_CUBE_RESOLUTION*COLOR_CUBE_RESOLUTION

int neighbourIndices[27][3] = {
	{ 0, 0, 0}, { 0, 0, 1}, { 0, 0,-1},
	{ 0, 1, 0}, { 0, 1, 1}, { 0, 1,-1},
	{ 0,-1, 0}, { 0,-1, 1}, { 0,-1,-1},
	{ 1, 0, 0}, { 1, 0, 1}, { 1, 0,-1},
	{ 1, 1, 0}, { 1, 1, 1}, { 1, 1,-1},
	{ 1,-1, 0}, { 1,-1, 1}, { 1,-1,-1},
	{-1, 0, 0}, {-1, 0, 1}, {-1, 0,-1},
	{-1, 1, 0}, {-1, 1, 1}, {-1, 1,-1},
	{-1,-1, 0}, {-1,-1, 1}, {-1,-1,-1}
};

@interface CCColorCube () {
	CCCubeCell cells[COLOR_CUBE_RESOLUTION*COLOR_CUBE_RESOLUTION*COLOR_CUBE_RESOLUTION];
}

- (unsigned char *)rawPixelDataFromImage:(UIImage *)image pixelCount:(unsigned int*)pixelCount;
- (void)clearCells;
- (NSArray *)findLocalMaximaInImage:(UIImage *)image flags:(NSUInteger)flags;
- (NSArray *)findAndSortMaximaInImage:(UIImage *)image flags:(NSUInteger)flags;
- (NSArray *)extractAndFilterMaximaFromImage:(UIImage *)image flags:(NSUInteger)flags;
- (NSArray *)colorsFromMaxima:(NSArray *)maxima;
- (NSArray *)filterDistinctMaxima:(NSArray *)maxima threshold:(CGFloat)threshold;
- (NSArray *)filterMaxima:(NSArray *)maxima tooCloseToColor:(UIColor *)color;
- (NSArray *)performAdaptiveDistinctFilteringForMaxima:(NSArray *)maxima count:(NSUInteger)count;
- (NSArray *)orderByBrightness:(NSArray *)maxima;
- (NSArray *)orderByDarkness:(NSArray *)maxima;

@end

@implementation CCColorCube

- (id)init {
	self = [super init];
	if (self) {}
	return self;
}

- (void)dealloc {}

- (NSArray *)findLocalMaximaInImage:(UIImage *)image flags:(NSUInteger)flags {
	[self clearCells];
	unsigned int pixelCount;
	unsigned char *rawData = [self rawPixelDataFromImage:image pixelCount:&pixelCount];
	if (!rawData) return nil;
	double red, green, blue;
	int redIndex, greenIndex, blueIndex, cellIndex, localHitCount;
	BOOL isLocalMaximum;
	for (int k=0; k<pixelCount; k++) {
		red = (double)rawData[k*4+0]/255.0;
		green = (double)rawData[k*4+1]/255.0;
		blue  = (double)rawData[k*4+2]/255.0;
		if (flags & CCOnlyBrightColors) {
			if (red < BRIGHT_COLOR_THRESHOLD && green < BRIGHT_COLOR_THRESHOLD && blue < BRIGHT_COLOR_THRESHOLD) continue;
		}
		else if (flags & CCOnlyDarkColors) {
			if (red >= DARK_COLOR_THRESHOLD || green >= DARK_COLOR_THRESHOLD || blue >= DARK_COLOR_THRESHOLD) continue;
		}
		redIndex = (int)(red*(COLOR_CUBE_RESOLUTION-1.0));
		greenIndex = (int)(green*(COLOR_CUBE_RESOLUTION-1.0));
		blueIndex  = (int)(blue*(COLOR_CUBE_RESOLUTION-1.0));
		cellIndex = CELL_INDEX(redIndex, greenIndex, blueIndex);
		cells[cellIndex].hitCount++;
		cells[cellIndex].redAcc += red;
		cells[cellIndex].greenAcc += green;
		cells[cellIndex].blueAcc  += blue;
	}
	free(rawData);
	NSMutableArray *localMaxima = [NSMutableArray array];
	for (int r=0; r<COLOR_CUBE_RESOLUTION; r++) {
		for (int g=0; g<COLOR_CUBE_RESOLUTION; g++) {
			for (int b=0; b<COLOR_CUBE_RESOLUTION; b++) {
				localHitCount = cells[CELL_INDEX(r, g, b)].hitCount;
				if (localHitCount == 0) continue;
				isLocalMaximum = YES;
				for (int n=0; n<27; n++) {
					redIndex = r+neighbourIndices[n][0];
					greenIndex = g+neighbourIndices[n][1];
					blueIndex  = b+neighbourIndices[n][2];
					if (redIndex >= 0 && greenIndex >= 0 && blueIndex >= 0) {
						if (redIndex < COLOR_CUBE_RESOLUTION && greenIndex < COLOR_CUBE_RESOLUTION && blueIndex < COLOR_CUBE_RESOLUTION) {
							if (cells[CELL_INDEX(redIndex, greenIndex, blueIndex)].hitCount > localHitCount) {
								isLocalMaximum = NO;
								break;
							}
						}
					}
				}
				if (!isLocalMaximum) continue;
				CCLocalMaximum *maximum = [[CCLocalMaximum alloc] init];
				maximum.cellIndex = CELL_INDEX(r, g, b);
				maximum.hitCount = cells[maximum.cellIndex].hitCount;
				maximum.red = cells[maximum.cellIndex].redAcc / (double)cells[maximum.cellIndex].hitCount;
				maximum.green = cells[maximum.cellIndex].greenAcc / (double)cells[maximum.cellIndex].hitCount;
				maximum.blue  = cells[maximum.cellIndex].blueAcc / (double)cells[maximum.cellIndex].hitCount;
				maximum.brightness = fmax(fmax(maximum.red, maximum.green), maximum.blue);
				[localMaxima addObject:maximum];
			}
		}
	}
	NSArray *sortedMaxima = [localMaxima sortedArrayUsingComparator:^NSComparisonResult(CCLocalMaximum *m1, CCLocalMaximum *m2){
		if (m1.hitCount == m2.hitCount) return NSOrderedSame;
		return m1.hitCount > m2.hitCount ? NSOrderedAscending : NSOrderedDescending;
	}];
	return sortedMaxima;
}

- (NSArray *)findAndSortMaximaInImage:(UIImage *)image flags:(NSUInteger)flags {
	NSArray *sortedMaxima = [self findLocalMaximaInImage:image flags:flags];
	if (flags & CCOnlyDistinctColors) {
		sortedMaxima = [self filterDistinctMaxima:sortedMaxima threshold:DISTINCT_COLOR_THRESHOLD];
	}
	if (flags & CCOrderByBrightness) {
		sortedMaxima = [self orderByBrightness:sortedMaxima];
	}
	else if (flags & CCOrderByDarkness) {
		sortedMaxima = [self orderByDarkness:sortedMaxima];
	}
	return sortedMaxima;
}

- (NSArray *)filterDistinctMaxima:(NSArray *)maxima threshold:(CGFloat)threshold {
	NSMutableArray *filteredMaxima = [NSMutableArray array];
	for (int k=0; k<maxima.count; k++) {
		CCLocalMaximum *max1 = maxima[k];
		BOOL isDistinct = YES;
		for (int n=0; n<k; n++) {
			CCLocalMaximum *max2 = maxima[n];
			double redDelta = max1.red - max2.red;
			double greenDelta = max1.green - max2.green;
			double blueDelta  = max1.blue - max2.blue;
			double delta = sqrt(redDelta*redDelta + greenDelta*greenDelta + blueDelta*blueDelta);
			if (delta < threshold) {
				isDistinct = NO;
				break;
			}
		}
		if (isDistinct) {
			[filteredMaxima addObject:max1];
		}
	}
	return [NSArray arrayWithArray:filteredMaxima];
}

- (NSArray *)filterMaxima:(NSArray *)maxima tooCloseToColor:(UIColor*)color {
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	NSMutableArray *filteredMaxima = [NSMutableArray array];
	for (int k=0; k<maxima.count; k++) {
		CCLocalMaximum *max1 = maxima[k];
		double redDelta = max1.red - components[0];
		double greenDelta = max1.green - components[1];
		double blueDelta  = max1.blue - components[2];
		double delta = sqrt(redDelta*redDelta + greenDelta*greenDelta + blueDelta*blueDelta);
		if (delta >= DISTINCT_COLOR_THRESHOLD) {
			[filteredMaxima addObject:max1];
		}
	}
	return [NSArray arrayWithArray:filteredMaxima];
}

- (NSArray *)performAdaptiveDistinctFilteringForMaxima:(NSArray *)maxima count:(NSUInteger)count {
	NSArray *filteredMaxima = nil;
	CGFloat threshold = DISTINCT_COLOR_THRESHOLD;
	while (filteredMaxima.count < count) {
		filteredMaxima = [self filterDistinctMaxima:maxima threshold:threshold];
		threshold *= 0.75;
		if (threshold < 0.1) break;
	}
	if (filteredMaxima.count > count) {
		filteredMaxima = [filteredMaxima subarrayWithRange:NSMakeRange(0, count)];
	}
	return filteredMaxima;
}

- (NSArray *)orderByBrightness:(NSArray *)maxima {
	NSArray *sortedMaxima = [maxima sortedArrayUsingComparator:^NSComparisonResult(CCLocalMaximum *m1, CCLocalMaximum *m2){
		if (m1.brightness == m2.brightness) return NSOrderedSame;
		return m1.brightness > m2.brightness ? NSOrderedAscending : NSOrderedDescending;
	}];
	return sortedMaxima;
}

- (NSArray *)orderByDarkness:(NSArray *)maxima {
	NSArray *sortedMaxima = [maxima sortedArrayUsingComparator:^NSComparisonResult(CCLocalMaximum *m1, CCLocalMaximum *m2){
		if (m1.brightness == m2.brightness) return NSOrderedSame;
		return m1.brightness < m2.brightness ? NSOrderedAscending : NSOrderedDescending;
	}];
	return sortedMaxima;
}

- (NSArray *)extractAndFilterMaximaFromImage:(UIImage *)image flags:(NSUInteger)flags {
	NSArray *maxima = [self findAndSortMaximaInImage:image flags:flags];
	if ((flags & CCAvoidSimilarColors) && maxima.count > 0) {
		maxima = [self filterMaxima:maxima tooCloseToColor:[UIColor redColor]];
	}
	return maxima;
}

- (NSArray *)colorsFromMaxima:(NSArray *)maxima {
	NSMutableArray *colors = [NSMutableArray array];
	for (CCLocalMaximum *maximum in maxima) {
		UIColor *color = [UIColor colorWithRed:maximum.red green:maximum.green blue:maximum.blue alpha:1.0];
		[colors addObject:color];
	}
	return [NSArray arrayWithArray:colors];
}

- (void)clearCells {
	memset(cells, 0, sizeof(cells));
}

- (unsigned char *)rawPixelDataFromImage:(UIImage *)image pixelCount:(unsigned int*)pixelCount {
	CGImageRef imageRef = [image CGImage];
	NSUInteger width = CGImageGetWidth(imageRef);
	NSUInteger height = CGImageGetHeight(imageRef);
	*pixelCount = (unsigned int)(width * height);
	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = bytesPerPixel * width;
	NSUInteger bitsPerComponent = 8;
	unsigned char *rawData = (unsigned char *)malloc(height * width * bytesPerPixel);
	if (!rawData) return NULL;
	CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
	CGContextRelease(context);
	return rawData;
}

// Implement missing methods
- (NSArray<UIColor *> *)extractColorsFromImage:(UIImage *)image flags:(CCFlags)flags {
	NSArray *maxima = [self extractAndFilterMaximaFromImage:image flags:flags];
	return [self colorsFromMaxima:maxima];
}

- (NSArray<UIColor *> *)extractColorsFromImage:(UIImage *)image flags:(CCFlags)flags avoidColor:(UIColor *)avoidColor {
	NSArray *maxima = [self extractAndFilterMaximaFromImage:image flags:flags];
	maxima = [self filterMaxima:maxima tooCloseToColor:avoidColor];
	return [self colorsFromMaxima:maxima];
}

- (NSArray<UIColor *> *)extractBrightColorsFromImage:(UIImage *)image avoidColor:(UIColor *)avoidColor count:(NSUInteger)count {
	NSArray *maxima = [self findAndSortMaximaInImage:image flags:CCOnlyBrightColors];
	maxima = [self filterMaxima:maxima tooCloseToColor:avoidColor];
	maxima = [self performAdaptiveDistinctFilteringForMaxima:maxima count:count];
	return [self colorsFromMaxima:maxima];
}

- (NSArray<UIColor *> *)extractDarkColorsFromImage:(UIImage *)image avoidColor:(UIColor *)avoidColor count:(NSUInteger)count {
	NSArray *maxima = [self findAndSortMaximaInImage:image flags:CCOnlyDarkColors];
	maxima = [self filterMaxima:maxima tooCloseToColor:avoidColor];
	maxima = [self performAdaptiveDistinctFilteringForMaxima:maxima count:count];
	return [self colorsFromMaxima:maxima];
}

- (NSArray<UIColor *> *)extractColorsFromImage:(UIImage *)image flags:(CCFlags)flags count:(NSUInteger)count {
	NSArray *maxima = [self extractAndFilterMaximaFromImage:image flags:flags];
	maxima = [self performAdaptiveDistinctFilteringForMaxima:maxima count:count];
	return [self colorsFromMaxima:maxima];
}

@end
