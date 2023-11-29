#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFIconBackground : NSObject <NSSecureCoding>
-(instancetype)_init;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(id)aCoder;
+(BOOL)supportsSecureCoding;
@end

NS_ASSUME_NONNULL_END
