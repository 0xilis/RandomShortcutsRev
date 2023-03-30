#import "WFAction.h"

@implementation WFAction
//this is a method for checking if an action can do something ex if it accesses internet check if it has internet perm
//but this confuses the hell out of me so this is unfinished and wildly innacurate, DO NOT rely on this
//wip
-(void)performSmartPromptChecksWithUserInterface:(id)userInterface contentDestination:(id)descContent contentItemCache:(id)cacheItemContent isWebpageCoercion:(_Bool)webpageCoercion completionHandler:(CDUnknownBlockType)completion {
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
 id approvalResult = [databaseProxy approvalResultForContentAttributionSet:contentAttributes contentDestination:descContent actionUUID:actionUUID actionIdentifier:actionID actionIndex:indexOfAction reference:[[self workflow]reference] allowedOnceStates:set error:&err];
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
     [[WFSmartPromptConfiguration alloc] initWithSmartPromptStates:[approvalResult undefinedStates] attributionSet:[[self contentAttributionTracker]trackedAttributionSet] contentItemCache:cacheItemContent action:self contentDestination:descContent reference:[[self workflow]reference] source:@"Shortcut"];
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
//this method is called in WorkflowKit by -[WFFiniteRepeatAction runWithInput:userInterface:runningDelegate:variableSource:workQueue:completionHandler:], -[WFOutputAction runAsynchronouslyWithInput:], -[WFHandleDonatedIntentAction(WFLCompatibility) continueInAppWithCompletionHandler:] +[WFAction showImplicitChooseFromListWithInput:userInterface:workQueue:cancelHandler:selectionHandler:], -[WFWorkflowController runAction:withInput:completionHandler:], -[WFWorkflowController noInputBehavior:wantsToRunAction:completionHandler:]
-(void)runWithInput:(id)input userInterface:(id)useri runningDelegate:(id)delegate variableSource:(id)varSource workQueue:(id)queueWork completionHandler:(id)completion {
 if ([self isRunning]) {
  //the action is already running for some reason, error here with [NSError errorWithDomain:**_NSPOSIXErrorDomain code:0x25 userInfo:0x0]
 } else {
  //log
  [self setRunning:YES];
  [self setUserInterface:useri];
  [self setRunningDelegate:delegate];
  [self setVariableSource:varSource];
  [self setWorkQueue:queueWork];
  dispatch_async(dispatch_get_main_queue(), ^{
   NSArray *allObj = [[self eventObservers]allObjects];
   for (id obj in allObj) {
    if ([obj respondsToSelector:@selector(actionRunningStateDidChange:)]) {
     [obj actionRunningStateDidChange:[self inputContentClasses]]; //this seems weird that it would pass this in to this method so i think im wrong here and it's not [self inputContentClasses] but idk what else it could be
    }
   }
  });
  [self setCompletionHandler:^{
   [self setUserInterface:nil];
   [self setProcessedParameters:nil];
   [self setIgnoredParameterKeysForProcessing:nil];
   [self setRunningDelegate:nil];
   [self setVariableSource:nil];
   [self setContentAttributionTracker:nil];
   [self setWorkQueue:nil];
  }];
  id currentDevice = [WFDevice currentDevice];
  if ([self isDisabledWhenRunOnDevice:currentDevice]) {
   [self finishRunningWithError:[NSError wf_unsupportedActionErrorWithType:@"NotAvailableOnSpecifiedPlatform" platformIdiom:currentDevice]];
  } else {
   [self prepareToProcessWithCompletionHandler:^{
    if (queueWork) {
     [self finishRunningWithError:queueWork];
    } else {
     [[self resourceManager] makeAccessResourcesAvailableWithUserInterface:[self userInterface] completionHandler:^{
      //i got bored. not rev'ing this block for now, wip
     }];
    }
   }];
  }
 }
}
@end
