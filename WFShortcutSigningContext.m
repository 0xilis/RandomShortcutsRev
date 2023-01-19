
-(id)generateAuthData {
 NSArray* certChain = [self signingCertificateChain];
 if ([certChain count]) {
 } else {
   if ([self appleIDValidationRecord]) {
     long dumb = [[self appleIDCertificateChain]if_compactMap:^{},wip,wip];
     if (dumb == [[self signingCertificateChain] count]) {
       SecKeyCopyExternalRepresentation([self signingPublicKey], 0);
       @"AppleIDCertificateChain";
       @"SigningPublicKey";
       @"SigningPublicKeySignature";
       [self signingPublicKeySignature];
       [NSDictionary dictionaryWithObjects: forKeys:@"AppleIDCertificateChain",@"SigningPublicKey",@"SigningPublicKeySignature",@"AppleIDValidationRecord" count:4]; //this is especially wip
     } else {
       //error
     }
   } else {
     return [NSPropertyListSerialization dataWithPropertyList:0 format:NSPropertyListBinaryFormat_v1_0 options:nil error:nil]; //??????
   }
 }
}
