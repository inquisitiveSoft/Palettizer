// Copyright Harry Jordan, 2013			http://inquisitivesoftware.com/
// Open source under the MIT license	http://www.opensource.org/licenses/MIT

#import "XMLColorParser.h"
#import "RegexKitLite.h"


@interface XMLColorParser() {
	BOOL isParsingKey, isParsingValue, isParsingScope;
	NSInteger indexOfColor;
}

@property (readwrite) NSColorList *colorList;
@property (copy) NSString *key, *scope, *content;

@end



@implementation XMLColorParser


- (id)initWithContentsOfURL:(NSURL *)url colorListName:(NSString *)colorListName
{
	self = [super initWithContentsOfURL:url];
	
	if(self) {
		self.colorList = [[NSColorList alloc] initWithName:colorListName ? : @""];
		self.delegate = self;
		
		indexOfColor = 0;
	}
	
	return self;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	isParsingKey = FALSE;
	isParsingValue = FALSE;
	
	if([elementName isEqualToString:@"key"]) {
		isParsingKey = TRUE;
	} else if([elementName isEqualToString:@"string"]) {
		isParsingValue = TRUE;
	} else {
		self.key = nil;
	}
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(isParsingKey && [string isEqualToString:@"scope"]) {
		isParsingScope = TRUE;
	}
	
	self.content = string;
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSString *content = self.content;
	
	if(content.length) {
		if(isParsingScope) {
			self.scope = content;
		} else if(isParsingKey) {
			self.key = content;
		} else if(isParsingValue) {
			NSString *colorName = self.scope ? : self.key;
			[self addColorWithString:content forName:colorName];
		}
	}
	
	if(isParsingScope && ![elementName isEqualToString:@"key"]) {
		isParsingScope = FALSE;
	}
	
	self.content = nil;
	isParsingKey = FALSE;
	isParsingValue = FALSE;
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	printf("A parse error occured: %s\n", [parseError.localizedDescription UTF8String]);
}


- (BOOL)addColorWithString:(NSString *)colorString forName:(NSString *)key
{
	NSString *hexString = [colorString stringByMatching:@"^#[A-Za-z0-9]{6}"];
	
	if(hexString) {
		NSColor *color = [self colorWithHexString:hexString];
		
		if(color) {
			indexOfColor++;
			
			if([_colorList colorWithKey:key])
				key = nil;
			
			key = key ? : [NSString stringWithFormat:@"Color #%ld", indexOfColor];
			
				
			[_colorList setColor:color forKey:key];
		}
	}
	
	return hexString.length > 0;
}


- (NSColor *)colorWithHexString:(NSString *)hexString
{
	// From http://stackoverflow.com/a/8697241
	if(!hexString || hexString.length == 0) {
		return nil;
	}
	
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringWithRange:NSMakeRange(1, [hexString length] - 1)];
    }
    
	unsigned int colorCode = 0;
	
	if(hexString) {
		NSScanner *scanner = [NSScanner scannerWithString:hexString];
		(void)[scanner scanHexInt:&colorCode];
	}
    
	return [NSColor colorWithDeviceRed:((colorCode>>16) & 0xFF) / 255.0
								 green:((colorCode>>8) & 0xFF) / 255.0
								  blue:((colorCode) & 0xFF) / 255.0
								 alpha:1.0];
}


@end
