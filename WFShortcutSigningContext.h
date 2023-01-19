#import <Foundation/Foundation.h>

@interface WFShortcutSigningContext : NSObject

@property (readonly, copy, nonatomic) NSArray *appleIDCertificateChain;
@property (readonly, nonatomic) SFAppleIDValidationRecord *appleIDValidationRecord;
@property (readonly, nonatomic) NSDate *expirationDate;
@property (readonly, copy, nonatomic) NSArray *signingCertificateChain;
@property (nonatomic) *__SecKey signingPublicKey;
@property (retain, nonatomic) NSData *signingPublicKeySignature;

+(id)contextWithAppleIDAccount:(id)arg0 signingKey:(struct __SecKey *)arg1;
+(id)contextWithAuthData:(id)arg0;
+(id)contextWithSigningCertificateChain:(id)arg0;
-(BOOL)validateAppleIDCertificatesWithError:(NSError **)arg0;
-(BOOL)validateSigningCertificateChainWithICloudIdentifier:(*id)arg0 error:(NSError **)arg1;
-(BOOL)validateWithSigningMethod:(*NSInteger)arg0 error:(NSError **)arg1;
-(BOOL)validateWithSigningMethod:(*NSInteger)arg0 iCloudIdentifier:(*id)arg1 error:(NSError **)arg2;
-(id)generateAuthData;
-(id)initWithAppleIDValidationRecord:(id)arg0 appleIDCertificateChain:(id)arg1 signingPublicKey:(struct __SecKey *)arg2 signingPublicKeyData:(id)arg3;
-(id)initWithSigningCertificateChain:(id)arg0;
-(struct __SecKey *)copyPublicKey;
-(void)validateAppleIDValidationRecordWithCompletion:(id)arg0;
-(void)validateWithCompletion:(id)arg0;


@end
