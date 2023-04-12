#import <Foundation/Foundation.h>
#import "WFWorkflowMigration-Protocol.h"
@interface WFWorkflowMigration : NSObject <WFWorkflowMigration>
@property (readonly, nonatomic) NSString *actionIdentifierKey;
@property (readonly, nonatomic) NSString *actionParametersKey;
@property (readonly, nonatomic) NSMutableArray *actions;
@property (copy, nonatomic) id *completionHandler;
@property (readonly, nonatomic) NSMutableSet *warnings;
@property (readonly, nonatomic) NSMutableDictionary *workflow;
+(BOOL)workflowNeedsMigration:(id)placeholder fromClientVersion:(NSString *)oldVersion;
+(id)migrationClassDependencies;
-(void)enumerateActionsWithIdentifier:(NSString *)actionId usingBlock:(void (^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;
-(void)finish;
-(void)migrateWorkflow;
-(void)migrateWorkflowIfNeeded:(id)placeholder completion:(id)completion;
@end
