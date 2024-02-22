#import <Foundation/Foundation.h>
#import "WFShortcutSigningContext.h"

/*
 * This file in particular is VERY WIP.
 * Decomp of WFShortcutSigningContext sucks here.
 */

@implementation WFShortcutSigningContext
-(id)generateAuthData {
 NSArray* certChain = [self signingCertificateChain];
 if ([certChain count]) {
  long dumb = [[self signingCertificateChain]if_compactMap:^{},wip,wip];
  if (dumb == [[self signingCertificateChain] count]) {
   return [NSPropertyListSerialization dataWithPropertyList:[[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjects:dumb forKeys:@"SigningCertificateChain" count:1]] format:NSPropertyListBinaryFormat_v1_0 options:nil error:nil]; //this is especially wip
  } else {
   //error
  }
 } else {
   if ([self appleIDValidationRecord]) {
     long dumb = [[self appleIDCertificateChain]if_compactMap:^{},wip,wip];
     if (dumb == [[self appleIDCertificateChain] count]) {
       SecKeyCopyExternalRepresentation([self signingPublicKey], 0);
       return [NSPropertyListSerialization dataWithPropertyList:[[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjects:dumb,cert,[self signingPublicKeySignature],[[self appleIDValidationRecord]data] forKeys:@"AppleIDCertificateChain",@"SigningPublicKey",@"SigningPublicKeySignature",@"AppleIDValidationRecord" count:4]] format:NSPropertyListBinaryFormat_v1_0 options:nil error:nil]; //this is especially wip
     } else {
       //error
     }
   } else {
     return [NSPropertyListSerialization dataWithPropertyList:0 format:NSPropertyListBinaryFormat_v1_0 options:nil error:nil]; //??????
   }
 }
}
-(BOOL)validateWithSigningMethod:(*NSInteger)arg0 error:(NSError**)arg1 {
    return [self validateWithSigningMethod:arg0 iCloudIdentifier:nil error:arg1];
}
-(struct __SecKey *)copyPublicKey {
 if ([[self signingCertificateChain]count]) {
  return [[[self signingCertificateChain]firstObject]copyPublicKey];
 } else {
  return [self signingPublicKey];
 }
}
-(id)initWithAppleIDValidationRecord:(id)arg0 appleIDCertificateChain:(id)arg1 signingPublicKey:(struct __SecKey *)arg2 signingPublicKeyData:(id)arg3 {
 self = [super init];
 if (self) {
  self.appleIDValidationRecord = arg0;
  self.appleIDCertificateChain = arg1;
  self.signingPublicKey = arg2;
  self.signingPublicKeySignature = arg3;
 }
 return self;
}
-(id)initWithSigningCertificateChain:(id)arg0 {
 self = [super init];
 if ((self) && ([arg0 count])) {
  self.signingCertificateChain = arg0;
 }
 return self;
}
-(void)validateAppleIDValidationRecordWithCompletion:(id)completion {
 SFAppleIDAccount* account = [[[SFAppleIDClient alloc]init]myAccountWithError:nil];
 if ([[account altDSID]isEqualToString:[[self appleIDValidationRecord]altDSID]]) {
  completion(0x1,0x3,0x0,0x0);
 } else if ([WFSharingSettings isPrivateSharingEnabled]) {
  [[[SFClient alloc]init]contactIDForEmailHash:[[self appleIDValidationRecord]validatedEmailHashes] phoneHash:_WFCombinedHashStringFromArray([[self appleIDValidationRecord] validatedPhoneHashes]) completion:^{/*block*/}];
 }
}
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
-(BOOL)validateAppleIDCertificatesWithError:(NSError**)err {
    /* I haven't bothered to fill err yet but validation should be identical */
    NSArray <WFShortcutSigningCertificate *>* signingCertificateChain = [self appleIDCertificateChain];
    /* if_map is from IntentsFoundation.framework */
    NSArray* certificates = [signingCertificateChain if_map:^(WFShortcutSigningCertificate *item){
      [item certificate]; //WFShortcutSigningCertificate
    }];
    if (certificates) {
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
                            }
                        }
                    } else {
                        /* cert is valid if we reached here */
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
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
                            SFAppleIDValidationRecord *appleIDValidationRecord = dict[@"AppleIDValidationRecord"];
                            if (appleIDValidationRecord) {
                                /* also checked for twice? */
                                appleIDValidationRecord = dict[@"AppleIDValidationRecord"];
                                if (appleIDValidationRecord) {
                                   /* finish later */
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
        self->_signingCertificateChain = chain;
        self->_signingPublicKey = pubKey;
        self->_signingPublicKeySignature = data;
    }
    return self;
}
+(WFShortcutSigningContext *)contextWithAppleIDAccount:(SFAppleIDAccount *)account signingKey:(SecKeyRef)key {
    /* TODO: Implement logs + errors, for now this decomp doesn't handle errors/logs at all */
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
@end
