#import "WFIcon.h"

@implementation WFIcon
-(instancetype)_init {
    self = [super init];
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self _init];
}
-(void)encodeWithCoder:(id)aCoder {
    return;
}
-(BOOL)hasClearBackground {
    return NO;
}
+(BOOL)supportsSecureCoding {
    return YES;
}
@end
