//
//  WFShortcutSigningCertificate.h
//  UnsigncutsApp
//
//  Created by Snoolie Keffaber on 2023/11/29.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFShortcutSigningCertificate : NSObject
@property (readonly, nonatomic) NSString *commonName;
-(SecKeyRef)copyPublicKey;
-(NSData *)generateAuthData;
-(instancetype)initWithCertificate:(SecCertificateRef)cert;
-(instancetype)initWithCertificateData:(NSData *)data;
@property (readonly, nonatomic) NSDate *expirationDate;
@property (nonatomic) SecCertificateRef certificate;
@end

NS_ASSUME_NONNULL_END
