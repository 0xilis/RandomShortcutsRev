#import "WFShortcutExporter.h"

@interface WFP2PSignedShortcutFileExporter : WFShortcutExporter
@property (retain, nonatomic) WFFileRepresentation *signedShortcutFile;
-(void)exportWorkflowWithCompletion:(id)arg0;
@end
