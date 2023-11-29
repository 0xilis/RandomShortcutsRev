#import "WFWorkflowIcon.h"
#define WFCOLOR_DEFINED 0

@implementation WFWorkflowIcon
-(instancetype)init {
    return [self initWithBackgroundColorValue:[WFWorkflowIcon randomBackgroundColor] glyphCharacter:(unsigned short)[WFWorkflowIcon defaultGlyphCharacter] customImageData:nil];
}
-(instancetype)initWithPaletteColor:(NSUInteger)paletteColor glyphCharacter:(unsigned short)glyph customImageData:(NSData * _Nullable)data {
#if WFCOLOR_DEFINED
    return [self initWithBackgroundColorValue:[[WFColor colorWithPaletteColor:paletteColor] RGBAValue] glyphCharacter:glyph customImageData:data];
#else
    /* placeholder - return nil since I don't have WFColor defined yet :P */
    return nil;
#endif
}
-(instancetype)initWithBackgroundColorValue:(NSInteger)bgColor glyphCharacter:(unsigned short)glyph customImageData:(NSData * _Nullable)data {
    self = [super init];
    if (self) {
        _backgroundColorValue = bgColor;
        _glyphCharacter = glyph;
        _customImageData = [data copy];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSNumber *backgroundColorValue = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"backgroundColorValue"];
        NSNumber *glyphCharacter = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"glyphCharacter"];
        NSData *customImageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:@"customImageData"];
        return [self initWithBackgroundColorValue:[backgroundColorValue integerValue] glyphCharacter:[glyphCharacter unsignedLongValue] customImageData:customImageData];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:[self backgroundColorValue]] forKey:@"backgroundColorValue"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedShort:(unsigned short)[self backgroundColorValue]] forKey:@"glyphCharacter"];
    [aCoder encodeObject:[self customImageData] forKey:@"customImageData"];
}
-(WFColor *)backgroundColor {
#if WFCOLOR_DEFINED
    return [WFColor colorWithRGBAValue:[self backgroundColorValue]];
#else
    /* placeholder - return nil since I don't have WFColor defined yet :P */
    return nil;
#endif
}
-(WFIcon *)icon {
#if 0
    WFIconGradientBackground *gradientBg = [[WFIconGradientBackground alloc]initWithGradient:[[self backgroundColor]paletteGradient]];
    NSString *glyphName = WFSystemImageNameForGlyphCharacter((unsigned short)[self glyphCharacter]);
    if (glyphName) {
        return [[WFSymbolIcon alloc]initWithSymbolName:glyphName background:gradientBg];
    }
    return [[WFWorkflowGlyphIcon alloc]initWithGlyph:(unsigned short)[self glyphCharacter] background:gradientBg];
#else
    /* placeholder */
    return nil;
#endif
}
+(NSUInteger)randomBackgroundColor {
    /* placeholder */
    return 0;
}
+(unsigned short)defaultGlyphCharacter {
    return 61440;
}
+(BOOL)supportsSecureCoding {
    return YES;
}
@end
