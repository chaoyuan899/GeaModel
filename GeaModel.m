//
//  GeaModel.m
//  GeaBookDesigner
//
//  Created by Johnny Cubehead on 12-9-6.
//
//

#import "GeaModel.h"

static NSString const *CLASS_KEY = @"__class";


@implementation GeaModel

+ (id)modelWithJson:(NSDictionary *)json {
    GeaModel *model = [[self alloc] init];
    [model loadFromJson:json];
#if !__has_feature(objc_arc)
    return [model autorelease];
#else
    return model;
#endif
}

+(NSArray *)modelWithJsonArray:(NSArray *)array {
    NSMutableArray *list = [NSMutableArray array];
    if ([array isKindOfClass:[NSArray class]]&&array.count){
        for (NSDictionary *dict in array){
            [list addObject:[self modelWithJson:dict]];
        }
    }
    return [NSArray arrayWithArray:list];
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setup];
    return self;
}

- (void)setup {

}

- (NSSet *)propertiesForJson {
    return [NSSet set];
}

-(NSDictionary *) propertiesMap{
    return nil;
}

-(NSDictionary *) propertyClassMap{
    return nil;
}


- (void)loadProperty:(NSString *)prop with:(NSString *)p fromJson:(NSDictionary *)json {
    if (![json.allKeys containsObject:p]) {
        return;
    }
    id value = [json objectForKey:p];
    if ([value isKindOfClass:[NSArray class]]) {
        BOOL flag = NO;
        NSMutableArray *list = [NSMutableArray array];
        for (id v in value) {
            if ([v isKindOfClass:[NSDictionary class]]) {
                NSString *c = [v objectForKey:CLASS_KEY];
                if (!c){
                    c = [[self propertyClassMap] objectForKey:prop];
                }
                if (c){
                    Class clazz = NSClassFromString(c);
                    if (clazz) {
                        GeaModel *obj = [[clazz alloc] init];
                        [obj loadFromJson:v];
                        [list addObject:obj];
#if !__has_feature(objc_arc)
                        [obj release];
#endif
                    }
                } else {
                    [list addObject:v];
                }
            } else {
                flag = YES;
                break;
            }
        }
        if (flag) {
            [self setValue:value forKey:prop];
        } else {
            [self setValue:list forKey:prop];
        }
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *c = [value objectForKey:CLASS_KEY];
        if (!c){
            c = [[self propertyClassMap] objectForKey:prop];
        }
        Class clazz = NSClassFromString(c);
        if (clazz) {
            GeaModel *obj = [[clazz alloc] init];
            [obj loadFromJson:value];
            [self setValue:obj forKey:prop];
#if !__has_feature(objc_arc)
            [obj release];
#endif
        }
    } else {
        if (![value isKindOfClass:[NSNull class]]) {
            [self setValue:value forKey:prop];
        }
    }
}

- (void)writeProperty:(NSString *)prop toJson:(NSMutableDictionary *)json {
    id value = [self valueForKey:prop];
    if (!value)
        return;
    NSString *key = prop;
    NSDictionary *map = self.propertiesMap;
    if ([map.allKeys containsObject:prop]){
        NSString *s = [map objectForKey:prop];
        if (s.length){
            key = s;
        }
    }
    if ([value isKindOfClass:[NSArray class]]) {
        BOOL flag = NO;
        NSMutableArray *list = [NSMutableArray array];
        for (id v in value) {
            if (![v isKindOfClass:[GeaModel class]]) {
                flag = YES;
                break;
            }
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            GeaModel *model = v;
            [model writeToJson:dict];
            [list addObject:dict];
        }
        if (flag) {
            [json setObject:value forKey:key];
        } else {
            [json setObject:list forKey:key];
        }
    } else if ([value isKindOfClass:[GeaModel class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        GeaModel *model = value;
        [model writeToJson:dict];
        [json setObject:dict forKey:key];
    } else {
        [json setObject:value forKey:key];
    }
}

- (void)loadFromJson:(NSDictionary *)json {
    NSSet *set = [self propertiesForJson];
    NSDictionary *map = [self propertiesMap];
    NSString *prop = nil;
    for (prop in set) {
        NSString *p = [map objectForKey:prop];
        if (!p){
            p = prop;
        }
        [self loadProperty:prop with:p fromJson:json];
    }
    [self afterLoaded];
}

- (void)writeToJson:(NSMutableDictionary *)json {
    [self beforeWrite];
    NSSet *set = [self propertiesForJson];
    NSString *prop = nil;
    for (prop in set) {
        [self writeProperty:prop toJson:json];
    }
//    [json setObject:NSStringFromClass([self class]) forKey:CLASS_KEY];
}

- (void)beforeWrite {

}

- (void)afterLoaded {

}

-(NSDictionary*) json{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self writeToJson:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation NSArray (GeaModel)

-(NSString*) geaJSON{
    NSMutableArray *list = [NSMutableArray array];
    for (id obj in self) {
        if ([obj isKindOfClass:[GeaModel class]]) {
            GeaModel *model = obj;
            [list addObject:[model json]];
        }
    }
    return [list JSONString];
}

@end

