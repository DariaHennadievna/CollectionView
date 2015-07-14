//
//  CollectionViewLayout.h
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

// порядок размещения элементов
typedef NS_ENUM (NSUInteger, CollectionViewLayoutItemRenderDirection)
{
    // каждый следующий эдемент устанавливается в ту колонку, которая имеет наименьшую высоту
    // значение по умолчанию
    CollectionViewLayoutItemRenderDirectionShortestFirst,
    // заполнение идет слева на право
    CollectionViewLayoutItemRenderDirectionLeftToRight,
    // заполнение идет справа налево
    CollectionViewLayoutItemRenderDirectionRightToLeft
};


/// идентификатор для дополнительного view Header
extern NSString *const CollectionElementKindSectionHeader;
/// идентификатор для дополнительного view Footer
extern NSString *const CollectionElementKindSectionFooter;

#pragma mark - CollectionViewDelegateLayout

@class CollectionViewLayout;


@protocol CollectionViewDelegateLayout <UICollectionViewDelegate>
@required

// запрашивает делегата размер ячейки для указанного элемента
// метод возвращает размер ячейки
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

// запрашивает количество колонок
// количество колонок должно быть больше нуля
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section;

// возвращает высоту для Header в указанной секции
// по умолчанию = 0
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;

// возвращает высоту для Footer в указанной секции
// по умолчанию = 0
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;

// возвращает отступы для указанной секции
// по умолчанию: Top = 20, Left, Right, Bottom = 0
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

// возвращает Header отступы для указанной секции
// по умолчанию = UIEdgeInsetsZero
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section;

// возвращает Footer отступы для указанной секции
// по умолчанию = UIEdgeInsetsZero
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForFooterInSection:(NSInteger)section;

// возвращает минимальное расстояние между элементами в колонке для указанной секции
// по умолчанию = 5;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;


// возвращает минимальное расстояние между колонками для указанной секции
// по умолчанию = 5;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section;


@end

#pragma mark - CollectionViewLayout


@interface CollectionViewLayout : UICollectionViewLayout

// ~~~~~~~~~~~~свойства для CollectionViewLayout~~~~~~~~~~~~

// количество колонок для этого layout
// по умолчанию = 2
@property (nonatomic, assign) NSInteger columnCount;

// минимальное пространство между колонками
// по умолчанию = 5
@property (nonatomic, assign) CGFloat minimumColumnSpacing;

// минимальное пространство между элементами в колонке
// по умолчанию = 5
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

// высота для header
// по умолчанию = 0
@property (nonatomic, assign) CGFloat headerHeight;

// высота для footer
// по умолчанию =0
@property (nonatomic, assign) CGFloat footerHeight;

// Header отступы для указанной секции
// по умолчанию = UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets headerInset;

// Footer отступы для указанной секции
// по умолчанию = UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets footerInset;

// отступы для указанной секции
// по умолчанию: (Top = 20, Left, Right, Bottom = 0)
@property (nonatomic, assign) UIEdgeInsets sectionInset;

// свойство определяет как будут располагаться элементы
// по умолчанию каждый следующий элемент будет размещаться в той колонке, которая имеет наименьшую высоту
// CollectionViewLayoutItemRenderDirectionShortestFirst
@property (nonatomic, assign) CollectionViewLayoutItemRenderDirection itemRenderDirection;

// минимальное значение высоты контента collection view
// по умолчанию = 0
@property (nonatomic, assign) CGFloat minimumContentHeight;


// возвращает ширину для элемента в выбранной ячейке
// ширина элемента вычисляется на основе количества колонок, ширины collection view и горизонтальных вставок для этой секции
- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section;

@end
