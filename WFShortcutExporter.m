#import <Foundation/Foundation.h>
#import "WFShortcutExporter.h"

@implementation WFShortcutExporter
-(id)initWithWorkflow:(id)arg0 sharingOptions:(id)arg1 {
    return [self initWithWorkflowRecord:[arg0 prepareForSharingWithOptions:arg1]];
}
-(id)initWithWorkflowRecord:(id)arg0 {
  self = [super init];
  if (self) {
    self.workflowRecord = arg0;
  }
  return self;
}
-(void)exportWorkflowWithCompletion:(id)arg0 {
  return;
}
@end
