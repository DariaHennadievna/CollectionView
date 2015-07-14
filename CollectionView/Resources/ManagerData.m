//
//  ManagerData.m
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ManagerData.h"

@implementation ManagerData

-(id)initWithDictionary:(NSDictionary *)aDict{
    self = [self init];
    if (self)
    {
        // для каждого объекта из .json буду сохранять адрес картинки
        self.imageFilename = [aDict objectForKey:@"imageFilename"];
    }
    return self;
}

@end
