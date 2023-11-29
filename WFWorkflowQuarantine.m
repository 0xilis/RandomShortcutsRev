#import "WFWorkflowQuarantine.h"

@implementation WFWorkflowQuarantine
-(id)initWithSourceAppIdentifier:(NSString *)sourceAppID importDate:(NSDate *)importDate {
    if (!sourceAppID) {
        /* error with Invalid parameter not satisfying: %@ */
        return nil;
    }
    if (!importDate) {
        /* error with Invalid parameter not satisfying: %@ */
        return nil;
    }
    self = [super init];
    if (self) {
        _sourceAppIdentifier = [sourceAppID copy];
        _importDate = importDate;
    }
    return self;
}
@end
