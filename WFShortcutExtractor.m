#import <Foundation/Foundation.h>
#import "WFShortcutExtractor.h"

@implementation WFShortcutExtractor
+(BOOL)isShortcutFileType:(WFFileType *)fileType {
 return [fileType conformsToUTTypes:[NSArray arrayWithObjects:@"com.apple.shortcut",@"com.apple.shortcuts.workflow-file",@"is.workflow.my.workflow",@"is.workflow.workflow"]];
}
-(void)extractShortcutWithCompletion:(id)comp {
    /* Start extracting a shortcut from file */
    if ([[self extractingURL]isFileURL] == NO) {
        /* Found a remote shortcut URL */
        [self extractRemoteShortcutFileAtURL:[self extractingURL] completion:comp];
    } else if ([self extractingFile]) {
        /* Found a shortcut file URL */
        [self extractShortcutFile:[self extractingFile] completion:comp];
    } else {
        _extractingFile = [WFFileRepresentation fileWithURL:[self extractingURL] options:[self fileAdoptionOptions]];
        if ([self extractingFile]) {
            [self extractShortcutFile:[self extractingFile] completion:comp];
        } else {
            /* error */
        }
    }
}
-(void)extractRemoteShortcutFileAtURL:(NSURL *)fileURL completion:(id)comp {
    /* Downloading a remote shortcut file */
    [[NSURLSession wf_sharedSession]downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (location) {
            WFFileRepresentation *fileRep = [WFFileRepresentation fileWithURL:location options:0x3 ofType:0x0 proposedFilename:[response suggestedFilename]];
            if (fileRep) {
                [self extractShortcutFile:fileRep completion:comp];
            } else {
                /* error */
            }
        } else {
            /* error */
        }
    }];
}
-(void)extractShortcutFile:(WFFileRepresentation *)fileRep completion:(id)comp {
    /* Extracting a shortcut from file */
    NSData *mappedData = [fileRep mappedData];
    if ([mappedData length] <= 3) {
        /* error */
    } else {
        NSString *fileSignature = [NSString wf_stringWithData:[mappedData subdataWithRange:NSMakeRange(0, 4)]];
        if ([fileSignature isEqualToString:@"AEA1"]) {
            [self extractSignedShortcutFile:fileRep completion:comp];
        } else {
            if ([WFShortcutExtractor isShortcutFileType:[fileRep wfType]]) {
                [self extractWorkflowFile:fileRep completion:comp];
            } else {
                /* error */
            }
        }
    }
}
-(void)extractSignedShortcutFile:(WFFileRepresentation *)fileRep completion:(id)comp {
    [self extractSignedShortcutFile:fileRep allowsRetryIfExpired:YES completion:comp];
}
-(void)extractSignedShortcutFile:(WFFileRepresentation *)fileRep allowsRetryIfExpired:(BOOL)retry completion:(id)comp {
    /* Extracting a signed shortcut format file */
    WFShortcutPackageFile *package = [[WFShortcutPackageFile alloc]initWithSignedShortcutFileURL:[fileRep fileURL]];
    [package extractShortcutFileRepresentationWithCompletion:^(WFFileRepresentation *outFileRep, long long scFileTypeArg, NSString * icloudId, NSError *err) {
        long long scFileType;
        if (scFileTypeArg == 1) {
            scFileType = 1;
            if (outFileRep) {
                NSString *suggestedName = [self suggestedName];
                if (!suggestedName) {
                    suggestedName = [fileRep wfName];
                }
                [self extractWorkflowFile:outFileRep shortcutName:suggestedName shortcutFileContentType:scFileType iCloudIdentifier:icloudId completion:comp];
            } else {
                /* Expired cert */
                if (icloudId) {
                    /* Found an iCloud Signed Shortcut File with expired certificate. Trying to download a new one from iCloud */
                }
            }
        } else {
            if (scFileTypeArg == 3) {
                scFileType = 3;
            } else if (scFileTypeArg == 2) {
                scFileType = 2;
            } else {
                scFileType = -1;
            }
            if (outFileRep) {
                NSString *suggestedName = [self suggestedName];
                if (!suggestedName) {
                    suggestedName = [fileRep wfName];
                }
                [self extractWorkflowFile:outFileRep shortcutName:suggestedName shortcutFileContentType:scFileType iCloudIdentifier:icloudId completion:comp];
            } else {
                /* call completion with err */
            }
        }
        
    }];
}
-(void)extractWorkflowFile:(WFFileRepresentation *)fileRep completion:(id)comp {
    /* Extracting an old shortcut format file */
    /* VCIsInternalBuild() is a function from VoiceShortcutsClient.framework */
    if ((VCIsInternalBuild() && [WFSharingSettings shortcutFileSharingEnabled]) || [self allowsOldFormatFile]) {
        NSString *suggestedName = [self suggestedName];
        if (suggestedName) {
            [self extractWorkflowFile:fileRep shortcutName:suggestedName shortcutFileContentType:0 iCloudIdentifier:nil completion:comp];
        } else {
            NSString *wfName = [fileRep wfName];
            [self extractWorkflowFile:fileRep shortcutName:wfName shortcutFileContentType:0 iCloudIdentifier:nil completion:comp];
        }
    } else {
        /* [WFSharingSettings shortcutFileSharingDisabledError]; */
    }
}
-(void)extractWorkflowFile:(WFFileRepresentation*)shortcutFile shortcutName:(NSString *)name shortcutFileContentType:(NSInteger)shortcutType iCloudIdentifier:(id)shortcutIdentifier completion:(id)completion {
 NSError* err = nil;
 WFWorkflowRecord* wfRecord = [[[WFWorkflowFile alloc]initWithDescriptor:[[WFWorkflowFileDescriptor alloc]initWithFile:shortcutFile name:name sourceAppIdentifier:[self sourceApplication]] error:&err]recordRepresentationWithError:&err];
 NSString *source;
 if (shortcutType == 0x1) {
  source = @"ShortcutSourceFilePublic";
 } else if (shortcutType == 0x2) {
  source = @"ShortcutSourceFileKnownContacts";
 } else if (shortcutType == 0x3) {
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
