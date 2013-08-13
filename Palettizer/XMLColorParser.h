// Copyright Harry Jordan, 2013			http://inquisitivesoftware.com/
// Open source under the MIT license	http://www.opensource.org/licenses/MIT

#import <AppKit/AppKit.h>

@interface XMLColorParser : NSXMLParser <NSXMLParserDelegate>

- (id)initWithContentsOfURL:(NSURL *)url colorListName:(NSString *)colorListName;

@property (readonly) NSColorList *colorList;

@end
