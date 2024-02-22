#import "WFShortcutExporter.h"

@interface WFP2PSignedShortcutFileExporter : WFShortcutExporter
@property (retain, nonatomic) WFFileRepresentation *signedShortcutFile;
-(void)exportWorkflowWithCompletion:(void(^)(NSURL *fileURL, NSError *err))comp;
@end
