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
      AAByteStream byteStream = AAFileStreamOpenWithPath(daURL, 0x202, 0x1a4);
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
-(void)generateDirectoryStructureInDirectory:(id)arg0 error:(id)arg1 {
 NSData *shortcutData = [self shortcutData];
 if (shortcutData) {
  NSString *daURL = [arg0 URLByAppendingPathComponent:[self directoryName]];
  if ([[self fileManager]createDirectoryAtURL:daURL withIntermediateDirectories:0 attributes:0 error:arg1]) {
    [[self shortcutData] writeToURL:[daURL URLByAppendingPathComponent:@"Shortcut.wflow"] atomically:YES];
  }
 } else {
  //error
 }
}
-(void)extractShortcutFileRepresentationWithSigningMethod:(id)arg0 error:(id)arg1 {
    [self extractShortcutFileRepresentationWithSigningMethod:arg0 iCloudIdentifier:0 error:arg1];
    return;
}
-(void)extractShortcutFileRepresentationWithError:(id)arg0 {
    [self extractShortcutFileRepresentationWithSigningMethod:0 error:arg0];
    return;
}
-(void)preformShortcutDataExtractionWithCompletion:(id)arg0 {
 WFLogSubsystem *daLog = getWFSecurityLogObject();
 if (os_log_type_enabled(daLog, 0)) {
  //log
 }
 NSData *signedShortcutData = [self signedShortcutData];
 if (!signedShortcutData) {
  NSURL *daURL = [self signedShortcutFileURL];
  if (![self signedShortcutFileURL]) {
   //error
  }
 }
 AAByteStream byteStream;
 if (signedShortcutData) {
  byteStream = AAMemoryInputStreamOpen([signedShortcutData bytes], [signedShortcutData length]);
 } else {
  byteStream = AAFileStreamOpenWithPath([[self signedShortcutFileURL] fileSystemRepresentation], 0, 0x1a4);
 }
 if (!byteSteam) {
  //error
 }
 AEAContext context = AEAContextCreateWithEncryptedStream(byteStream);
 if (!context) {
  //error
 }
 size_t blobSize = 0;
 int fieldBlob = AEAContextGetFieldBlob(context, AEA_CONTEXT_FIELD_AUTH_DATA, AEA_CONTEXT_FIELD_REPRESENTATION_RAW, 0, 0, &blobSize);
 if (fieldBlob) {
  //error
 }
 if (blobSize == 0) {
  //error
 }
 uint8_t *tooLazyForGoodVariableNames = (uint8_t *)malloc(blobSize);
 if (!(AEAContextGetFieldBlob(context, AEA_CONTEXT_FIELD_AUTH_DATA, AEA_CONTEXT_FIELD_REPRESENTATION_RAW, blobSize, tooLazyForGoodVariableNames, 0))) {
  id context2 = [WFShortcutSigningContext contextWithAuthData:[NSData dataWithBytesNoCopy:tooLazyForGoodVariableNames length:blobSize]];
  if (context2) {
   [context2 validateWithCompletion:^{
     id publicKey = [context2 copyPublicKey];
     if (publicKey) {
       //finish latr
     } else {
      //error
     }
   }];
  } else {
   //error
  }
 } else {
  free(tooLazyForGoodVariableNames); //for some reason WorkflowKit only frees the uint8_t here, idk why
  //error
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
