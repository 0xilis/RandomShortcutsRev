@implementation WFBundledActionProvider
-(id)createActionWithIdentifier:(id)actionIdentifier definition:(id)def serializedParameters:(id)params fallbackToMissing:(BOOL)returnMissingActionIfNoClassFound isForLocalization:(BOOL)localization {
 Class actionClass = NSClassFromString([def objectForKey:@"ActionClass"]);
 if ([actionClass isSubclassOfClass:[WFHandleIntentAction class]]) {
  return [[actionClass alloc] initWithIdentifier:actionIdentifier definition:def serializedParameters:params stringLocalizer:[self stringLocalizer]];
 } else if ([actionClass isSubclassOfClass:[WFAction class]]) {
  return [[actionClass alloc] initWithIdentifier:actionIdentifier definition:def serializedParameters:params];
 } else {
  actionClass = nil;
 }
 if ((!actionClass) && returnMissingActionIfNoClassFound) {
  WFMissingAction* missingAction = [[WFMissingAction alloc] initWithIdentifier:actionIdentifier definition:def serializedParameters:params];
  [missingAction setIsForLocalization:localization];
  return missingAction;
 }
 return nil;
}
-(id)availableActionIdentifiers {
 return [[NSSet alloc] initWithArray:[[self actionDefinitionsWithIdentifiers:nil]allKeys]];
}
-(id)createAllAvailableActionsIncludingMissingActions:(BOOL)includeMissingActions {
 id actionIds = [self actionDefinitionsWithIdentifiers:nil];
 NSMutableSet* actions = [NSMutableSet new];
 for (id actionId actionIds) {
  id def = [actionIds objectForKey:actionId];
  id actionWithIdentifier = [self createActionWithIdentifier:actionId definition:def serializedParameters:nil fallbackToMissing:includeMissingActions isForLocalization:NO];
  if (actionWithIdentifier) {
   [actions addObject:actionWithIdentifier, def, nil];
  }
 }
 return actions;
}
//wrapper methods
-(id)createAllAvailableActions {
 return [self createAllAvailableActionsIncludingMissingActions:NO];
}
@end
