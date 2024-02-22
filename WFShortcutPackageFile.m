#import <Foundation/Foundation.h>
#import <AppleArchive/AppleArchive.h>
#import <AppleArchive/AEADefs.h>
#import "WFShortcutPackageFile.h"

//some things might be slightly innaccurate, not good with rev

@implementation WFShortcutPackageFile
-(NSString *)fileName {
    return [[self sanitizedName] stringByAppendingPathExtension:@"shortcut"];
}
-(NSString *)directoryName {
    return [[self sanitizedName] stringByAppendingPathExtension:@"shortcuts"];
}
@synthesize sanitizedName = _sanitizedName;
-(NSString *)sanitizedName {
    NSString *sanitizedName = _sanitizedName;
    if (!sanitizedName) {
        NSString *shortcutName = [self shortcutName];
        NSRange range = [shortcutName rangeOfString:@"^[\\.](?=.*)" options:NSRegularExpressionSearch];
        if ((range.location == 0) && (range.length != 0)) {
            /* if . is first character replace it with _ */
            shortcutName = [shortcutName stringByReplacingOccurrencesOfString:@"." withString:@"_" options:0 range:range];
        }
        shortcutName = [shortcutName stringByReplacingOccurrencesOfString:@":" withString:@""];
        shortcutName = [shortcutName stringByReplacingOccurrencesOfString:@"/" withString:@":"];
        _sanitizedName = shortcutName;
    }
    return sanitizedName;
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
-(WFFileRepresentation *)generateSignedShortcutFileRepresentationWithAccount:(id)account error:(NSError**)err {
    /* TODO: Implement logs + errors, for now this decomp doesn't handle errors/logs at all */
    //highly unfinished reving so this method is wildly missing a lot of actual, just wanted to check private key and stuff
    //the arg0 passed in is by [WFP2PSignedShortcutFileExporter exportWorkflowWithCompletion:] and it's value is [SFAppleIDClient myAccountWithError:notimportant]
    //SDAppleIDClient is from the Sharing.framework PrivateFramework
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    mutableDict[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeECSECPrimeRandom;
#if 0
    mutableDict[(__bridge id)kSecAttrKeySizeInBits] = (__bridge id)0x6469b0;
#else
    mutableDict[(__bridge id)kSecAttrKeySizeInBits] = @6580656;
#endif
    mutableDict[(__bridge id)kSecAttrIsPermanent] = @NO;
    SecKeyRef daKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)mutableDict, 0);
    WFShortcutSigningContext *signingContext = [WFShortcutSigningContext contextWithAppleIDAccount:account signingKey:daKey];
    return [self generateSignedShortcutFileRepresentationWithPrivateKey:daKey signingContext:signingContext error:0];
}

#ifndef COMPRESSION_LZFSE
#define COMPRESSION_LZFSE 0x801
#endif

-(WFFileRepresentation *)generateSignedShortcutFileRepresentationWithPrivateKey:(SecKeyRef)daKey signingContext:(WFShortcutSigningContext *)signingContext error:(NSError**)err {
    /* TODO: Implement logs + errors, for now this decomp doesn't handle errors/logs at all */
    NSData *authData = [signingContext generateAuthData];
    if (authData) {
        NSURL *url = [self generateDirectoryStructureInDirectory:[self temporaryWorkingDirectoryURL] error:err];
        if (url) {
            AEAContext context = AEAContextCreateWithProfile(0);
            if (context) {
                if (AEAContextSetFieldUInt(context, AEA_CONTEXT_FIELD_COMPRESSION_ALGORITHM, COMPRESSION_LZFSE) == 0) {
                    CFErrorRef cferr = 0;
                    NSData *key = (__bridge NSData *)SecKeyCopyExternalRepresentation(daKey, &cferr);
                    if (key) {
                        if (AEAContextSetFieldBlob(context, AEA_CONTEXT_FIELD_SIGNING_PRIVATE_KEY, AEA_CONTEXT_FIELD_REPRESENTATION_X963, [key bytes], [key length]) == 0) {
                            AEAContextSetFieldBlob(context, AEA_CONTEXT_FIELD_AUTH_DATA, AEA_CONTEXT_FIELD_REPRESENTATION_RAW, [authData bytes], [authData length]);
                            NSURL *fileURL = [[self temporaryWorkingDirectoryURL]URLByAppendingPathComponent:[self fileName]];
                            const char *path = [fileURL fileSystemRepresentation];
                            AAByteStream byteStream = AAFileStreamOpenWithPath(path,O_CREAT | O_RDWR, 0420);
                            AAByteStream encryptedStream = AEAEncryptionOutputStreamOpen(byteStream, context, 0, 0);
                            AAFieldKeySet fields = AAFieldKeySetCreateWithString("TYP,PAT,LNK,DEV,DAT,MOD,FLG,MTM,BTM,CTM,HLC,CLC");
                            if (fields) {
                                const char *dir = [url fileSystemRepresentation];
                                AAPathList pathList = AAPathListCreateWithDirectoryContents(dir, 0, 0, 0, 0, 0);
                                if (pathList) {
                                    AAArchiveStream archiveStream = AAEncodeArchiveOutputStreamOpen(encryptedStream, 0, 0, 0, 0);
                                    if (archiveStream) {
                                        if (AAArchiveStreamWritePathList(archiveStream, pathList, fields, [url fileSystemRepresentation], 0, 0, 0, 0) == 0) {
                                            AAArchiveStreamClose(archiveStream);
                                            AAByteStreamClose(encryptedStream);
                                            AAByteStreamClose(byteStream);
                                            WFFileRepresentation *fileRep = [WFFileRepresentation fileWithURL:fileURL options:0x3 ofType:0x0 proposedFilename:[self sanitizedName]];
                                            [[self fileManager]removeItemAtURL:fileURL error:nil];
                                            /* The original implementation has these in blocks but eh */
                                            AAPathListDestroy(pathList);
                                            AAFieldKeySetDestroy(fields);
                                            AEAContextDestroy(context);
                                            return fileRep;
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
    return nil;
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
                        uint8_t *buffer = (uint8_t *)malloc(buf_size);
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
                                                if (![[self fileManager] fileExistsAtPath:[daURL path] isDirectory:nil]) {
                                                    [[self fileManager] createDirectoryAtURL:daURL withIntermediateDirectories:NO attributes:nil error:nil];
                                                }
                                                AAArchiveStream archiveStream = AAExtractArchiveOutputStreamOpen([daURL fileSystemRepresentation], nil, nil, 1, 0);
                                                if (archiveStream) {
                                                    AAByteStream decryptionInputStream = AEADecryptionInputStreamOpen(byteStream, context, 0, 0);
                                                    AAArchiveStream decodeStream = AADecodeArchiveInputStreamOpen(decryptionInputStream, nil, nil, 0, 0);
                                                    /* Extracting Signed Shortcut Data */
                                                    ssize_t archiveEntries = AAArchiveStreamProcess(decodeStream, archiveStream, nil, nil, 0, 0);
                                                    /* archiveEntries will return a negative error code if failure */
                                                    if ((archiveEntries >= 0) && (AAArchiveStreamClose(archiveStream) >= 0)) {
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
-(instancetype)initWithShortcutData:(NSData *)shortcutData shortcutName:(NSString *)name {
    self = [super init];
    if (self) {
        _shortcutData = shortcutData;
        _shortcutName = name;
        [self commonInit];
    }
    return self;
}
-(instancetype)initWithSignedShortcutData:(NSData *)shortcutData shortcutName:(NSString *)name {
    self = [super init];
    if (self) {
        _signedShortcutData = shortcutData;
        _shortcutName = name;
        [self commonInit];
    }
    return self;
}
-(instancetype)initWithSignedShortcutFileURL:(NSURL *)signedShortcutFileURL {
    self = [super init];
    if (self) {
        _signedShortcutFileURL = signedShortcutFileURL;
        _shortcutName = [[signedShortcutFileURL lastPathComponent]stringByDeletingPathExtension];
        [self commonInit];
    }
    return self;
}
-(void)commonInit {
    NSURL *tempWorkingDir = [WFTemporaryFileManager createTemporaryDirectoryWithFilename:[[NSUUID UUID]UUIDString]];
    _temporaryWorkingDirectoryURL = tempWorkingDir;
    _fileManager = [NSFileManager defaultManager];
    NSError* thisIsUnusedIThinkLol = nil;
    [[self fileManager] createDirectoryAtURL:tempWorkingDir withIntermediateDirectories:NO attributes:nil error:&thisIsUnusedIThinkLol];
    _executionQueue = dispatch_queue_create("com.apple.shortcuts.shorcut-package-file.execution-queue", 0);
}
-(void)extractShortcutFileRepresentationWithCompletion:(void(^)(id, long long, NSString * _Nullable, NSError*))comp {
    dispatch_async([self executionQueue], ^{
        [self preformShortcutDataExtractionWithCompletion:comp];
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
