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
@end
