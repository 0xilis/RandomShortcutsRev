#import <AppleArchive/AppleArchive.h>
#import <AppleArchive/AEADefs.h>

//some things might be slightly innaccurate, not good with rev

@implementation WFShortcutPackageFile
-(void)generateSignedShortcutFileRepresentationWithAccount:(id)arg0 error:(id)arg1 {
  //highly unfinished reving so this method is wildly missing a lot of actual, just wanted to check private key and stuff
  //the arg0 passed in is by [WFP2PSignedShortcutFileExporter exportWorkflowWithCompletion:] and it's value is [SFAppleIDClient myAccountWithError:notimportant]
  //SDAppleIDClient is from the Sharing.framework PrivateFramework
  id log = getWFSecurityLogObject();
  NSMutableDictionary *daKey = [NSMutableDictionary dictionary];
  [daKey setObject:(__bridge id)kSecAttrKeyTypeECSECPrimeRandom forKey:(__bridge id)kSecAttrKeyType];
  [daKey setObject:0x6469b0 forKey:(__bridge id)kSecAttrKeySizeInBits];
  [daKey setObject:@NO forKey:(__bridge id)kSecAttrIsPermanent];
  [self generateSignedShortcutFileRepresentationWithPrivateKey:log signingContext:[WFShortcutSigningContext contextWithAppleIDAccount:arg0 signingKey:SecKeyCreateRandomKey(daKey, 0)] error:0];
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
      AEAContextSetFieldBlob(context, AEA_CONTEXT_FIELD_AUTH_DATA, 0, [data bytes], [data length]);
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
  if ([self fileManager]createDirectoryAtURL:daURL withIntermediateDirectories:0 attributes:0 error:arg1]) {
    [[self shortcutData] writeToURL:[daURL URLByAppendingPathComponent:@"Shortcut.wflow"] atomically:YES];
  }
 } else {
  //error
 }
}
@end
