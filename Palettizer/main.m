// Copyright Harry Jordan, 2013			http://inquisitivesoftware.com/
// Open source under the MIT license	http://www.opensource.org/licenses/MIT

#import <AppKit/AppKit.h>
#import "RegexKitLite.h"
#import "XMLColorParser.h"

NSString * const PALETTIZER_HEX_REGEX = @"<string>(\\s)*(#[A-Za-z0-9]{6})";

NSURL *absoluteURLForPath(NSString *relativePath);
NSColor *colorWithHexColorString(NSString *hexString);



int main(int argc, const char * argv[])
{
	@autoreleasepool {
		NSArray *cliArguments = [[NSProcessInfo processInfo] arguments];
		NSURL *themeURL = nil;
		BOOL installColorPalette = FALSE;
		
		for(NSString *argument in cliArguments) {
			if([argument rangeOfString:@"-i" options:NSCaseInsensitiveSearch].location != NSNotFound
			   || [argument rangeOfString:@"--install" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				installColorPalette = TRUE;
			} else {
				themeURL = absoluteURLForPath(argument);
			}
		}
		
#ifdef DEBUG
		installColorPalette = TRUE;
		themeURL = absoluteURLForPath(@"~/Developer/Palettizer/Hues.tmTheme");
#endif
		
		if(!themeURL) {
			printf("Usage:\npalettizer [path to .tmTheme file]\n\t-i --install\tInstall the color palette in ~/Library/Colors\n\n");
			return 0;
		}
		
		NSString *paletteName = [[themeURL lastPathComponent] stringByDeletingPathExtension];
		XMLColorParser *parser = [[XMLColorParser alloc] initWithContentsOfURL:themeURL colorListName:paletteName];
		if(![parser parse]) {
			printf("Couldn't parse the .tmTheme file\n");
			return 1;
		}
		
		NSColorList *colorList = parser.colorList;
		NSInteger numberOfColors = [[colorList allKeys] count];
		
		if(numberOfColors == 0) {
			printf("Couldn't find any colors\n");
			return 1;
		} else {
			NSString *destinationPath = [@"~/Library/Colors" stringByExpandingTildeInPath];
			
			if(!installColorPalette) {
				destinationPath = [themeURL path];
				destinationPath = [[destinationPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"clr"];
			}
			
			if([colorList writeToFile:destinationPath]) {
				printf("Successfully created the new color palette with %ld colors to:\n %s\n", numberOfColors, [destinationPath UTF8String]);
			} else {
				printf("Failed to create color palette\n");
			}
		}
	}
	
    return 0;
}



NSURL *absoluteURLForPath(NSString *relativePath) {
	if(!relativePath || relativePath.length == 0)
		return nil;
	
	if(![relativePath isAbsolutePath]) {
		// If the path isn't absolute then append relativePath to the path of the current working directory
		relativePath = [NSString pathWithComponents:@[[[NSFileManager defaultManager] currentDirectoryPath], relativePath]];
	}
						
	relativePath = [[relativePath stringByExpandingTildeInPath] stringByStandardizingPath];
	return [NSURL fileURLWithPath:relativePath];
}