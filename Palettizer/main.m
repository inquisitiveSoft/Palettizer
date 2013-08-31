// Copyright Harry Jordan, 2013			http://inquisitivesoftware.com/
// Open source under the MIT license	http://www.opensource.org/licenses/MIT

#import <AppKit/AppKit.h>
#import "RegexKitLite.h"
#import "XMLColorParser.h"
#import "NSColor+Formating.h"
#import "SymlColorMap.h"


NSURL *absoluteURLForPath(NSString *relativePath);
void writeColorListToThemeFile(NSColorList *colorList, NSString *path, BOOL verbose);


int main(int argc, const char * argv[])
{
	@autoreleasepool {
		NSArray *cliArguments = [[NSProcessInfo processInfo] arguments];
		NSMutableArray *themeURLs = [[NSMutableArray alloc] init];
		BOOL installColorPalette = FALSE;
		BOOL createSymlTheme = FALSE;
		BOOL verbose = FALSE;
		
		for(NSString *argument in cliArguments) {
			if([argument rangeOfString:@"-i" options:NSCaseInsensitiveSearch].location != NSNotFound
			   || [argument rangeOfString:@"--install" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				installColorPalette = TRUE;
			} else if([argument rangeOfString:@"-v" options:NSCaseInsensitiveSearch].location != NSNotFound
			   || [argument rangeOfString:@"--verbose" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				verbose = TRUE;
			} else if([argument rangeOfString:@"-s" options:NSCaseInsensitiveSearch].location != NSNotFound
			   || [argument rangeOfString:@"--syml" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				if(installColorPalette) {
					installColorPalette = FALSE;
					printf("Can't install while using the -s argument\n");
				}
				
				createSymlTheme = TRUE;
			} else {
				NSURL *newURL = absoluteURLForPath(argument);
				
				if(newURL && [[newURL pathExtension] caseInsensitiveCompare:@"tmtheme"] == NSOrderedSame) {
					[themeURLs addObject:newURL];
				}
			}
		}
		
#ifdef TESTING
		installColorPalette = FALSE;
		createSymlTheme = TRUE;
		themeURLs = [@[absoluteURLForPath(@"~/Developer/Offshoots/Palettizer/Solarized (dark).tmTheme")] mutableCopy];
#endif
		
		if([themeURLs count] == 0) {
			printf("Usage: palettizer [options] <path to .tmTheme file>\n"
					"\t-i  --install		Install's the color palette in ~/Library/Colors\n"
					"\t-s  --syml		Generates a .syml-theme (json) file (overrides -i)\n"
					"\t-r --replace		Replaces any existing .clr or .json file\n"
					"\t-v  -verbose\n\n");
			
			return 0;
		}
		
		
		for(NSURL *themeURL in themeURLs) {
			if([[themeURL pathExtension] caseInsensitiveCompare:@"tmtheme"] != NSOrderedSame) {
				continue;
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
				
				if(installColorPalette) {
					destinationPath = [destinationPath stringByAppendingPathComponent:[themeURL lastPathComponent]];
				} else {
					destinationPath = [themeURL path];
				}
				
				destinationPath = [destinationPath stringByDeletingPathExtension];
				
				if(createSymlTheme) {
					destinationPath = [destinationPath stringByAppendingPathExtension:@"syml-theme"];
					writeColorListToThemeFile(colorList, destinationPath, verbose);
				} else {
					// Replace the .tmtheme with the .clr extension
					destinationPath = [destinationPath stringByAppendingPathExtension:@"clr"];
					
					if([colorList writeToFile:destinationPath]) {
						printf("Successfully created a color palette with %ld colors:\n %s\n", numberOfColors, [destinationPath UTF8String]);
					} else {
						printf("Failed to create color palette\n");
					}
				}
			}
		}
	}
	
    return 0;
}


void writeColorListToThemeFile(NSColorList *colorList, NSString *path, BOOL verbose)
{
	// MAnually construct the json because it wants to look good
	NSMutableString *jsonString = [[NSMutableString alloc] init];
	NSArray *mapBetweenColorKeys = SYMLMapBetweenColorKeys();
	NSString *fileName = [[path lastPathComponent] stringByDeletingPathExtension];
	
	// Add the theme name and placeholder attributes
	[jsonString appendFormat:@"{\n"
							"	\"identifier\"      : \"%@\",\n"
							"	\"name\"            : \"%@\",\n"
							"	\"attribution\"     : \"Anon\",\n"
							"	\"link\"            : \"http://example.com/\",\n\n",
									fileName, fileName];
	
	
	BOOL isFirstColor = TRUE;
	NSMutableArray *remainingSourceKeys = [[colorList allKeys] mutableCopy];
	NSMutableArray *remainingDestinationKeys = [[mapBetweenColorKeys valueForKeyPath:newKey] mutableCopy];
	
	for(NSDictionary *map in mapBetweenColorKeys) {
		NSArray *sourceKeys = map[originalKeys];
		NSString *destinationKey = map[newKey];
		
		NSColor *color = nil;
		NSString *matchedKey = nil;
		
		for(NSString *key in sourceKeys) {
			color = [colorList colorWithKey:key];
			
			if(color) {
				matchedKey = key;
				break;
			}
		}
		
		if(isFirstColor) {
			isFirstColor = FALSE;
		} else {
			[jsonString appendFormat:@",\n"];
		}
		
		if(color) {
			// asCommaSeperatedFloats always returns an alpha of 1.0
			// Is there a semi-sensible way to align tabs? That'd be nice.
			[jsonString appendFormat:@"	\"%@\"	: [%@]", destinationKey, [color asCommaSeperatedFloats]];
			[remainingSourceKeys removeObject:matchedKey];
			[remainingDestinationKeys removeObject:destinationKey];
		} else {
			// Insert a placeholder to maintain the order of keys
			[jsonString appendFormat:@"	\"%@\"	: [???]", destinationKey];
		}
    }
	
	
	// Use a set to unique each additional color
	NSMutableSet *additionalColors = [[NSMutableSet alloc] initWithCapacity:[remainingSourceKeys count]];
	
	if([remainingSourceKeys count]) {
		[jsonString appendString:@",\n	\"additionalColors\" : [\n"];
		isFirstColor = TRUE;
		
		for(NSString *key in remainingSourceKeys) {
			NSColor *color = [colorList colorWithKey:key];
			
			if(color) {
				[additionalColors addObject:color];
			}
		}
		
		for(NSColor *color in additionalColors) {
			if(isFirstColor) {
				isFirstColor = FALSE;
			} else {
				[jsonString appendFormat:@",\n"];
			}
			
			[jsonString appendFormat:@"		[%@]", [color asCommaSeperatedFloats]];
		}
		
		[jsonString appendString:@"\n	]"];
	}
	
	[jsonString appendFormat:@"\n}\n"];
	
	
	if(verbose)
		printf("\n%s\n\n", [jsonString UTF8String]);
	
	
	// Strip out color keys that were genterated by the parser
	for(NSString *key in [remainingSourceKeys copy]) {
		if([key isMatchedByRegex:@"Color #\\d+"]) {
			[remainingSourceKeys removeObject:key];
		}
	}
	
		
	NSError *error = nil;
	if(![jsonString writeToFile:path atomically:TRUE encoding:NSUTF8StringEncoding error:&error]) {
		printf("Couldn't write to file:'%s'\n	Error: %s\n\n", [path UTF8String], [[error localizedDescription] UTF8String]);
	} else {
		printf("Successfully created a theme file for Syml:\n %s\n\n", [path UTF8String]);
		
		if([remainingSourceKeys count]) {
			if(verbose) {
				printf("	Unmatched keys in the .tmtheme file: %s\n\n", [[remainingSourceKeys description] UTF8String]);
			} else {
				printf("	Found %ld unmatched keys in the .tmtheme file\n", [remainingSourceKeys count]);
			}
			
			printf("	Added %ld colors to the additionalColors array\n\n", [additionalColors count]);
		}
		
		if([remainingDestinationKeys count])
			printf("Colors which couldn't to be set: %s\n\n", [[remainingDestinationKeys description] UTF8String]);

	}
}



NSURL *absoluteURLForPath(NSString *relativePath) {
	if(!relativePath || relativePath.length == 0)
		return nil;
	
	if(![relativePath isAbsolutePath]) {
		// If the path isn't absolute then append relativePath to the path of the current working directory
		relativePath = [NSString pathWithComponents:@[[[NSFileManager defaultManager] currentDirectoryPath], relativePath]];
	}
						
	relativePath = [[relativePath stringByExpandingTildeInPath] stringByStandardizingPath];
	
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if([fileManager fileExistsAtPath:relativePath]) {
		return [NSURL fileURLWithPath:relativePath];
	}
	
	return nil;
}