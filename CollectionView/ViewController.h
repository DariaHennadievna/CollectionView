//
//  ViewController.h
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "CollectionViewCell.h"
//#import <AFNetworking/AFNetworking.h>
//#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

#import <UIImageView+AFNetworking.h>
//#import <UII>

@interface ViewController : UIViewController <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end

