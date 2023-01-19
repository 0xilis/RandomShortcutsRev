#import <Foundation/Foundation.h>
#import "WFP2PSignedShortcutFileExporter.h"

@implementation WFP2PSignedShortcutFileExporter
-(void)exportWorkflowWithCompletion:(id)arg0 {
 id rep = [[self workflowRecord] fileRepresentation];
 [rep setName:[[self workflowRecord]name]];
 NSData * fileData = [rep fileDataWithError:nil];
 if (fileData) {
   WFWorkflowRecord *workflowRecord = [self workflowRecord];
   WFShortcutPackageFile* shortcutPackage = [[WFShortcutPackageFile alloc] initWithShortcutData:fileData shortcutName:[workflowRecord name]];
   SFAppleIDAccount* account = [[[SFAppleIDClient alloc]init]myAccountWithError:nil];
   if (account) {
     id signedShortcutFile = [shortcutPackage generateSignedShortcutFileRepresentationWithAccount:account error:nil];
     if (signedShortcutFile) {
       [self setSignedShortcutFile:signedShortcutFile];
       arg0([signedShortcutFile fileURL]);
     } else {
       //error
     }
   } else {
     //error
   }
 } else {
   //error
 }
}
@end
