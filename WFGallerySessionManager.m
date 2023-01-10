@implementation WFGallerySessionManager
/* @class WFGallerySessionManager */
-(void)uploadWorkflow:(id)workflowRecord withName:(id)shortcutName shortDescription:(id)shortDesc longDescription:(id)longDesc private:(id)isPrivate completionHandler:(id)completion {
 id genericVariable;
 if (isPrivate) {
  genericVariable = [[WFSharedShortcut alloc]init];
  [sharedShortcut setName:shortcutName];
  [sharedShortcut setIcon:[workflowRecord icon]];
 } else {
  genericVariable = [[WFMutableGalleryWorkflow alloc]init];
  [sharedShortcut setName:shortcutName];
  [sharedShortcut setIcon:[workflowRecord icon]];
  [sharedShortcut setShortDescription:shortDesc];
  [sharedShortcut setLongDescription:longDesc];
  
 }
 WFCloudKitItemRequest *cloudKitItemRequest = [genericVariable setWorkflowRecord:workflowRecord];
 [[WFCloudKitItemRequest alloc] initWithContainer:[self container] database:[self database]];
 //block invoked here
 [cloudKitItemRequest updateItems:[[NSArray arrayWithObjects:[self container] count:1] setNilValues:NO qualityOfService:25 timeoutIntervalForRequest:&/*dablock*/ completionHandler:/*dablock*/];

}
  
//below methods look uncomplete, but they're actually not.
-(void)deleteBanner:(id)banner completionHandler:(id)completion {
 return;
}
-(void)updateWorkflow:(id)workflowRecord withName:(id)shortcutName shortDescription:(id)shortDesc longDescription:(id)longDesc workflow:(id)daWorkflow completionHandler:(id)completion {
 return;
}
-(void)deleteCollection:(id)collection completionHandler:(id)completion {
 return;
}
-(void)createCollection:(id)collection small2xImage:(id)smallImage2x large2xImage:largeImage2x small3xImage:smallImage3x large3xImage:largeImage3x completionHandler:(id)completion {
 return;
}
-(void)createBannerWithName:(id)name detailPage:(id)page iphone2xImage:(id)iphone2x iphone3xImage:(id)iphone3x ipadImage:(id)ipad completionHandler:(id)completion {
 return;
}
@end
