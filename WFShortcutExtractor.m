#import <Foundation/Foundation.h>
#import "WFShortcutExtractor.h"

@implementation WFShortcutExtractor
+(BOOL)isShortcutFileType:(WFFileType *)fileType {
 return [fileType conformsToUTTypes:[NSArray arrayWithObjects:@"com.apple.shortcut",@"com.apple.shortcuts.workflow-file",@"is.workflow.my.workflow",@"is.workflow.workflow"]];
}
-(void)extractShortcutFile:(WFFileRepresentation*)shortcutFile completion:(id)completion {
 //log
 if ([[shortcutFile mappedData] length] <= 0x3) {
  //error
 } else {
  if ([[NSString wf_stringWithData:[[shortcutFile mappedData] subdataWithRange:NSMakeRange(0, 4)]] isEqualToString:@"AEA1"]) { //check that first 4 bytes are AEA1, if so, extractSignedShortcutFile, if not, if valid shortcut file type, extractWorkflowFile 
   [self extractSignedShortcutFile:shortcutFile completion:completion];
  } else {
   if ([WFShortcutExtractor isShortcutFileType:[shortcutFile wfType]]) {
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
-(void)extractWorkflowFile:(WFFileRepresentation*)shortcutFile shortcutName:(NSString *)name shortcutFileContentType:(NSInteger)shortcutType iCloudIdentifier:(id)shortcutIdentifier completion:(id)completion {
 NSError* err = nil;
 WFWorkflowRecord* wfRecord = [[[WFWorkflowFile alloc]initWithDescriptor:[[WFWorkflowFileDescriptor alloc]initWithFile:shortcutFile name:name sourceAppIdentifier:[self sourceApplication]] error:&err]recordRepresentationWithError:&err];
 NSString *source;
 if (shortcutType == 0x1) {
  source = @"ShortcutSourceFilePublic";
 } else if (shortcutType == 0x2) {
  source = @"ShortcutSourceFileKnownContacts";
 } else if (rax == 0x3) {
  source = @"ShortcutSourceFilePersonal";
 } else {
  source = @"ShortcutSourceUnknown";
 }
 [wfRecord setSource:source];
 if (wfRecord) {
  WFExtractShortcutResult* extractShortcutResult = [[WFExtractShortcutResult alloc] initWithRecord:wfRecord fileContentType:shortcutType iCloudIdentifier:shortcutIdentifier sourceApplicationIdentifier:[self sourceApplication] sharedDate:[shortcutFile creationDate]];
  if ([self skipsMaliciousScanning]) {
   completion(extractShortcutResult, nil);
  } else {
   //WFWorkflowRemoteQuarantineRequest / WFRemoteQuarantinePolicyEvaluator stuff
  }
 } else {
  completion(nil, err);
 }
}
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)skipScanning fileAdoptionOptions:(NSInteger)options suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 if (!url) {
  //error
 }
 self = [super init];
 if (self) {
  _extractingURL = url;
  _allowsOldFormatFile = allowOldFileFormat;
  _skipsMaliciousScanning = skipScanning;
  _fileAdoptionOptions = options;
  _suggestedName = suggestName;
  _sourceApplication = app;
 }
}
-(id)initWithFile:(WFFileRepresentation *)file allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)skipScanning suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 if (!file) {
  //error
 }
 self = [super init];
 if (self) {
  _extractingURL = [file fileURL];
  _extractingFile = file;
  _allowsOldFormatFile = allowOldFileFormat;
  _skipsMaliciousScanning = skipScanning;
  _suggestedName = suggestName;
  _sourceApplication = app;
 }
}
//wrapper methods
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 return [self initWithURL:url allowsOldFormatFile:allowOldFileFormat skipsMaliciousScanning:NO fileAdoptionOptions:nil suggestedName:suggestName sourceApplication:app];
}
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)skipScanning suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 return [self initWithURL:url allowsOldFormatFile:allowOldFileFormat skipsMaliciousScanning:skipScanning fileAdoptionOptions:nil suggestedName:suggestName sourceApplication:app];
}
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat fileAdoptionOptions:(NSInteger)options suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 return [self initWithURL:url allowsOldFormatFile:allowOldFileFormat skipsMaliciousScanning:NO fileAdoptionOptions:options suggestedName:suggestName sourceApplication:app];
}
-(id)initWithURL:(NSURL *)url fileAdoptionOptions:(NSInteger)options suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 return [self initWithURL:url allowsOldFormatFile:NO fileAdoptionOptions:options suggestedName:suggestName sourceApplication:app];
}
-(id)initWithURL:(NSURL *)url suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 return [self initWithURL:url allowsOldFormatFile:NO fileAdoptionOptions:nil suggestedName:suggestName sourceApplication:app];
}
-(id)initWithFile:(WFFileRepresentation *)file suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 return [self initWithFile:file allowsOldFormatFile:NO suggestedName:suggestName sourceApplication:app];
}
-(id)initWithFile:(WFFileRepresentation *)file allowsOldFormatFile:(BOOL)allowOldFileFormat suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app {
 return [self initWithFile:file allowsOldFormatFile:allowOldFileFormat skipsMaliciousScanning:NO suggestedName:suggestName sourceApplication:app];
}
@end
