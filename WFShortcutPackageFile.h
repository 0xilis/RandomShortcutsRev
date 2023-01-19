@interface WFShortcutPackageFile : NSObject
@property (readonly, nonatomic) NSString *directoryName;
@property (readonly, nonatomic) NSObject<OS_dispatch_queue> *executionQueue;
@property (readonly, nonatomic) NSFileManager *fileManager;
@property (readonly, nonatomic) NSString *fileName;
@property (readonly, nonatomic) NSString *sanitizedName;
@property (retain, nonatomic) NSData *shortcutData;
@property (readonly, nonatomic) NSString *shortcutName;
@property (retain, nonatomic) NSData *signedShortcutData;
@property (readonly, nonatomic) NSURL *signedShortcutFileURL;
@property (readonly, nonatomic) NSURL *temporaryWorkingDirectoryURL;
-(id)extractShortcutFileRepresentationWithError:(*id)arg0;
-(id)extractShortcutFileRepresentationWithSigningMethod:(*long)arg0 error:(*id)arg1;
-(id)extractShortcutFileRepresentationWithSigningMethod:(*long)arg0 iCloudIdentifier:(*id)arg1 error:(*id)arg2;
-(id)generateDirectoryStructureInDirectory:(id)arg0 error:(*id)arg1;
-(id)generateSignedShortcutFileRepresentationWithAccount:(id)arg0 error:(*id)arg1;
-(id)generateSignedShortcutFileRepresentationWithPrivateKey:(struct __SecKey *)arg0 signingContext:(id)arg1 error:(*id)arg2;
-(id)initWithShortcutData:(id)arg0 shortcutName:(id)arg1;
-(id)initWithSignedShortcutData:(id)arg0 shortcutName:(id)arg1;
-(id)initWithSignedShortcutFileURL:(id)arg0;
-(void)commonInit;
-(void)extractShortcutFileRepresentationWithCompletion:(id)arg0;
-(void)preformShortcutDataExtractionWithCompletion:(id)arg0;
@end
