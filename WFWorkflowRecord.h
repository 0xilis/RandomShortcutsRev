#import "WFRecord.h"
#import "WFWorkflowIcon.h"
#import "WFWorkflowQuarantine.h"
#import "WFNaming-Protocol.h"

@interface WFWorkflowRecord : WFRecord <WFNaming>
@property (copy, nonatomic) NSSet *accessResourcePerWorkflowStates;
@property (nonatomic) NSInteger actionCount;
@property (copy, nonatomic) NSArray *actions;
@property (copy, nonatomic) NSString *actionsDescription;
@property (copy, nonatomic) NSString *associatedAppBundleIdentifier;
@property (copy, nonatomic) NSData *cloudKitRecordMetadata;
@property (readonly, nonatomic) BOOL conflictOfOtherWorkflow;
@property (retain, nonatomic) NSDate *creationDate;
@property (nonatomic) BOOL deleted;
@property (readonly, nonatomic) NSUInteger estimatedSize;
@property (copy, nonatomic) NSString *galleryIdentifier;
@property (nonatomic) BOOL hasOutputFallback;
@property (nonatomic) BOOL hasShortcutInputVariables;
@property (nonatomic) BOOL hiddenFromLibraryAndSync;
@property (nonatomic) BOOL hiddenInComplication;
@property (retain, nonatomic) WFWorkflowIcon *icon;
@property (copy, nonatomic) NSArray *importQuestions;
@property (copy, nonatomic) NSArray *inputClasses;
@property (copy, nonatomic) NSString *lastMigratedClientVersion;
@property (copy, nonatomic) NSString *lastSavedOnDeviceName;
@property (nonatomic) NSInteger lastSyncedHash;
@property (copy, nonatomic) NSString *legacyName;
@property (copy, nonatomic) NSString *minimumClientVersion;
@property (retain, nonatomic) NSDate *modificationDate;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSDictionary *noInputBehavior;
@property (copy, nonatomic) NSArray *outputClasses;
@property (retain, nonatomic) WFWorkflowQuarantine *quarantine;
@property (copy, nonatomic) NSArray *quickActionSurfacesForSharing;
@property (nonatomic) NSInteger remoteQuarantineStatus;
@property (copy, nonatomic) NSSet *smartPromptPerWorkflowStates;
@property (copy, nonatomic) NSString *source;
@property (nonatomic) NSInteger syncHash;
@property (readonly, copy, nonatomic) NSString *wfName;
@property (copy, nonatomic) NSString *workflowSubtitle;
@property (copy, nonatomic) NSArray *workflowTypes;
+(id)defaultPropertyValues;
+(id)workflowSubtitleForActionCount:(NSUInteger)arg0 savedSubtitle:(id)arg1;
-(BOOL)addWatchWorkflowTypeIfEligible;
-(BOOL)addWatchWorkflowTypeIfEligibleWithIneligibleActionIdentifiers:(id)arg0;
-(BOOL)hasOutputFallback;
-(BOOL)hasShortcutInputVariables;
-(BOOL)hiddenFromLibraryAndSync;
-(BOOL)hiddenInComplication;
-(BOOL)isEligibleForWatch;
-(BOOL)isEligibleForWatchWithIneligibleActionIdentifiers:(id)arg0;
-(BOOL)isEquivalentForSyncTo:(id)arg0;
-(BOOL)loadFromPeaceData:(id)arg0 keyImageData:(id)arg1 error:(NSError**)arg2;
-(BOOL)saveChangesToStorage:(id)arg0 error:(NSError**)arg1;
-(id)fileRepresentation;
-(id)initWithPeaceCloudKitRecord:(id)arg0 error:(NSError**)arg1;
-(id)initWithPeaceCoreDataModel:(id)arg0 error:(NSError**)arg1;
-(void)addWatchWorkflowType;
@end
