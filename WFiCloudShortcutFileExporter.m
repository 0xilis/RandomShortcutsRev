//wip

@implementation WFiCloudShortcutFileExporter
/* @class WFiCloudShortcutFileExporter */
-(int)exportWorkflowWithCompletion:(id)arg0 {
    WFWorkflowRecord *workflowRecord = [arg0 workflowRecord];
    return [[WFGallerySessionManager sharedManager] uploadWorkflow:workflowRecord withName:[workflowRecord name] shortDescription:nil longDescription:nil private:YES completionHandler:nil];
}
@end
