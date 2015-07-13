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
    if (self){
        self.imageFilename = [aDict objectForKey:@"imageFilename"];
        self.title = [aDict objectForKey:@"title"];
        self.firstTimeShown = YES;
    }
    return self;
}

-(NSString *)description{
    NSString *retVal = [NSString stringWithFormat:@"%@ %@", [super description], self.title];
    return retVal;
}

@end
