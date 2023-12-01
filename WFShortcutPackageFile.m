#import <Foundation/Foundation.h>
#import <AppleArchive/AppleArchive.h>
#import <AppleArchive/AEADefs.h>
#import "WFShortcutPackageFile.h"

//some things might be slightly innaccurate, not good with rev

@implementation WFShortcutPackageFile
-(void)generateSignedShortcutFileRepresentationWithAccount:(id)arg0 error:(id)arg1 {
  //highly unfinished reving so this method is wildly missing a lot of actual, just wanted to check private key and stuff
  //the arg0 passed in is by [WFP2PSignedShortcutFileExporter exportWorkflowWithCompletion:] and it's value is [SFAppleIDClient myAccountWithError:notimportant]
  //SDAppleIDClient is from the Sharing.framework PrivateFramework
  id log = getWFSecurityLogObject();
  NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
  [daKey setObject:(__bridge id)kSecAttrKeyTypeECSECPrimeRandom forKey:(__bridge id)kSecAttrKeyType];
  [daKey setObject:0x6469b0 forKey:(__bridge id)kSecAttrKeySizeInBits];
  [daKey setObject:@NO forKey:(__bridge id)kSecAttrIsPermanent];
  SecKeyRef daKey = SecKeyCreateRandomKey(mutableDict, 0);
  [self generateSignedShortcutFileRepresentationWithPrivateKey:daKey signingContext:[WFShortcutSigningContext contextWithAppleIDAccount:arg0 signingKey:daKey] error:0];
}
-(void)generateSignedShortcutFileRepresentationWithPrivateKey:(id)arg0 signingContext:(id)arg1 error:(id)arg2 {
id auth = [arg1 generateAuthData]; //WFShortcutSigningContext
if (auth) {
 NSURL *tempURL = [self temporaryWorkingDirectoryURL];
 id directoryStructure = [self generateDirectoryStructureInDirectory:tempURL error:arg2];
 if (directoryStructure) {
  AEAContext context = AEAContextCreateWithProfile(0);
  if (context) {
   //block saved here
   if (AEAContextSetFieldUInt(context, AEA_CONTEXT_FIELD_COMPRESSION_ALGORITHM, 2049)) {
    //error
   } else {
    CFDataRef data = SecKeyCopyExternalRepresentation(arg0, 0);
    if (data) {
     if (AEAContextSetFieldBlob(context, AEA_CONTEXT_FIELD_SIGNING_PRIVATE_KEY, AEA_CONTEXT_FIELD_REPRESENTATION_X963, [data bytes], [data length])) {
      //error
     } else {
      AEAContextSetFieldBlob(context, AEA_CONTEXT_FIELD_AUTH_DATA, AEA_CONTEXT_FIELD_REPRESENTATION_RAW, [auth bytes], [auth length]);
      NSURL *daURL = [[[self temporaryWorkingDirectoryURL] URLByAppendingPathComponent:[self fileName]]fileSystemRepresentation]; //im amazing at var names
      AAByteStream byteStream = AAFileStreamOpenWithPath(daURL, O_CREAT | O_RDWR, 0420);
      AEAEncryptionOutputStreamOpen(byteStream, context, 0, 0);
      AAFieldKeySet fieldKeySet = AAFieldKeySetCreateWithString("TYP,PAT,LNK,DEV,DAT,MOD,FLG,MTM,BTM,CTM,HLC,CLC");
      if (fieldKeySet) {
       AAPathList pathList = AAPathListCreateWithDirectoryContents([directoryStructure fileSystemRepresentation], 0, 0, 0, 0, 0);
       if (pathList) {
        AAArchiveStream archiveStream = AAEncodeArchiveOutputStreamOpen(outputStream, 0, 0, 0, 0);
        if (archiveStream) {
         if (AAArchiveStreamWritePathList(archiveStream,pathList, fieldKeySet, [directoryStructure fileSystemRepresentation], 0, 0, 0, 0)) {
          //error
         } else {
          AAArchiveStreamClose(archiveStream);
          AAByteStreamClose(outputStream);
          AAByteStreamClose(byteStream);
          [WFFileRepresentation fileWithURL:daURL options:0x3 ofType:0x0 proposedFileName:[self sanitizedName]];
          [[self fileManager]removeItemAtURL:daURL error:0];
         }
        }
       }
      }
     }
    }
   }
  }
 }
}
}
-(NSURL *)generateDirectoryStructureInDirectory:(NSURL *)dir error:(NSError ** _Nullable)err {
    NSURL *returnURL;
    if ([self shortcutData]) {
        NSURL *url = [dir URLByAppendingPathComponent:[self directoryName]];
        returnURL = nil;
        BOOL didSucceed = [[self fileManager] createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:err];
        if (didSucceed) {
            NSURL *writeToURL = [url URLByAppendingPathComponent:@"Shortcut.wflow"];
            [[self shortcutData]writeToURL:writeToURL atomically:YES];
            returnURL = url;
        }
    } else {
        if (err) {
            *err = WFShortcutPackageFileFailedToSignShortcutFileError();
        }
        returnURL = nil;
    }
    return returnURL;
}
-(void)extractShortcutFileRepresentationWithSigningMethod:(id)arg0 error:(id)arg1 {
    [self extractShortcutFileRepresentationWithSigningMethod:arg0 iCloudIdentifier:0 error:arg1];
    return;
}
-(void)extractShortcutFileRepresentationWithError:(id)arg0 {
    [self extractShortcutFileRepresentationWithSigningMethod:0 error:arg0];
    return;
}
-(void)preformShortcutDataExtractionWithCompletion:(void(^)(id, int, NSString * _Nullable, NSError*))comp {
    if ([self signedShortcutData] || [self signedShortcutFileURL]) {
        AAByteStream byteStream;
        if ([self signedShortcutData]) {
            byteStream = AAMemoryInputStreamOpen([[self signedShortcutData]bytes], [[self signedShortcutData]length]);
        } else {
            byteStream = AAFileStreamOpenWithPath([[self signedShortcutFileURL]fileSystemRepresentation], 0, 420);
        }
        if (byteStream) {
            AEAContext context = AEAContextCreateWithEncryptedStream(byteStream);
            if (context) {
                size_t buf_size = 0;
                int errorCode = AEAContextGetFieldBlob(context, AEA_CONTEXT_FIELD_AUTH_DATA, 0, 0, 0, &buf_size);
                if (errorCode == 0) {
                    if (buf_size) {
                        void *buffer = malloc(buf_size);
                        if (AEAContextGetFieldBlob(context, AEA_CONTEXT_FIELD_AUTH_DATA, 0, buf_size, buffer, 0) == 0) {
                            NSData *authData = [NSData dataWithBytesNoCopy:buffer length:buf_size];
                            WFShortcutSigningContext *signingContext = [WFShortcutSigningContext contextWithAuthData:authData];
                            if (signingContext) {
                                [signingContext validateWithCompletion:^(BOOL success, int options, NSString * _Nullable icId, NSError *validationError) {
                                    if (success) {
                                        SecKeyRef publicKey = [signingContext copyPublicKey];
                                        if (publicKey) {
                                            NSData *externalRep = (__bridge NSData*)SecKeyCopyExternalRepresentation(publicKey, nil);
                                            if (AEAContextSetFieldBlob(context, AEA_CONTEXT_FIELD_SIGNING_PUBLIC_KEY, AEA_CONTEXT_FIELD_REPRESENTATION_X963, [externalRep bytes], [externalRep length]) == 0) {
                                                NSURL *daURL = [[self temporaryWorkingDirectoryURL]URLByAppendingPathComponent:[self directoryName]];
                                                if ([[self fileManager] fileExistsAtPath:[daURL path] isDirectory:nil]) {
                                                    [[self fileManager] createDirectoryAtURL:daURL withIntermediateDirectories:NO attributes:nil error:nil];
                                                }
                                                AAArchiveStream archiveStream = AAExtractArchiveOutputStreamOpen([daURL fileSystemRepresentation], nil, nil, 1, 0);
                                                if (archiveStream) {
                                                    AAByteStream decryptionInputStream = AEADecryptionInputStreamOpen(byteStream, context, 0, 0);
                                                    AAArchiveStream decodeStream = AADecodeArchiveInputStreamOpen(decryptionInputStream, nil, nil, 0, 0);
                                                    /* Extracting Signed Shortcut Data */
                                                    size_t archiveEntries = AAArchiveStreamProcess(decodeStream, archiveStream, nil, nil, 0, 0);
                                                    /* archiveEntries will return a negative error code if failure */
                                                    if ((archiveEntries >= 0) && AAArchiveStreamClose(archiveStream)) {
                                                        [daURL URLByAppendingPathComponent:@"Shortcut.wflow"];
                                                        WFFileRepresentation *fileRep = [WFFileRepresentation fileWithURL:daURL options:0x3 ofType:[WFFileType typeWithUTType:@"com.apple.shortcuts.workflow-file"] proposedFilename:[self fileName]];
                                                        if (fileRep) {
                                                            /* Signed Shortcut Data Extracted Successfully */
                                                            comp(fileRep, options, icId, nil);
                                                            AAArchiveStreamClose(decodeStream);
                                                            AAByteStreamClose(decryptionInputStream);
                                                        } else {
                                                            /* Could not find the main shortcut Shortcut.wflow file in the archive */
                                                            comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
                                                        }
                                                    } else {
                                                        comp(nil,0,nil,WFShortcutPackageFileFailedToExtractShortcutFileError());
                                                    }
                                                } else {
                                                    comp(nil,0,nil,WFShortcutPackageFileFailedToExtractShortcutFileError());
                                                }
                                            } else {
                                                /* error? */
                                            }
                                        } else {
                                            comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
                                        }
                                    } else {
                                        /* error? */
                                    }
                                }];
                            } else {
                                comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
                            }
                        } else {
                            free(buffer);
                            comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
                        }
                    } else {
                        comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
                    }
                } else {
                    comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
                }
            } else {
                comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
            }
        } else {
            /* Error */
            comp(nil,0,nil,WFShortcutPackageFileInvalidShortcutFileError());
        }
    } else {
        comp(nil,0,nil,[NSError errorWithDomain:NSCocoaErrorDomain code:0x4 userInfo:nil]);
    }
}
-(id)initWithShortcutData:(id)arg0 shortcutName:(id)arg1 {
 self = [super init];
 if (self) {
  self.shortcutData = arg0;
  self.shortcutName = arg1;
 }
 return self;
}
-(id)initWithSignedShortcutData:(id)arg0 shortcutName:(id)arg1 {
 self = [super init];
 if (self) {
  self.signedShortcutData = arg0;
  self.shortcutName = arg1;
 }
 return self;
}
-(id)initWithSignedShortcutFileURL:(id)arg0 {
 self = [super init];
 if (self) {
  self.signedShortcutFileURL = arg0;
  self.shortcutName = [[arg0 lastPathComponent]stringByDeletingPathExtension];
  [self commonInit];
 }
 return self;
}
-(void)commonInit
 self.temporaryWorkingDirectoryURL = [WFTemporaryFileManager createTemporaryDirectoryWithFilename:[[NSUUID UUID]UUIDString]];
 self.fileManager = [NSFileManager defaultManager];
 [[self fileManager] createDirectoryAtURL:[self temporaryWorkingDirectoryURL] withIntermediateDirectories:NO attributes:nil error:nil];
 self.executionQueue = dispatch_queue_create("com.apple.shortcuts.shorcut-package-file.execution-queue", NULL);
}
-(void)extractShortcutFileRepresentationWithCompletion:(id)arg0 {
 dispatch_async([self executionQueue], ^{
  return [self preformShortcutDataExtractionWithCompletion:arg0];
 });
}
-(id)extractShortcutFileRepresentationWithSigningMethod:(*NSInteger)arg0 iCloudIdentifier:(*id)arg1 error:(NSError**)arg2 {
    //WIP!!!!!
    dispatch_semaphore_create(0);
    [arg0 preformShortcutDataExtractionWithCompletion:^(WFFileRepresentation* a, NSString* b, NSError** c){
      self.fileManager._delegate = a;
      self.signedShortcutFileURL = b;
      dispatch_semaphore_signal();
    }];
    return;
}
@end
