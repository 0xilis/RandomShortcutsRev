#import <Foundation/Foundation.h>


@interface WFShortcutExtractor : NSObject

@property (readonly, nonatomic) BOOL allowsOldFormatFile; // ivar: _allowsOldFormatFile
@property (readonly, nonatomic) WFFileRepresentation *extractingFile; // ivar: _extractingFile
@property (readonly, nonatomic) NSURL *extractingURL; // ivar: _extractingURL
@property (readonly, nonatomic) NSInteger fileAdoptionOptions; // ivar: _fileAdoptionOptions
@property (readonly, nonatomic) BOOL skipsMaliciousScanning; // ivar: _skipsMaliciousScanning
@property (readonly, copy, nonatomic) NSString *sourceApplication; // ivar: _sourceApplication
@property (readonly, copy, nonatomic) NSString *suggestedName; // ivar: _suggestedName


+(BOOL)isShortcutFileType:(id)arg0 ;
-(BOOL)allowsOldFormatFile;
-(BOOL)skipsMaliciousScanning;
-(id)initWithFile:(id)arg0 allowsOldFormatFile:(BOOL)arg1 skipsMaliciousScanning:(BOOL)arg2 suggestedName:(id)arg3 sourceApplication:(id)arg4 ;
-(id)initWithFile:(id)arg0 allowsOldFormatFile:(BOOL)arg1 suggestedName:(id)arg2 sourceApplication:(id)arg3 ;
-(id)initWithFile:(id)arg0 suggestedName:(id)arg1 sourceApplication:(id)arg2 ;
-(id)initWithURL:(id)arg0 allowsOldFormatFile:(BOOL)arg1 fileAdoptionOptions:(NSInteger)arg2 suggestedName:(id)arg3 sourceApplication:(id)arg4 ;
-(id)initWithURL:(id)arg0 allowsOldFormatFile:(BOOL)arg1 skipsMaliciousScanning:(BOOL)arg2 fileAdoptionOptions:(NSInteger)arg3 suggestedName:(id)arg4 sourceApplication:(id)arg5 ;
-(id)initWithURL:(id)arg0 allowsOldFormatFile:(BOOL)arg1 skipsMaliciousScanning:(BOOL)arg2 suggestedName:(id)arg3 sourceApplication:(id)arg4 ;
-(id)initWithURL:(id)arg0 allowsOldFormatFile:(BOOL)arg1 suggestedName:(id)arg2 sourceApplication:(id)arg3 ;
-(id)initWithURL:(id)arg0 fileAdoptionOptions:(NSInteger)arg1 suggestedName:(id)arg2 sourceApplication:(id)arg3 ;
-(id)initWithURL:(id)arg0 suggestedName:(id)arg1 sourceApplication:(id)arg2 ;
-(void)extractRemoteShortcutFileAtURL:(id)arg0 completion:(id)arg1 ;
-(void)extractShortcutFile:(id)arg0 completion:(id)arg1 ;
-(void)extractShortcutWithCompletion:(id)arg0 ;
-(void)extractSignedShortcutFile:(id)arg0 allowsRetryIfExpired:(BOOL)arg1 completion:(id)arg2 ;
-(void)extractSignedShortcutFile:(id)arg0 completion:(id)arg1 ;
-(void)extractWorkflowFile:(id)arg0 completion:(id)arg1 ;
-(void)extractWorkflowFile:(id)arg0 shortcutName:(id)arg1 shortcutFileContentType:(NSInteger)arg2 iCloudIdentifier:(id)arg3 completion:(id)arg4 ;


@end
