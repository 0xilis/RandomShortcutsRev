#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFIcon : NSObject
-(instancetype)_init;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(id)aCoder;
-(BOOL)hasClearBackground;
+(BOOL)supportsSecureCoding;
@end

NS_ASSUME_NONNULL_END
