#import <Foundation/Foundation.h>

@interface WFShortcutSigningCertificate : NSObject
@property (nonatomic) *__SecCertificate certificate;
@property (readonly, nonatomic) NSString *commonName;
@property (readonly, nonatomic) NSDate *expirationDate;
-(id)generateAuthData;
-(id)initWithCertificate:(struct __SecCertificate *)arg0 ;
-(id)initWithCertificateData:(id)arg0 ;
-(struct __SecKey *)copyPublicKey;
@end
