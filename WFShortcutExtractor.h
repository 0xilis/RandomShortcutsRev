#import <Foundation/Foundation.h>

@interface WFShortcutExtractor : NSObject
@property (readonly, nonatomic) BOOL allowsOldFormatFile;
@property (readonly, nonatomic) WFFileRepresentation *extractingFile;
@property (readonly, nonatomic) NSURL *extractingURL;
@property (readonly, nonatomic) NSInteger fileAdoptionOptions;
@property (readonly, nonatomic) BOOL skipsMaliciousScanning;
@property (readonly, copy, nonatomic) NSString *sourceApplication;
@property (readonly, copy, nonatomic) NSString *suggestedName;
+(BOOL)isShortcutFileType:(WFFileType *)fileType;
-(BOOL)allowsOldFormatFile;
-(BOOL)skipsMaliciousScanning;
-(id)initWithFile:(WFFileRepresentation *)file allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)skipScanning suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithFile:(WFFileRepresentation *)file allowsOldFormatFile:(BOOL)allowOldFileFormat suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithFile:(WFFileRepresentation *)file suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat fileAdoptionOptions:(NSInteger)options suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)skipScanning fileAdoptionOptions:(NSInteger)options suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)skipScanning suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithURL:(NSURL *)url allowsOldFormatFile:(BOOL)allowOldFileFormat suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithURL:(NSURL *)url fileAdoptionOptions:(NSInteger)options suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(id)initWithURL:(NSURL *)url suggestedName:(NSString *)suggestName sourceApplication:(NSString *)app;
-(void)extractRemoteShortcutFileAtURL:(id)shortcutFileURL completion:(id)completion;
-(void)extractShortcutFile:(WFFileRepresentation*)shortcutFile completion:(id)completion;
-(void)extractShortcutWithCompletion:(id)completion;
-(void)extractSignedShortcutFile:(WFFileRepresentation*)shortcutFile allowsRetryIfExpired:(BOOL)allowRetry completion:(id)completion;
-(void)extractSignedShortcutFile:(WFFileRepresentation*)shortcutFile completion:(id)completion;
-(void)extractWorkflowFile:(WFFileRepresentation*)shortcutFile completion:(id)completion;
-(void)extractWorkflowFile:(WFFileRepresentation*)shortcutFile shortcutName:(NSString *)name shortcutFileContentType:(NSInteger)shortcutType iCloudIdentifier:(id)shortcutIdentifier completion:(id)completion;
@end
