//
//  CollectionViewCell.m
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

//- (void)awakeFromNib
//{
//    NSUInteger pickACat = arc4random_uniform(4) + 1;     // Vary from 1 to 4.
//    NSString *catFilename = [NSString stringWithFormat:@"cat%lu.jpg", (unsigned long)pickACat];
//    UIImageView *imageView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:catFilename]];
//    // Scale with fill for contents when we resize.
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    
//    // Scale the imageview to fit inside the contentView with the image centered:
//    CGRect imageViewFrame = CGRectMake(0.f, 0.f, CGRectGetMaxX(self.contentView.bounds), CGRectGetMaxY(self.contentView.bounds));
//    imageView.frame = imageViewFrame;
//    //imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    imageView.clipsToBounds = YES;
//    _imageView = imageView;
//    //self.bounds.size = imageView.bounds.size;
//    //[self.contentView addSubview:imageView];
//}
//


//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Pick a cat at random.
//        NSUInteger pickACat = arc4random_uniform(4) + 1;     // Vary from 1 to 4.
//        NSString *catFilename = [NSString stringWithFormat:@"cat%lu.jpg", (unsigned long)pickACat];
//        UIImageView *imageView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:catFilename]];
//        // Scale with fill for contents when we resize.
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        
//        // Scale the imageview to fit inside the contentView with the image centered:
//        CGRect imageViewFrame = CGRectMake(0.f, 0.f, CGRectGetMaxX(self.contentView.bounds), CGRectGetMaxY(self.contentView.bounds));
//        imageView.frame = imageViewFrame;
//        //imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        imageView.clipsToBounds = YES;
//        _imageView = imageView;
//        [self.contentView addSubview:imageView];
//    }
//    return self;
//}



@end
