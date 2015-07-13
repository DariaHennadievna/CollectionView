//
//  ManagerData.h
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    kMosaicLayoutTypeUndefined,
    kMosaicLayoutTypeSingle,
    kMosaicLayoutTypeDouble
} MosaicLayoutType;

@interface ManagerData : NSObject

-(id)initWithDictionary:(NSDictionary *)aDict;

@property (strong) NSString *imageFilename;
@property (strong) NSString *title;
@property (assign) BOOL firstTimeShown;
@property (assign) MosaicLayoutType layoutType;
@property (assign) float relativeHeight;
@end



