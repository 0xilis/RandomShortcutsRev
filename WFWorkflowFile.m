#import "WFWorkflowFile.h"

@implementation WFWorkflowFileDescriptor
-(instancetype)initWithFile:(WFFileRepresentation *)file name:(NSString *)name {
    return [self initWithFile:file name:name sourceAppIdentifier:nil];
}
-(instancetype)initWithFile:(WFFileRepresentation *)file name:(NSString *)name sourceAppIdentifier:(NSString * _Nullable)sourceAppID {
    if (!file) {
        /* error with Invalid parameter not satisfying: %@ */
        return nil;
    }
    if (!name) {
        /* error with Invalid parameter not satisfying: %@ */
        return nil;
    }
    self = [super init];
    if (self) {
        _file = file;
        _name = name;
        _sourceAppIdentifier = sourceAppID;
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _file = [aDecoder decodeObjectOfClass:[WFFileRepresentation class] forKey:@"file"];
        _name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _sourceAppIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"sourceAppIdentifier"];
        if (_file && _name) {
            return self;
        }
        return nil;
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self file] forKey:@"file"];
    [aCoder encodeObject:[self name] forKey:@"name"];
    [aCoder encodeObject:[self sourceAppIdentifier] forKey:@"sourceAppIdentifier"];
}
-(id)copyWithZone:(struct _NSZone *)zone {
    return self;
}
+(BOOL)supportsSecureCoding {
    return YES;
}
@end

@implementation WFWorkflowFile
-(instancetype)init {
    return [self initWithDictionary:[NSDictionary new] name:nil];
}
-(instancetype)initWithFileData:(NSData *)fileData name:(NSString * _Nullable)name error:(NSError *)err {
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:fileData options:0 format:0 error:&err];
    if (dict) {
        return [self initWithDictionary:dict name:name];
    }
    return nil;
}
-(instancetype)initWithDictionary:(NSDictionary *)dict name:(NSString * _Nullable)name {
    return [self initWithDictionary:dict name:name performMigration:YES];
}
-(instancetype)initWithDictionary:(NSDictionary *)dict name:(NSString * _Nullable)name performMigration:(BOOL)migrate {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID]UUIDString];
        _rootObject = [dict mutableCopy];
        _name = [name copy];
        _creationDate = [NSDate date];
        _modificationDate = [NSDate date];
        if (migrate) {
            [self migrateRootObject];
        }
    }
    return self;
}
-(instancetype)initWithDescriptor:(WFWorkflowFileDescriptor *)desc error:(NSError *)err {
    return [self initWithDescriptor:desc performMigration:YES error:err];
}
-(instancetype)initWithDescriptor:(WFWorkflowFileDescriptor *)desc performMigration:(BOOL)migrate error:(NSError *)err {
    if (!desc) {
        /* error with Invalid parameter not satisfying: %@ */
        return nil;
    }
    WFFileRepresentation *fileRep = [desc file];
    NSInputStream *inputStream = [fileRep inputStream];
    [inputStream open];
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithStream:inputStream options:0 format:0 error:&err];
    [inputStream close];
    if (dict) {
        self = [super init];
        if (self) {
            _identifier = [[NSUUID UUID]UUIDString];
            _rootObject = [dict mutableCopy];
            _name = [[desc name]copy];
            _creationDate = [fileRep creationDate];
            NSDate *modificationDate = [fileRep modificationDate];
            if (!modificationDate) {
                modificationDate = [NSDate date];
            }
            _modificationDate = modificationDate;
            NSString *sourceAppID = [desc sourceAppIdentifier];
            if (sourceAppID) {
                _quarantine = [[WFWorkflowQuarantine alloc]initWithSourceAppIdentifier:[desc sourceAppIdentifier] importDate:[NSDate date]];
            }
            if (migrate) {
                [self migrateRootObject];
            }
            return self;
        }
    }
    return nil;
}
-(WFWorkflowFileDescriptor *)descriptor {
    WFFileRepresentation *fileRep = [self file];
    if (fileRep) {
        return [[WFWorkflowFileDescriptor alloc]initWithFile:[self file] name:[self name] sourceAppIdentifier:[[self quarantine]sourceAppIdentifier]];
    }
    return nil;
}
-(NSUInteger)estimatedSize {
    return [[self file]fileSize];
}
-(WFWorkflowRecord *)recordRepresentationWithError:(NSError*)err {
    return [[WFWorkflowRecord alloc]initWithStorage:self];
}
-(WFWorkflowIcon *)icon {
    /* TODO: some _WFEnforceClass.23711 calls are missing */
    NSDictionary *rootObj = _rootObject;
    NSDictionary *wfWorkflowIcon = rootObj[@"WFWorkflowIcon"];
    NSNumber *iconStartColor = wfWorkflowIcon[@"WFWorkflowIconStartColor"];
    NSNumber *iconGlyphNumber = wfWorkflowIcon[@"WFWorkflowIconGlyphNumber"]; /* this gets downcasted to 16 bit */
    NSData *data = wfWorkflowIcon[@"WFWorkflowIconImageData"];
    return [[WFWorkflowIcon alloc] initWithBackgroundColorValue:[iconStartColor integerValue] glyphCharacter:[iconGlyphNumber unsignedIntegerValue] customImageData:data];
}
-(BOOL)migrateRootObject {
    /* temp */
    return YES;
}
@end
