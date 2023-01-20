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
 if (![[self workflowTypes] containsObject:WFWorkflowTypeWatch()]) {
  if ([self isEligibleForWatchWithIneligibleActionIdentifiers:arg0]) {
   [self addWatchWorkflowType];
  } else {
   return 0;
  }
 }
 return 1;
}
-(void)addWatchWorkflowType {
 [self setWorkflowTypes:[[self workflowTypes] arrayByAddingObject:WFWorkflowTypeWatch()]];
 //log
}

@end
