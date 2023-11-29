#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* From ContentKit.framework, placing this here since I don't have the ContentKit header for this :P */
@interface WFFileRepresentation : NSObject
-(NSInputStream *)inputStream;
@property (readonly, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) NSDate *modificationDate;
@property (readonly, nonatomic) NSInteger fileSize;
@end

@interface WFWorkflowFileDescriptor : NSObject
-(instancetype)initWithFile:(WFFileRepresentation *)file name:(NSString *)name;
-(instancetype)initWithFile:(WFFileRepresentation *)file name:(NSString *)name sourceAppIdentifier:(NSString * _Nullable)sourceAppID;
-(instancetype)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)copyWithZone:(struct _NSZone *)zone;
@property (readonly, nonatomic) WFFileRepresentation *file;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *sourceAppIdentifier;
+(BOOL)supportsSecureCoding;
@end

NS_ASSUME_NONNULL_END
