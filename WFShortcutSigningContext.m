#import <Foundation/Foundation.h>
#import "WFShortcutSigningContext.h"

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
@end
