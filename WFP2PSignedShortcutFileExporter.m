#import <Foundation/Foundation.h>
#import "WFP2PSignedShortcutFileExporter.h"

@implementation WFP2PSignedShortcutFileExporter
-(void)exportWorkflowWithCompletion:(void(^)(NSURL *fileURL, NSError *err))comp {
    WFFileRepresentation *fileRep = [self.workflowRecord fileRepresentation];
    [fileRep setName:[self.workflowRecord name]];
    NSError *err;
    NSData *data = [fileRep fileDataWithError:&err];
    if (data) {
        WFShortcutPackageFile *package = [[WFShortcutPackageFile alloc]initWithShortcutData:data shortcutName:[self.workflowRecord name]];
        SFAppleIDAccount *account = [[[SFAppleIDClient alloc]init]myAccountWithError:&err];
        if (account) {
            WFFileRepresentation *signedShortcutFile = [package generateSignedShortcutFileRepresentationWithAccount:account error:&err];
            if (signedShortcutFile) {
                [self setSignedShortcutFile:signedShortcutFile];
                comp([signedShortcutFile fileURL], nil);
            }
        }
    }
}
@end
