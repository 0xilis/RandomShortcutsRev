//
//  WFShortcutSigningCertificate.m
//  UnsigncutsApp
//
//  Created by Snoolie Keffaber on 2023/11/29.
//

#import "WFShortcutSigningCertificate.h"

@implementation WFShortcutSigningCertificate
-(NSString *)commonName {
    NSString *commonName = nil;
    CFStringRef cfCommonName = nil;
    OSStatus result = SecCertificateCopyCommonName([self certificate], &cfCommonName);
    if (result == 0) {
        commonName = (__bridge NSString*)cfCommonName;
    }
    return commonName;
}
-(SecKeyRef)copyPublicKey {
    return SecCertificateCopyKey([self certificate]);
}
-(NSData*)generateAuthData {
    return (__bridge NSData*)SecCertificateCopyData([self certificate]);
}
-(instancetype)initWithCertificate:(SecCertificateRef)cert {
    self = [super init];
    if (self) {
        _certificate = (SecCertificateRef)CFRetain(cert);
    }
    return self;
}
-(instancetype)initWithCertificateData:(NSData *)data {
    SecCertificateRef cert = SecCertificateCreateWithData(0, (__bridge CFDataRef)data);
    if (cert) {
        return [self initWithCertificate:cert];
    }
    return 0;
}

@end
