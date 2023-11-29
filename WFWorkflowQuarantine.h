#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFWorkflowQuarantine : NSObject
@property (readonly, nonatomic) NSDate *importDate;
@property (readonly, copy, nonatomic) NSString *sourceAppIdentifier;
-(id)initWithSourceAppIdentifier:(NSString *)sourceAppID importDate:(NSDate *)importDate;
@end

NS_ASSUME_NONNULL_END
