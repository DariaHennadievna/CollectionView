//
//  ViewController.h
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewLayout.h"
#import "CollectionViewCell.h"
#import "ManagerData.h"
#import <UIImageView+AFNetworking.h>

@interface ViewController : UIViewController <UICollectionViewDataSource, CollectionViewDelegateLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end

