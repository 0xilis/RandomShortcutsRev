#import "WFRecordProperty.h"
#include <objc/runtime.h>

@implementation WFRecordProperty
-(instancetype)initWithName:(NSString *)name property:(struct objc_property *)prop {
    /* temp */
    self = [super init];
    if (!self) {
        return self;
    }
    _name = name;
    unsigned int outCount;
    objc_property_attribute_t *attributeList = property_copyAttributeList(prop, &outCount);
    if (attributeList) {
        for (unsigned int i = 0; i < outCount; i++) {
            switch (attributeList[i].name[0]) {
                case 'D':
                    _dynamic = YES;
                    break;
                case 'G':
                    _getter = [NSString stringWithUTF8String:attributeList[i].value];
                    break;
                case 'N':
                    _nonAtomic = YES;
                    break;
                case 'S':
                    _setter = [NSString stringWithUTF8String:attributeList[i].value];
                    break;
                case 'R':
                    _readOnly = YES;
                    break;
            }
        }
    }
    free(attributeList);
    if (!_getter) {
        _getter = _name;
    }
    if (!_setter && !_readOnly) {
        unichar idk = [_name characterAtIndex:0] - 'a';
        NSString *substring = [_name substringToIndex:1];
        if (idk <= 0x19) {
            substring = [substring uppercaseString];
        }
        _setter = [NSString stringWithFormat:@"set%@%@:", substring, [_name substringFromIndex:1]];
    }
    return self;
}
@end
