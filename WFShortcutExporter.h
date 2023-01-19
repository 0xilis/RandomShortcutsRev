#import <Foundation/Foundation.h>
#import "WFWorkflowRecord.h"

@interface WFShortcutExporter : NSObject
@property (readonly, nonatomic) WFWorkflowRecord *workflowRecord;
-(id)initWithWorkflow:(id)arg0 sharingOptions:(id)arg1;
-(id)initWithWorkflowRecord:(id)arg0;
-(void)exportWorkflowWithCompletion:(id)arg0;
@end
