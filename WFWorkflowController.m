#import "WFWorkflowController.h"
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
-(void)run {
 dispatch_async([self executionQueue], ^{
  [self _run];
 });
}
-(void)stop {
 dispatch_async([self executionQueue], ^{
  [self queue_stopWithError:nil];
 });
}
-(void)stopWithError:(NSError **)err {
 dispatch_async([self executionQueue], ^{
  [self queue_stopWithError:err];
 });
}
-(void)queue_stopWithError:(NSError **)err {
 dispatch_assert_queue([self executionQueue]);
 [isRunning]
 [self setFinishedRunningWithSuccess:NO];
 //wip
}
@end
