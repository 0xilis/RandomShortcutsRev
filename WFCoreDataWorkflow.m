#import "WFCoreDataWorkflow.h"

@implementation WFCoreDataWorkflow
+(NSDictionary *)recordPropertyMap {
    return @{
        @"icon" : @"workflowIcon",
        @"quarantine" : @"workflowQuarantine",
        @"deleted" : @"tombstoned",
        @"workflowSubtitle" : @"subtitle",
        @"actions" : @"deserializedActions",
        @"importQuestions" : @"deserializedImportQuestions",
        @"inputClasses" : @"deserializedInputClasses",
        @"noInputBehavior" : @"deserializedNoInputBehavior",
        @"outputClasses" : @"deserializedOutputClasses",
    };
}
@end
