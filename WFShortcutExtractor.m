#import <Foundation/Foundation.h>
#import "WFShortcutExtractor.h"

@implementation WFShortcutExtractor
-(void)extractShortcutFile:(WFFileRepresentation*)shortcutFile completion:(id)completion {
 //log
 if ([[shortcutFile mappedData] length] <= 0x3) {
  //error
 } else {
  if ([[NSString wf_stringWithData:[[shortcutFile mappedData] subdataWithRange:NSMakeRange(0, 4)]] isEqualToString:@"AEA1"]) { //check that first 4 bytes are AEA1, if so, extractSignedShortcutFile, if not, if valid shortcut file type, extractWorkflowFile 
   [self extractSignedShortcutFile:shortcutFile completion:completion];
  } else {
   if ([WFShortcutExtractor isShortcutFileType:[arg0 wfType]]) {
    //used for unsigned shortcut files
    [self extractWorkflowFile:shortcutFile completion:completion];
   } else {
    //error
   }
  }
 }
}
-(void)extractSignedShortcutFile:(WFFileRepresentation*)shortcutFile completion:(id)completion {
    [self extractSignedShortcutFile:shortcutFile allowsRetryIfExpired:YES completion:completion];
}
-(void)extractWorkflowFile:(WFFileRepresentation*)shortcutFile completion:(id)completion {
 //log
 if ((VCIsInternalBuild() && [WFSharingSettings shortcutFileSharingEnabled]) || [self allowsOldFormatFile]) {
  NSString *workflowName = [self suggestedName];
  if (!workflowName) {
    workflowName = [shortcutFile wfName];
  }
  [self extractWorkflowFile:shortcutFile shortcutName:workflowName shortcutFileContentType:0x0 iCloudIdentifier:nil completion:completion];
 } else {
  [WFSharingSettings shortcutFileSharingDisabledError];
 }
}
-(void)extractSignedShortcutFile:(WFFileRepresentation*)shortcutFile allowsRetryIfExpired:(BOOL)allowRetry completion:(id)completion {
 //log
 [[[WFShortcutPackageFile alloc]initWithSignedShortcutFileURL:[shortcutFile fileURL]]extractShortcutFileRepresentationWithCompletion://wip]; //completion block is not yet implemented here but basically it checks that shortcutFileContentType is 0x1/0x2/0x3, if not it makes it 0xffffffffffffffff, and calls extractWorkflowFile:shortcutName:shortcutFileContentType:iCloudIdentifier:completion: 
}
@end
