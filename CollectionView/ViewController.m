//
//  ViewController.m
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ViewController.h"

#define CELL_IDENTIFIER @"WaterfallCell"

@interface ViewController ()

// размер для ячейки по умолчанию
@property (nonatomic, strong) NSMutableArray *cellSizes;

// все элементы, которые будем отображать в ячейках
@property (nonatomic, strong) NSMutableArray *elements;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    // в массив NSMutableArray *elements помещаю объекты типа ManagerData, которые получаю из                            файла data.json (группа Resources). Это происходит внутри метода loadDataFromResource
    // каждый объект содержит имя запроса для одной картинки
    [self loadDataFromResource];
}

// получим данные
- (void)loadDataFromResource
{
    _elements = [[NSMutableArray alloc] init];
    
    // получаем имя файла с расширением
    NSString *pathString = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    // получаем данные из указанного файла
    NSData *elementsData = [NSData dataWithContentsOfFile:pathString];
    
    NSError *anError = nil;
    // полученные данные преобразуем в массив (JSON формат)
    NSArray *parsedElements = [NSJSONSerialization JSONObjectWithData:elementsData
                                                              options:NSJSONReadingAllowFragments
                                                                error:&anError];
    // для каждого словаря в полученном массиве
    for (NSDictionary *aModuleDict in parsedElements)
    {
        // создаем объект, который хранит в себе имя URL (NSString)
        ManagerData *aMosaicModule = [[ManagerData alloc] initWithDictionary:aModuleDict];
        // добавляем этот объект в массив _elements
        [_elements addObject:aMosaicModule];
    }
}

- (NSMutableArray *)cellSizes
{
    if (!_cellSizes)
    {
        _cellSizes = [NSMutableArray array];
        for (NSInteger i = 0; i < _elements.count; i++)
        {
            // ширина и высота будет принимать зачения от 50 до 99
            CGSize size = CGSizeMake(arc4random() % 50 + 50, arc4random() % 50 + 50 );
            // сохраняем каждое значение в массиве _cellSizes
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation
{
    CollectionViewLayout *layout =
    (CollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    // количество колонов независимо от ориентации будет 2 штуки
    layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 2;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // возвращаем количество элементов, которые получили
    return _elements.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // возвращаем количество секций
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell =
    (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];
    // извлекаем из массива объект для каждого indexPath.row
    ManagerData *managerData = [_elements objectAtIndex:indexPath.row];
    
    __weak CollectionViewCell *weakCell = cell;
    
    // получаем URL
    NSURL *anURL = [NSURL URLWithString:managerData.imageFilename];
    // и URL запрос
    NSURLRequest *anURLRequest = [NSURLRequest requestWithURL:anURL];
    
    // делаем запрос
    [cell.imageView setImageWithURLRequest: anURLRequest placeholderImage:nil
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        // и добавляем то что пришло на cell.imageView
         weakCell.imageView.image = image;
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         NSLog(@"Err: %@", [error localizedDescription]);
     }];
    
    return cell;
}

#pragma mark - CollectionViewDelegateLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellSizes[indexPath.item] CGSizeValue];
}



@end
