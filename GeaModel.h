//
//  GeaModel.h
//  GeaBookDesigner
//
//  Created by Johnny Cubehead on 12-9-6.
//
//

#import <Foundation/Foundation.h>

@interface GeaModel : NSObject

+ (id)modelWithJson:(NSDictionary *)json;
+ (NSArray *)modelWithJsonArray:(NSArray *)array;

- (NSSet *)propertiesForJson;

- (NSDictionary *)propertiesMap;

- (NSDictionary *)propertyClassMap;

- (void)loadFromJson:(NSDictionary *)json;

- (void)writeToJson:(NSMutableDictionary *)json;

- (void)writeProperty:(NSString *)prop toJson:(NSMutableDictionary *)json;

- (void)beforeWrite;

- (void)afterLoaded;

- (void)setup;

- (NSDictionary *) json;

@end

@interface NSArray(GeaModel)

-(NSString *) geaJSON;

@end


