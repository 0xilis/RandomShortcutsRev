#import <Foundation/Foundation.h>
#import "WFShortcutSigningContext.h"

/*
 * This file in particular is VERY WIP.
 * Decomp of WFShortcutSigningContext sucks here.
 */

@implementation WFShortcutSigningContext
-(NSData *)generateAuthData {
    if ([self signingCertificateChain]) {
        NSArray *authDataMap = [[self signingCertificateChain]if_compactMap:^(WFShortcutSigningCertificate *cert){
            return [cert generateAuthData];
        }];
        if ([authDataMap count] != [[self signingCertificateChain]count]) {
            return nil;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"SigningCertificateChain" : authDataMap,
        }];
        return [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    } else {
        NSMutableDictionary *dict;
        if ([self appleIDValidationRecord]) {
            NSArray *authDataMap = [[self appleIDCertificateChain]if_compactMap:^(WFShortcutSigningCertificate *cert){
                return [cert generateAuthData];
            }];
            if ([authDataMap count] != [[self appleIDCertificateChain]count]) {
                return nil;
            }
            NSData *signingPublicKey = (__bridge NSData *)SecKeyCopyExternalRepresentation([self signingPublicKey], 0);
            dict = [NSMutableDictionary dictionaryWithDictionary:@{
                @"AppleIDCertificateChain" : authDataMap,
                @"SigningPublicKey" : signingPublicKey,
                @"SigningPublicKeySignature" : [self signingPublicKeySignature],
                @"AppleIDValidationRecord" : [self appleIDValidationRecord],
            }];
        } else {
            dict = nil;
        }
        return [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    }
}
-(BOOL)validateWithSigningMethod:(*NSInteger)arg0 error:(NSError**)err {
    return [self validateWithSigningMethod:arg0 iCloudIdentifier:nil error:err];
}
-(SecKeyRef)copyPublicKey {
 if ([[self signingCertificateChain]count]) {
  return [[[self signingCertificateChain]firstObject]copyPublicKey];
 } else {
  return [self signingPublicKey];
 }
}
-(instancetype)initWithSigningCertificateChain:(NSArray *)signingChain {
    self = [super init];
    if (self) {
        self->_signingCertificateChain = [signingChain copy];
    }
    return self;
}
-(void)validateAppleIDValidationRecordWithCompletion:(void(^)(BOOL success, int options, NSString * _Nullable icId, NSError *validationError))comp {
    WFSecurityLog("Validating AppleID Validation Record");
    SFAppleIDClient *client = [[SFAppleIDClient alloc]init];
    SFAppleIDAccount *account = [client myAccountWithError:nil];
    NSString *userDSID = [account altDSID];
    if ([userDSID isEqualToString:[[self appleIDValidationRecord]altDSID]]) {
        /* Shared by the user themselves, allow import */
        WFSecurityLog("Found the current user's AppleID Validation Record");
        comp(1, 3, 0, 0);
    } else {
        if ([WFSharingSettings isPrivateSharingEnabled]) {
            NSString *emailHashString = WFCombinedHashStringFromArray([[self appleIDValidationRecord] validatedEmailHashes]);
            NSString *phoneHashString = WFCombinedHashStringFromArray([[self appleIDValidationRecord] validatedPhoneHashes]);
            SFClient *sfclient = [[SFClient alloc]init];
            [sfclient contactIDForEmailHash:emailHashString phoneHash:phoneHashString completion:^(BOOL success){
                NSError *err = nil;
                if (success) {
                    WFSecurityLog("Found contact matching with AppleID Validation Record");
                } else {
                    err = [NSError errorWithDomain:@"WFWorkflowErrorDomain" code:0x5 userInfo:@{
                        NSLocalizedDescriptionKey : WFLocalizedString(@"This shortcut cannot be opened because it was shared by someone who is not in your contacts."),
                    }];
                    WFSecurityLog("Contact with matching AppleID Validation Record Couldn't be found");
                }
                comp(success, 2, 0, err);
            }];
        } else {
            WFSecurityLog("Skipping AppleID Validation Record due to Private Sharing Disabled");
            comp(0, 2, 0, [WFSharingSettings privateSharingDisabledErrorWithShortcutName:nil]);
        }
    }
}
/* This is an awful decomp of the iCloud verification I attempted maybe about 6-12(?) months back when I was much less skilled. Ignore this... */
-(BOOL)validateSigningCertificateChainWithICloudIdentifier:(*id)arg0 error:(*id)arg1 {
 //log
 NSArray *signingCertificateChain = [self signingCertificateChain];
 //FYI: This part of the method is NOT CORRECT at all bc i have no idea how if_map works lol sorry
 NSArray* certificates = [signingCertificateChain if_map:^{
  [signingCertificateChain certificate]; //WFShortcutSigningCertificate
 }];
 
 //this part im still iffy on but its definitely more accurate than above
 CFArrayRef signingCertificateChainRef = (__bridge CFArrayRef)signingCertificateChain;
 SecPolicyRef policy = SecPolicyCreateRevocation(kSecRevocationUseAnyAvailableMethod);
 SecTrustRef trust;
 OSStatus status = SecTrustCreateWithCertificates(signingCertificateChainRef, policy, &trust);
 if ((status) || (trust)) {
  CFStringRef commonName = arg0;
  SecCertificateRef leafCert = certificates[0];
  if (commonName) {
   SecCertificateCopyCommonName(leafCert, &commonName);
  }
  if (!SecTrustEvaluateWithError(trust, nil)) {
   //error
  }
  if (!SecCertificateCopyExtensionValue(leafCert, @"1.2.840.113635.100.18.1", nil)) {
   //error
  }
  //Shortcut Signing Certificate Chain Validated Successfully
  //CFRelease the stuff too lazy to add
  return YES;
 }
}
static __attribute__((always_inline)) BOOL WFAppleIDVerifyCertificateChain(NSArray *certificates) {
    /* TODO: While logs are implemented, NSErrors are not implemented ATM. */
    SecPolicyRef policy = SecPolicyCreateAppleIDAuthorityPolicy();
    SecPolicySetOptionsValue(policy,kSecPolicyCheckTemporalValidity,kCFBooleanFalse);
    if (policy) {
        SecTrustRef trust;
        OSStatus res = SecTrustCreateWithCertificates((__bridge CFArrayRef)certificates, policy, &trust);
        if (res == 0) {
            if (trust) {
                CFErrorRef trustErr;
                if (SecTrustEvaluateWithError(trust, &trustErr) == 0) {
                    CFErrorDomain domain = CFErrorGetDomain(trustErr);
                    if (CFEqual(domain, NSOSStatusErrorDomain)) {
                        if (CFErrorGetCode(trustErr) == errSecCertificateExpired) {
                            /* cert is valid if we reached here */
                            return YES;
                        } else {
                            WFSecurityErrorF("Signed Shortcut File Apple ID Certificate Chain Verification: SecTrustEvaluateWithError failed with error %@",trustErr);
                        }
                    } else {
                        WFSecurityErrorF("Signed Shortcut File Apple ID Certificate Chain Verification: SecTrustEvaluateWithError failed with error %@",trustErr);
                    }
                } else {
                    /* cert is valid if we reached here */
                    return YES;
                }
            } else {
                WFSecurityError("Signed Shortcut File Apple ID Certificate Chain Verification: SecTrustCreateWithCertificates returned NULL trust");
            }
        } else {
            WFSecurityErrorF("Signed Shortcut File Apple ID Certificate Chain Verification: SecTrustCreateWithCertificates failed with error %d",res);
        }
    } else {
        WFSecurityError("Signed Shortcut File Apple ID Certificate Chain Verification: SecPolicyCreateAppleIDAuthorityPolicy failed");
    }
    return NO;
}
-(BOOL)validateAppleIDCertificatesWithError:(NSError**)err {
    /* TODO: While logs are implemented, NSErrors are not implemented ATM. */
    WFSecurityLog("Validating AppleID Certificate Chain");
    NSArray <WFShortcutSigningCertificate *>* signingCertificateChain = [self appleIDCertificateChain];
    /* if_map is from IntentsFoundation.framework */
    NSArray* certificates = [signingCertificateChain if_map:^(WFShortcutSigningCertificate *item){
      [item certificate]; //WFShortcutSigningCertificate
    }];
    BOOL validCertificates = NO;
    if (certificates) {
        validCertificates = WFAppleIDVerifyCertificateChain(certificates);
    }
    if (validCertificates) {
        WFSecurityLog("Shortcut AppleID Certificate Chain Validated Successfully");
    } else {
        /*
         WFSecurityErrorF("Failed to Evaluate AppleID Certificate Chain: %@",verifyErr);
         */
    }
    return validCertificates;
}
/* This function is called in preformShortcutDataExtractionWithCompletion */
-(void)validateWithCompletion:(void(^)(BOOL success, int options, NSString * _Nullable icId, NSError *validationError))comp {
    NSArray *appleIDCertificateChain = [self appleIDCertificateChain];
    if (appleIDCertificateChain) {
        NSError *err = nil;
        BOOL result = [self validateAppleIDCertificatesWithError:&err];
        if (!result) {
            comp(result, 0, nil, err);
            return;
        }
        SFAppleIDValidationRecord *appleIDValidationRecord = [self appleIDValidationRecord];
        if (!appleIDValidationRecord) {
            /* error */
            comp(NO, 0, nil, [NSError errorWithDomain:@"WFWorkflowErrorDomain" code:0x5 userInfo:@{
                NSLocalizedDescriptionKey : WFLocalizedString(@"Failed to extract the shortcut file data"),
            }]);
            return;
        }
        [self validateAppleIDValidationRecordWithCompletion:comp];
        return;
    } else {
        NSString *icloudId = nil;
        NSError *err = nil;
        BOOL result = [self validateSigningCertificateChainWithICloudIdentifier:&icloudId error:&err];
        comp(result, 1, icloudId, err);
    }
}
+(WFShortcutSigningContext *)contextWithAuthData:(NSData *)authData {
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:authData options:0 format:0 error:nil];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        NSArray *signingCertChain = dict[@"SigningCertificateChain"];
        if (signingCertChain && [dict isKindOfClass:[NSArray class]]) {
            NSArray *compactMapSigningCertChain = [signingCertChain if_compactMap:^(NSData *data){
                return [[WFShortcutSigningCertificate alloc]initWithCertificateData:data];
            }];
            if ([compactMapSigningCertChain count] == [signingCertChain count]) {
                return [self contextWithSigningCertificateChain:compactMapSigningCertChain];
            } else {
                return nil;
            }
        } else {
            NSArray *appleIDCertChain = dict[@"AppleIDCertificateChain"];
            if (appleIDCertChain) {
                /* this method seems to get AppleIDCertificateChain twice? */
                appleIDCertChain = dict[@"AppleIDCertificateChain"];
                if (appleIDCertChain && [appleIDCertChain isKindOfClass:[NSArray class]]) {
                    NSArray *compactMapAppleIDCertChain = [appleIDCertChain if_compactMap:^(NSData *data){
                        return [[WFShortcutSigningCertificate alloc]initWithCertificateData:data];
                    }];
                    if ([compactMapAppleIDCertChain count] == [appleIDCertChain count]) {
                        NSData *signingPublicKey = dict[@"SigningPublicKey"];
                        if (![signingPublicKey isKindOfClass:[NSData class]]) {
                            signingPublicKey = nil;
                        }
                        NSData *signingPublicKeySignature = dict[@"SigningPublicKeySignature"];
                        if (![signingPublicKeySignature isKindOfClass:[NSData class]]) {
                            signingPublicKeySignature = nil;
                        }
                        SecKeyRef publicKey = [[compactMapAppleIDCertChain firstObject]copyPublicKey];
                        SecKeyCreateWithData((__bridge CFDataRef)signingPublicKey, (__bridge CFDictionaryRef)@{
                            (__bridge NSString *)kSecAttrKeyType : (__bridge NSString *)kSecAttrKeyTypeECSECPrimeRandom,
                            (__bridge NSString *)kSecAttrKeyClass : (__bridge NSString *)kSecAttrKeyClassPublic,
                        }, nil);
                        Boolean isVerified = SecKeyVerifySignature(publicKey, kSecKeyAlgorithmRSASignatureMessagePSSSHA256, (__bridge CFDataRef)signingPublicKey, (__bridge CFDataRef)signingPublicKeySignature, nil);
                        if (isVerified) {
                            NSData *appleIDValidationRecord = dict[@"AppleIDValidationRecord"];
                            if (appleIDValidationRecord) {
                                /* also checked for twice? */
                                appleIDValidationRecord = dict[@"AppleIDValidationRecord"];
                                if (appleIDValidationRecord) {
                                    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                                    dispatch_queue_t queue = dispatch_queue_create("SFAppleIDQueue",attr);
                                    dispatch_semaphore_create(0);
                                    if (!queue) {
                                        queue = dispatch_get_global_queue(0, 0);
                                    }
                                    SecPolicyRef policy = SecPolicyCreateAppleIDValidationRecordSigningPolicy();
                                    if (policy) {
                                        SecPolicySetOptionsValue(policy, kSecPolicyCheckTemporalValidity, kCFBooleanFalse);
                                        SecTrustRef trust = 0;
                                        CFDataRef attachedRecordContents = 0;
                                        if (SecCMSVerifyCopyDataAndAttributes((__bridge CFDataRef)appleIDValidationRecord, 0, policy, &trust, &attachedRecordContents, 0) == 0) {
                                            if (trust && attachedRecordContents) {
                                                NSDictionary *authDict = [NSPropertyListSerialization propertyListWithData:(__bridge NSData *)attachedRecordContents options:0 format:0 error:0];
                                                if (authDict) {
                                                    SecTrustEvaluateAsync(trust, queue, ^(SecTrustRef  _Nonnull trustRef, SecTrustResultType trustResult) {
                                                        if ((trustResult == kSecTrustResultProceed) || (trustResult == kSecTrustResultUnspecified)) {
                                                            /* CFDictionaryGetInt64 is from PrivateFrameworks/CoreUtils.m */
                                                            uint64_t authVersion = CFDictionaryGetInt64_CarplayImpl((__bridge CFDictionaryRef)authDict, @"Version", nil);
                                                            if (authVersion >= 0x65) {
                                                                /* Error, authVersion must be between 1 and 100 */
                                                            } else {
                                                                /* Call completion */
                                                                /* finish later */
                                                            }
                                                        }
                                                    });
                                                    /* finish later */
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                /* error? */
                            }
                        }
                    }
                }
            }
        }
    }
    /* error */
    return nil;
}
-(instancetype)initWithAppleIDValidationRecord:(SFAppleIDValidationRecord *)record appleIDCertificateChain:(NSArray *)chain signingPublicKey:(SecKeyRef)pubKey signingPublicKeyData:(NSData *)data {
    self = [super init];
    if (self) {
        self->_appleIDValidationRecord = record;
        self->_appleIDCertificateChain = chain;
        self->_signingPublicKey = pubKey;
        self->_signingPublicKeySignature = data;
    }
    return self;
}
+(WFShortcutSigningContext *)contextWithAppleIDAccount:(SFAppleIDAccount *)account signingKey:(SecKeyRef)key {
    SFAppleIDIdentity *identity = [account identity];
    if (identity) {
        OpaqueSecCertificateRef cert = [[account identity]copyCertificate];
        OpaqueSecCertificateRef intercert = [[account identity]copyIntermediateCertificate];
        if (cert) {
            if (intercert) {
                WFShortcutSigningCertificate *appleIDCert = [[WFShortcutSigningCertificate alloc] initWithCertificate:cert];
                WFShortcutSigningCertificate *appleIDCert2 = [[WFShortcutSigningCertificate alloc] initWithCertificate:copyIntermediateCertificate];
                OpaqueSecKeyRef privateKey = [identity copyPrivateKey];
                if (privateKey) {
                    SecKeyRef pubKey = SecKeyCopyPublicKey(key);
                    CFDataRef data = SecKeyCopyExternalRepresentation(pubKey);
                    NSData *signature = (__bridge NSData *)SecKeyCreateSignature(privateKey, kSecKeyAlgorithmRSASignatureMessagePSSSHA256, data, 0);
                    return [[self alloc]initWithAppleIDValidationRecord:[account validationRecord] appleIDCertificateChain:@[
                        appleIDCert,
                        appleIDCert2
                    ] signingPublicKey:pubKey signingPublicKeyData:signature];
                }
            }
        }
    }
}
+(WFShortcutSigningContext *)contextWithSigningCertificateChain:(NSArray *)signingChain {
    return [[self alloc]initWithSigningCertificateChain:signingChain];
}
@end
