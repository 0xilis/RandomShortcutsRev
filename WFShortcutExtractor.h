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
-(id)initWithFile:(id)file allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)arg2 suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(id)initWithFile:(id)file allowsOldFormatFile:(BOOL)allowOldFileFormat suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(id)initWithFile:(id)file suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(id)initWithURL:(id)url allowsOldFormatFile:(BOOL)allowOldFileFormat fileAdoptionOptions:(NSInteger)arg2 suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(id)initWithURL:(id)url allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)skipScanning fileAdoptionOptions:(NSInteger)options suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(id)initWithURL:(id)url allowsOldFormatFile:(BOOL)allowOldFileFormat skipsMaliciousScanning:(BOOL)arg2 suggestedName:(id)suggestName sourceApplication:(id)app;
-(id)initWithURL:(id)url allowsOldFormatFile:(BOOL)allowOldFileFormat suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(id)initWithURL:(id)url fileAdoptionOptions:(NSInteger)arg1 suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(id)initWithURL:(id)url suggestedName:(NSString *)suggestName sourceApplication:(id)app;
-(void)extractRemoteShortcutFileAtURL:(id)shortcutFileURL completion:(id)completion;
-(void)extractShortcutFile:(WFFileRepresentation*)shortcutFile completion:(id)completion;
-(void)extractShortcutWithCompletion:(id)completion;
-(void)extractSignedShortcutFile:(WFFileRepresentation*)shortcutFile allowsRetryIfExpired:(BOOL)allowRetry completion:(id)completion;
-(void)extractSignedShortcutFile:(WFFileRepresentation*)shortcutFile completion:(id)completion;
-(void)extractWorkflowFile:(WFFileRepresentation*)shortcutFile completion:(id)completion;
-(void)extractWorkflowFile:(WFFileRepresentation*)shortcutFile shortcutName:(NSString *)name shortcutFileContentType:(NSInteger)shortcutType iCloudIdentifier:(id)shortcutIdentifier completion:(id)completion;
@end
