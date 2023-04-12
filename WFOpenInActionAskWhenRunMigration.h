#import "WFWorkflowMigration.h"
@interface WFOpenInActionAskWhenRunMigration : WFWorkflowMigration
+(BOOL)workflowNeedsMigration:(id)idk fromClientVersion:(NSString *)oldVersion;
-(void)migrateWorkflow;
@end
