@implementation WFWorkflowController
-(void)runAction:(WFAction* )action withInput:(id)input completionHandler:(id)completion {
 dispatch_assert_queue([self executionQueue]);
 [action runWithInput:input userInterface:[self userInterface] runningDelegate:self variableSource:self workQueue:[self executionQueue] completionHandler:^{
  NSObject<OS_dispatch_queue> *executionQueue = [self executionQueue];
  dispatch_async(executionQueue, ^{
    completion(action, input, [self donateInteraction]);
  })
 }];
}
@end
