#import "WFRecord.h"
#include <objc/runtime.h>
#import "WFCoreDataWorkflow.h"

void *WFRecordPropertyObservationContext;

@implementation WFRecord
-(instancetype)init {
    return [self initWithStorage:nil];
}
-(instancetype)initWithStorage:(_Nullable id)storage {
    return [self initWithStorage:storage properties:nil];
}
-(instancetype)initWithStorage:(_Nullable id)storage properties:(_Nullable id)prop {
    self = [super init];
    if (self) {
        _allPropertiesByName = [[self class] recordSubclassProperties];
        _fetchedPropertyNames = [NSMutableSet new];
        _modifiedPropertyNamesSinceLastSave = [NSMutableSet new];
        _lastSavedOrFetchedValues = [NSMutableDictionary new];
        _modifiedPropertyNames = [NSMutableSet new];
        _lastFetchedValues = [NSMutableDictionary new];
        _storageIdentifier = [storage identifier];
        NSDictionary *defaultPropertyValues = [[self class]defaultPropertyValues];
        [defaultPropertyValues enumerateKeysAndObjectsUsingBlock:^(id value, NSString *key, BOOL *stop) {
            [_lastFetchedValues setValue:value forKey:key];
        }];
        if (storage) {
            [self loadFromStorage:storage properties:prop];
        }
        /* IDK [self resetModificationsForProperties:onlySinceLastSave:]; */
        [self setupPropertyObservation];
    }
    return self;
}
-(NSSet *)allProperties {
    return [NSSet setWithArray:[[self allPropertiesByName]allValues]];
}
-(void)loadFromStorage:(_Nullable id)storage {
    [self loadFromStorage:storage properties:nil];
}
-(void)loadFromStorage:(_Nullable id)storage properties:(_Nullable id)prop {
    id recordPropertyMap;
    NSSet *properties = prop;
    if ([storage respondsToSelector:@selector(recordPropertyMap)]) {
        recordPropertyMap = [storage recordPropertyMap];
    } else {
        recordPropertyMap = 0x0;
    }
    if (!prop) {
        properties = [NSSet setWithArray:[[self allPropertiesByName]allKeys]];
    }
    [WFRecord propertiesForClass:[storage class] walkingSuperclassesUntilReaching:[NSObject class]];
    /*
     struct stuff
     */
    //[prop countByEnumeratingWithState:rdx objects:rcx count:0x10];
    
    //finish latr
}
-(void)enumerateSettablePropertiesWithBlock:(id)arg0 {
    /* temp */
}
-(void)setupPropertyObservation {
    [self enumerateSettablePropertiesWithBlock:^(id something){
        [self addObserver:self forKeyPath:[something name] options:nil context:WFRecordPropertyObservationContext];
    }];
}
+(id)recordSubclassProperties {
    static NSCache *cachedProperties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachedProperties = [NSCache new];
    });
    if (cachedProperties) {
        return cachedProperties;
    }
    id propertiesForClass = [self propertiesForClass:self walkingSuperclassesUntilReaching:[WFRecord class]];
    cachedProperties = propertiesForClass;
    return propertiesForClass;
}
+(id)propertiesForClass:(Class)cls walkingSuperclassesUntilReaching:(Class)arg1 {
    NSMutableDictionary *propertyList = [NSMutableDictionary new];
    while (![cls isEqual:arg1]) {
        if (![cls isSubclassOfClass:arg1]) {
            break;
        }
        [propertyList addEntriesFromDictionary:[self propertiesForClass:cls]];
        cls = [cls superclass];
    }
    return propertyList;
}

NSDictionary *defaultPropertyValues;

+(NSDictionary *)defaultPropertyValues {
    return defaultPropertyValues;
}
+(NSSet *)ignoredPropertyNames {
    return [NSSet setWithObjects:@"wfName",@"description",@"debugDescription",@"hash",@"superclass", nil];
}
+(id)propertiesForClass:(Class)cls {
    /* temp */
    NSMutableDictionary *retPropertiesForClass = [NSMutableDictionary new];
    NSSet *ignoredPropertyNames = [WFRecord ignoredPropertyNames];
    if ([cls respondsToSelector:@selector(ignoredPropertyNames)]) {
        ignoredPropertyNames = [cls ignoredPropertyNames];
    }
    unsigned int propCount;
    objc_property_t *properties = class_copyPropertyList(self, &propCount);
    if (propCount != 0) {
        for (unsigned int i = 0; i < propCount; i++) {
            const char *propNameCString = property_getName(properties[i]);
            NSString *propName = [NSString stringWithUTF8String:propNameCString];
            if (![ignoredPropertyNames containsObject:propName]) {
                WFRecordProperty *recordProperty = [[WFRecordProperty alloc]initWithName:propName property:properties[i]];
                if (recordProperty) {
                    [retPropertiesForClass setObject:recordProperty forKey:propName];
                }
            }
        }
    }
    free(properties);
    return retPropertiesForClass;
}
@end
