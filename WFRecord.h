#import <Foundation/Foundation.h>
#import "WFRecordProperty.h"

NS_ASSUME_NONNULL_BEGIN

@interface WFRecord : NSObject
@property (readonly, nonatomic) NSSet *allProperties;
@property (readonly, nonatomic) NSDictionary *allPropertiesByName;
@property (readonly, nonatomic) NSSet *fetchedProperties;
@property (readonly, nonatomic) NSMutableSet *fetchedPropertyNames;
@property (readonly, nonatomic) NSMutableDictionary *lastFetchedValues;
@property (readonly, nonatomic) NSMutableDictionary *lastSavedOrFetchedValues;
@property (readonly, nonatomic) NSSet *modifiedProperties;
@property (readonly, nonatomic) NSSet *modifiedPropertiesSinceLastSave;
@property (readonly, nonatomic) NSMutableSet *modifiedPropertyNames;
@property (readonly, nonatomic) NSMutableSet *modifiedPropertyNamesSinceLastSave;
@property (copy, nonatomic) NSString *storageIdentifier;
+(NSDictionary *)defaultPropertyValues;
+(NSSet *)ignoredPropertyNames;
-(instancetype)init;
-(instancetype)initWithStorage:(_Nullable id)storage;
-(instancetype)initWithStorage:(_Nullable id)storage properties:(_Nullable id)prop;
+(id)recordSubclassProperties;
+(id)propertiesForClass:(Class)cls;
+(id)propertiesForClass:(Class)cls walkingSuperclassesUntilReaching:(Class)arg1;
-(void)enumerateSettablePropertiesWithBlock:(id)arg0;
-(void)loadFromStorage:(_Nullable id)storage;
-(void)loadFromStorage:(_Nullable id)storage properties:(_Nullable id)prop;
+(void)resetModificationsForProperties:(id)arg0 onlySinceLastSave:(BOOL)arg1;
-(void)setupPropertyObservation;
@end

NS_ASSUME_NONNULL_END
