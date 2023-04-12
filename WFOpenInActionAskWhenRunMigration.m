#import "WFOpenInActionAskWhenRunMigration.h"

@interface WFOpenInActionAskWhenRunMigration
+(BOOL)workflowNeedsMigration:(id)idk fromClientVersion:(NSString *)oldVersion {
 //after much trial and error / bruteforcing
 //(i suck at bitwise operations)
 //found out that this method calls WFCompareBundleVersions function with oldVersion as arg0 and @"0" NSString as arg1 and makes sure result is 0x2
 //but it also calls WFCompareBundleVersions function with oldVersion as arg0 again and @"1122" NSString as arg1 and 0s out the 2nd most bit
 //and makes sure that its 0x1
 //this confuses the heck out of me i suck at re
 if ((WFCompareBundleVersions(oldVersion, @"0") == 0x2) && ((WFCompareBundleVersions(oldVersion, @"1122") & 0xfffffffffffffffd) == 0x1)) {
  return WFWorkflowHasActionsWithIdentifier(@"is.workflow.actions.openin", idk);
 }
 return NO;
}
-(void)migrateWorkflow {
 [self enumerateActionsWithIdentifier:@"is.workflow.actions.openin" usingBlock:^(NSMutableDictionary *dict, NSUInteger index, BOOL *stop){
  if (!dict[@"WFOpenInAskWhenRun"]) {
    dict[@"WFOpenInAskWhenRun"] = YES;
  }
 }];
 [self finish];
}
@end
