#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFRecordProperty : NSObject
@property (readonly, nonatomic) NSString *name;
@property (getter=isReadOnly, readonly, nonatomic) BOOL readOnly;
@property (getter=isNonAtomic, readonly, nonatomic) BOOL nonAtomic;
@property (getter=isDynamic,readonly, nonatomic) BOOL dynamic;
@property (readonly, nonatomic) NSString *getter;
@property (readonly, nonatomic) NSString *setter;
-(instancetype)initWithName:(NSString *)name property:(struct objc_property *)prop;
@end

NS_ASSUME_NONNULL_END
