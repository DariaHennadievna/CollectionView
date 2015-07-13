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
        // для своей задачи я не использую title для картинок
        // по этому и сохранять его не буду.
        // для каждого объекта из .json буду сохранять только адрес картинки
        self.imageFilename = [aDict objectForKey:@"imageFilename"];
    }
    return self;
}

@end
