#import <Foundation/Foundation.h>
#import "WFWorkflowRecord.h"
#import "WFWorkflowFileDescriptor.h"
#import "WFWorkflowQuarantine.h"
#import "WFWorkflowIcon.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFWorkflowFile : NSObject
-(instancetype)init;
-(instancetype)initWithFileData:(NSData *)fileData name:(NSString * _Nullable)name error:(NSError *)err;
-(instancetype)initWithDictionary:(NSDictionary *)dict name:(NSString * _Nullable)name;
-(instancetype)initWithDictionary:(NSDictionary *)dict name:(NSString * _Nullable)name performMigration:(BOOL)migrate;
-(instancetype)initWithDescriptor:(WFWorkflowFileDescriptor *)desc error:(NSError *)err;
-(instancetype)initWithDescriptor:(WFWorkflowFileDescriptor *)desc performMigration:(BOOL)migrate error:(NSError *)err;
-(WFWorkflowFileDescriptor *)descriptor;
@property (readonly, nonatomic) NSUInteger estimatedSize;
@property (retain, nonatomic) WFWorkflowIcon *icon;
-(WFWorkflowRecord *)recordRepresentationWithError:(NSError*)err;
-(BOOL)migrateRootObject;
@property (readonly, nonatomic) NSDictionary *rootObject;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) NSDate *creationDate;
@property (retain, nonatomic) NSDate *modificationDate;
@property (retain, nonatomic) WFWorkflowQuarantine *quarantine;
@property (readonly, nonatomic) WFFileRepresentation *file;
@property (readonly, nonatomic) NSString *identifier;
@end

NS_ASSUME_NONNULL_END
