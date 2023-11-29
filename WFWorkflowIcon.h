#import <Foundation/Foundation.h>
#import "WFIcon.h"

NS_ASSUME_NONNULL_BEGIN

@class WFColor;

@interface WFWorkflowIcon : NSObject
-(instancetype)init;
-(instancetype)initWithPaletteColor:(NSUInteger)paletteColor glyphCharacter:(unsigned short)glyph customImageData:(NSData * _Nullable)data;
-(instancetype)initWithBackgroundColorValue:(NSInteger)bgColor glyphCharacter:(unsigned short)glyph customImageData:(NSData * _Nullable)data;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(WFColor *)backgroundColor;
@property (readonly, nonatomic) WFIcon *icon;
//@property (readonly, nonatomic) WFColor *backgroundColor;
@property (readonly, nonatomic) NSInteger backgroundColorValue;
@property (readonly, copy, nonatomic) NSData *customImageData;
@property (readonly, nonatomic) unsigned short glyphCharacter;
+(NSUInteger)randomBackgroundColor;
+(unsigned short)defaultGlyphCharacter;
+(BOOL)supportsSecureCoding;
@end

NS_ASSUME_NONNULL_END
