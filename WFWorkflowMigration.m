#import "WFWorkflowMigration.h"
@interface WFWorkflowMigration
-(void)enumerateActionsWithIdentifier:(id)actionId usingBlock:(void (^)(ObjectType obj, NSUInteger idx, BOOL *stop))block {
 NSArray* actions = [self actions];
 [actions enumerateObjectsUsingBlock:^{
  //noClueWhatThisIs is a var that idk where it first appears lol sorry, mayb its a NSMutableDictionary i thinjk but idk much about it
  NSString *otherActionId = noClueWhatThisIs[[self actionIdentifierKey]];
  if ([otherActionId isEqualToString:actionId]) {
    block(noClueWhatThisIs, noClueWhatThisIs[[self actionParametersKey]], stop);
  }
 }];
}
-(void)migrateWorkflow {
 [self finish];
}
-(void)migrateWorkflowIfNeeded:(id)placeholder completion:(id)completion {
 _workflow = placeholder;
  self.completionHandler = completion;
  [self migrateWorkflow];
}
-(void)finish {
 id *completionHandler = [self completionHandler];
 if (completionHandler) {
  completionHandler();
 }
}
+(id)migrationClassDependencies {
 return nil;
}
+(BOOL)workflowNeedsMigration:(id)placeholder fromClientVersion:(id)oldVersion {
 return nil;
}
@end
