//
//  ViewController.m
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ViewController.h"
#import "ManagerData.h"

//#define CELL_COUNT 30
#define CELL_IDENTIFIER @"WaterfallCell"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *cellSizes;
@property (nonatomic) ManagerData *managerData;

@property (readonly) NSMutableArray *elements;
@property (nonatomic) UIImage *loadedImage;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self loadDataFromResource];
}

- (void)loadDataFromResource
{
    _elements = [[NSMutableArray alloc] init];
    
    NSString *pathString = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *elementsData = [NSData dataWithContentsOfFile:pathString];
    
    NSError *anError = nil;
    NSArray *parsedElements = [NSJSONSerialization JSONObjectWithData:elementsData
                                                              options:NSJSONReadingAllowFragments
                                                                error:&anError];
    
    for (NSDictionary *aModuleDict in parsedElements){
        ManagerData *aMosaicModule = [[ManagerData alloc] initWithDictionary:aModuleDict];
        [_elements addObject:aMosaicModule];
    }
    
    NSLog(@"count of elements = %lu", (unsigned long)_elements.count);

}

- (NSMutableArray *)cellSizes {
    if (!_cellSizes) {
        _cellSizes = [NSMutableArray array];
        for (NSInteger i = 0; i < _elements.count; i++) {
            CGSize size = CGSizeMake(arc4random() % 50 + 50, arc4random() % 50 + 50 );
            _cellSizes[i] = [NSValue valueWithCGSize:size];
        }
    }
    return _cellSizes;
}

#pragma mark - Life Cycle

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
    CHTCollectionViewWaterfallLayout *layout =
    (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _elements.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell =
    (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];    
    
    ManagerData *managerData = [_elements objectAtIndex:indexPath.row];
    
    __weak CollectionViewCell *weakCell = cell;
    
    NSURL *anURL = [NSURL URLWithString:managerData.imageFilename];
    NSURLRequest *anURLRequest = [NSURLRequest requestWithURL:anURL];
    
    [cell.imageView setImageWithURLRequest: anURLRequest placeholderImage:nil
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakCell.imageView.image = image;
     }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         NSLog(@"Err %@", [error localizedDescription]);
     }];
    
    
    
    return cell;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizes[indexPath.item] CGSizeValue];
}



@end
