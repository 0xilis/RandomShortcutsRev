#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFWorkflowIcon : NSObject
//@property (readonly, nonatomic) WFColor *backgroundColor;
@property (readonly, nonatomic) NSInteger backgroundColorValue; // ivar: _backgroundColorValue
@property (readonly, copy, nonatomic) NSData *customImageData; // ivar: _customImageData
@property (readonly, nonatomic) unsigned short glyphCharacter; // ivar: _glyphCharacter
//@property (readonly, nonatomic) WFIcon *icon;
-(instancetype)initWithBackgroundColorValue:(NSInteger)bgColor glyphCharacter:(unsigned short)glyph customImageData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
