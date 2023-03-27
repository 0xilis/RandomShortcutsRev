#import "WFAction.h"

@implementation WFAction
//wip
-(void)performSmartPromptChecksWithUserInterface:(id)arg1 contentDestination:(id)arg2 contentItemCache:(id)arg3 isWebpageCoercion:(_Bool)arg4 completionHandler:(CDUnknownBlockType)arg5 {
 if (![[self workflow]databaseProxy]) {
  //log %s Not performing smart prompt checks because database access is not available.
  //error
 }
 if ([self isRunningAsAutomation]) {
  //log %s Not performing smart prompt checks because we are running as an automation.
  //error
 }
 long indexOfAction = [[[self workflow] actions]indexOfObject:self];
 NSMutableArray* array = [NSMutableArray array];
 id trackedAttributionSet = [[self contentAttributionTracker] trackedAttributionSet];
 if (trackedAttributionSet) { //if trackedAttributionSet is not null, add
  [array addObject:trackedAttributionSet];
 }
 id attributionSetForCurrentScope = [[[self runningDelegate]flowTracker]attributionSetForCurrentScope];
 if (attributionSetForCurrentScope) { //if attributionSetForCurrentScope is not null, add
   [array addObject:attributionSetForCurrentScope];
 }
 WFContentAttributionSet* contentAttributes = [WFContentAttributionSet attributionSetByMergingAttributionSets:array];
 WFWorkflow* workflow = [self workflow];
 WFDatabaseProxy* databaseProxy = [workflow databaseProxy];
 NSString* actionUUID = [self UUID];
 NSString* actionID = [self identifier];
 NSSet* set = [self allowedOnceSmartPromptStates];
 if (!set) {
  set = [NSSet set];
 }
 NSErrror** err = nil;
 id approvalResult = [databaseProxy approvalResultForContentAttributionSet:contentAttributes contentDestination:arg2 actionUUID:actionUUID actionIdentifier:actionID actionIndex:indexOfAction reference:[[self workflow]reference] allowedOnceStates:set error:&err];
 [self setAllowedOnceSmartPromptStates:nil];
 [self setUUID:[approvalResult actionUUID]];
 if (!indexOfAction) {
  if ([[approvalResult restrictedStates]count] == 0) {
   if ([[approvalResult deniedStates]count] == 0) {
    if ([[approvalResult undefinedStates]count] == 0) {
     //error
    } else {
     if ([self isRunningInSiriUserInterface]) {
       //log
     }
     [[WFSmartPromptConfiguration alloc] initWithSmartPromptStates:[approvalResult undefinedStates] attributionSet:[[self contentAttributionTracker]trackedAttributionSet] contentItemCache:arg4 action:self contentDestination:var_88 reference:[[self workflow]reference] source:@"Shortcut"];
      //theres more after here but im done for now with this
    }
   } else {
     [[[approvalResult deniedStates]firstObject]localizedDeniedPermissionsError];
     //error
   }
  } else {
   [[[approvalResult restrictedStates]firstObject]localizedExfiltrationRestrictedError];
   //error
  }
 }
}
@end
