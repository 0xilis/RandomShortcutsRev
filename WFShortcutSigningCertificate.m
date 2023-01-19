#import <Foundation/Foundation.h>
#import "WFShortcutSigningCertificate.h"

@implementation WFShortcutSigningCertificate
-(id)generateAuthData {
 return SecCertificateCopyData([self certificate]);
}
-(struct __SecKey *)copyPublicKey {
 return SecCertificateCopyKey([self certificate]);
}
-(id)initWithCertificate:(struct __SecCertificate *)arg0 {
 self = [super init];
 if (self) {
  self.certificate = arg0;
 }
 return self;
}
-(id)initWithCertificateData:(id)arg0 {
 SecCertificateRef cert = SecCertificateCreateWithData(0, arg0);
 if (cert) {
  return [self initWithCertificate:cert];
 }
 return 0;
}

@end
