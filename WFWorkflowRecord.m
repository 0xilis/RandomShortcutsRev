#import <Foundation/Foundation.h>
#import "WFWorkflowRecord.h"

@implementation WFWorkflowRecord
-(void)setActions:(NSArray*)arg0 {
 _actions = arg0;
 [self willChangeValueForKey:@"actionCount"];
 self->_actionCount = [arg0 count];
 [self didChangeValueForKey:@"actionCount"];
 [self markPropertyModifiedIfNecessary:@"actionCount"];
}
-(id)fileRepresentation {
 return [self writeToStorage:[[WFWorkflowFile alloc] initWithDictionary:[NSDictionary new] name:[self name] performMigration:NO] error:nil];
}
-(BOOL)saveChangesToStorage:(id)arg0 error:(NSError**)arg1 {
 if ([[self modifiedPropertiesSinceLastSave] count]) {
  [self setModificationDate:[NSDate date], arg1];
  [self setLastSavedOnDeviceName:[[WFDevice currentDevice]name], arg1];
 }
 return [super saveChangesToStorage:arg0 error:arg1];
}
-(BOOL)addWatchWorkflowTypeIfEligible {
 return [self addWatchWorkflowTypeIfEligibleWithIneligibleActionIdentifiers:[[WFActionRegistry sharedRegistry] identifiersOfActionsDisabledOnWatch]];
}
-(BOOL)addWatchWorkflowTypeIfEligibleWithIneligibleActionIdentifiers:(id)arg0 {
 if (![[self workflowTypes] containsObject:(WFWorkflowType *)WFWorkflowTypeWatch]) {
  if ([self isEligibleForWatchWithIneligibleActionIdentifiers:arg0]) {
   [self addWatchWorkflowType];
  } else {
   return 0;
  }
 }
 return 1;
}
-(void)addWatchWorkflowType {
 [self setWorkflowTypes:[[self workflowTypes] arrayByAddingObject:(WFWorkflowType *)WFWorkflowTypeWatch]];
 //log
}
+(id)workflowSubtitleForActionCount:(NSUInteger)arg0 savedSubtitle:(id)arg1 {
 if ((arg0 == 1) && arg1) {
  return arg1;
 } else {
  return [WFWorkflow localizedSubtitleWithActionCount:arg0];
 }
}
+(id)defaultPropertyValues {
 NSArray* supportedInputClassNames = [WFWorkflow supportedInputClassNames]array];
 id lastMigratedClientVersion = [[NSBundle bundleForClass:[WFWorkflowRecord class]] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
 return [NSDictionary dictionaryWithObjects:[[WFWorkflowIcon alloc]init],[NSDate date],[NSDate date],NSArray*,NSArray*,supportedInputClassNames,NSArray*,@NO,[NSArray new],NSConstantIntegerNumber,[NSArray new],@NO,[[WFDevice currentDevice]name],lastMigratedClientVersion,[NSSet new],[NSSet new],@YES forKeys:@"icon",@"creationDate",@"modificationDate",@"workflowTypes",@"quickActionSurfacesForSharing",@"inputClasses",@"outputClasses",@"hasShortcutInputVariables",@"actions",@"actionCount",@"importQuestions",@"deleted",@"lastSavedOnDeviceName",@"lastMigratedClientVersion",@"accessResourcePerWorkflowStates",@"smartPromptPerWorkflowStates",@"hasOutputFallback" count:17]
}
@end
