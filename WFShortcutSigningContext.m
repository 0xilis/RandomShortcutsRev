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
@end
