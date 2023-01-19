#import "WFShortcutExporter.h"

@interface WFiCloudShortcutFileExporter : WFShortcutExporter
@property (retain, nonatomic) WFFileRepresentation *signedShortcutFile;
-(void)exportWorkflowWithCompletion:(id)arg0;
@end
