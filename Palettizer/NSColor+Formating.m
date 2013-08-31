// Copyright Harry Jordan, 2013			http://inquisitivesoftware.com/
// Open source under the MIT license	http://www.opensource.org/licenses/MIT


#import "NSColor+Formating.h"

@implementation NSColor (Formating)

- (NSString *)asCommaSeperatedFloats
{
	NSColor *rgbColor = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	
	CGFloat red, green, blue, alpha;
	[rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
	
	return [NSString stringWithFormat:@"%.3f, %.3f, %.3f, 1.0", red, green, blue];
}


@end
