
NSString * const originalKeys = @"originalKeys";
NSString * const newKey = @"newKey";


NSArray *SYMLMapBetweenColorKeys()
{
	return @[
		@{
			originalKeys	: @[@"background"],
			newKey			: @"backgroundColor"
		},
		@{
			originalKeys	: @[@"foreground"],
			newKey			: @"baseColor"
		},
		@{
			originalKeys	: @[@"lineHighlight", @"entity.other.inherited-class", @"entity.name.class"],
			newKey			: @"borderColor"
		},
		@{
			originalKeys	: @[@"storage.type", @"support.type", @"support.class", @"support.type.exception",],
			newKey			: @"selectedButtonColor"
		},
		@{
			originalKeys	: @[@"string", @"support.constant.color", @"meta.property-value.css", @"keyword.other.unit.css"],
			newKey			: @"titleColor"
		},
		@{
			originalKeys	: @[@"markup.heading", @"constant", @"constant.numeric"],
			newKey			: @"headingColor"
		},
		@{
			originalKeys	: @[@"entity", @"meta.array.php", @"storage.type.c", @"text.html.markdown meta.dummy.line-break", @"meta.group.braces.tex", @"support.type.exception.python"],
			newKey			: @"horizontalRuleColor"
		},
		@{
			originalKeys	: @[@"entity.other.attribute-name", @"storage.type.js", @"entity.name.tag.block.any.html"],
			newKey			: @"linkColor"
		},
		@{
			originalKeys	: @[@"storage", @"meta.tag", @"entity.name.function"],
			newKey			: @"emphasisColor"
		},
		@{
			originalKeys	: @[@"keyword", @"support.constant", @"meta.tag entity"],
			newKey			: @"strongColor"
		},
		@{
			originalKeys	: @[@"meta.verbatim", @"support", @"markup.raw.block.markdown", @"punctuation.definition.variable.perl", @"variable.other.readwrite.global.perl", @"variable.other.predefined.perl", @"keyword.operator.comparison.perl", @"markup.raw.inline.markdown", @"meta.function.js", @"constant.numeric.js"],
			newKey			: @"blockquoteColor"
		},
		@{
			originalKeys	: @[@"entity.name.tag", @"storage.modifier.c"],
			newKey			: @"listColor"
		},
		@{
			originalKeys	: @[@"comment", @"string.regexp"],
			newKey			: @"commentColor"
		},
		@{
			originalKeys	: @[@"selection", @"meta.class.ruby"],
			newKey			: @"selectionColor"
		},
		@{
			originalKeys	: @[@"caret"],
			newKey			: @"caretColor"
		},
		@{
			originalKeys	: @[@"caret"],
			newKey			: @"selectionHandleColor"
		},
		@{
			originalKeys	: @[@"constant.language", @"meta.other.inherited-class.php", @"constant.numeric.php"],
			newKey			: @"actionOverlayColor"
		},
		@{
			originalKeys	: @[@"markup.inserted", @"constant.language.ruby", @"text.html.ruby punctuation.definition.string.begin"],
			newKey			: @"insertionBackgroundColor"
		},
		@{
			originalKeys	: @[@"markup.deleted", @"storage.type.php"],
			newKey			: @"deletionBackgroundColor"
		}
	];
}