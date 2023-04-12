#import "WFWorkflowMigration.h"
@interface WFOpenInActionAskWhenRunMigration : WFWorkflowMigration
+(BOOL)workflowNeedsMigration:(id)arg0 fromClientVersion:(NSString *)oldVersion;
-(void)migrateWorkflow;
@end
