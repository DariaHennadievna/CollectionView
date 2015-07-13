//
//  CollectionViewLayout.m
//  CollectionView
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CollectionViewLayout.h"
#import "tgmath.h"

NSString *const CollectionElementKindSectionHeader = @"CollectionElementKindSectionHeader";
NSString *const CollectionElementKindSectionFooter = @"CollectionElementKindSectionFooter";


@interface CollectionViewLayout ()

/// делегат
@property (nonatomic, weak) id <CollectionViewDelegateLayout> delegate;
/// массив хранит высоту для каждой колонки
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Каждый массив хранит массив с item attributes для каждой секции
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// массив хранит атрибуты для всех items включая headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// словарь хранит headers' attribute для секции
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
/// словарь хранит footers' attribute для секции
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
/// массив для хранения rectangles
/// сюда сохраняются rectangles для всех элементов
@property (nonatomic, strong) NSMutableArray *unionRects;

@end

@implementation CollectionViewLayout

/// столько элементов должно быть объединено в оном прямоугольнике
static const NSInteger unionSize = 20;

// возвращает новые значения для ширины и высоты в зависимости от разрешения экрана
static CGFloat FloorCGFloat(CGFloat value)
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

- (NSInteger)columnCountForSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:columnCountForSection:)])
    {
        // если в методе делегата переопределено значение возвращаем это
        return [self.delegate collectionView:self.collectionView layout:self columnCountForSection:section];
    }
    else
    {
        // если нет, используем значение по умолчанию (column count = 2)
        return self.columnCount;
    }
}

// возвращает ширину
- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets sectionInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
    {
        sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    else
    {
        // используем значения отступов по умолчанию
        sectionInset = self.sectionInset;
    }
    // получаем ширину за вычетом отступов, которые = 0 у меня
    CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
    // получаем количетво колонок
    NSInteger columnCount = [self columnCountForSection:section];
    
    // значение отступа между колонками по умолчанию
    CGFloat columnSpacing = self.minimumColumnSpacing;
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumColumnSpacingForSectionAtIndex:)])
    {
        // если задано новое значение будем еспользовать его
        columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumColumnSpacingForSectionAtIndex:section];
    }
    // возвращает значение ширины ячейки с учетом всех отступов
    // value = width - (2 - 1) * columnSpacing) / 2
    return FloorCGFloat((width - (columnCount - 1) * columnSpacing) / columnCount);
}

#pragma mark - Private Accessors
- (NSMutableDictionary *)headersAttribute {
    if (!_headersAttribute) {
        _headersAttribute = [NSMutableDictionary dictionary];
    }
    return _headersAttribute;
}

- (NSMutableDictionary *)footersAttribute {
    if (!_footersAttribute) {
        _footersAttribute = [NSMutableDictionary dictionary];
    }
    return _footersAttribute;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (NSMutableArray *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

- (id <CollectionViewDelegateLayout> )delegate {
    return (id <CollectionViewDelegateLayout> )self.collectionView.delegate;
}

#pragma mark - Init

// значения по умолчанию задаем
- (void)commonInit
{
    _columnCount = 2;
    _minimumColumnSpacing = 5;
    _minimumInteritemSpacing = 5;
    _headerHeight = 0;
    _footerHeight = 0;
    _sectionInset = UIEdgeInsetsMake(20, 0, 0, 0);
    _headerInset  = UIEdgeInsetsZero;
    _footerInset  = UIEdgeInsetsZero;
    _itemRenderDirection = CollectionViewLayoutItemRenderDirectionShortestFirst;
}

- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - CollectionViewLayout Methods to Override

- (void)prepareLayout {
    [super prepareLayout];
    
    // очищаем массивы
    [self.headersAttribute removeAllObjects];
    [self.footersAttribute removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.columnHeights removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    
    // получаем количество секций
    // у меня количество секций = 1
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0)
    {
        return;
    }
    
    // ~~~~~~ Вычисление всех необходимых значений ~~~~~~~~
 
    NSInteger idx = 0;
    
    for (NSInteger section = 0; section < numberOfSections; section++)
    {
        // получаем количество колонок в секции
        NSInteger columnCount = [self columnCountForSection:section];
        NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:columnCount];
        for (idx = 0; idx < columnCount; idx++)
        {
            [sectionColumnHeights addObject:@(0)];
        }
        // изначально высота колонок = 0
        // двумерный массив self.columnHeights[section][columnIndex]...
        [self.columnHeights addObject:sectionColumnHeights];
    }
    
    
    
    // создаем атрибуты
    CGFloat top = 0;
    
    UICollectionViewLayoutAttributes *attributes;
    
    for (NSInteger section = 0; section < numberOfSections; ++section)
    {
        
        // получаем значения
        // minimumInterItemSpacing - между элементами в колонке
        // sectionInset - для указанной секции
        
        // 1 minimumInteritemSpacing
        CGFloat minimumInteritemSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)])
        {
            // если значение было переопределено в классе делегата возвращаем его
            minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
        }
        else
        {
            // иначе возвращаем значение по умолчанию
            // я не переопределяю это значение.
            // по умолчанию = 5.0f
            minimumInteritemSpacing = self.minimumInteritemSpacing;
        }
        
        // 2 columnSpacing
        // также находим пространство между колоночками
        // по умолчанию = 5
        CGFloat columnSpacing = self.minimumColumnSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumColumnSpacingForSectionAtIndex:)])
        {
            // если значение было переопределено, заменяем текущее на новое
            // я использую значение по умолчанию
            columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumColumnSpacingForSectionAtIndex:section];
        }
        
        // 3 sectionInset
        // находим отступы для указанной секции
        // по умолчанию:
        //   отступ сверху = 20
        //   отступ снизу  = 0
        //   отступ справа = 0
        //   отступ слева  = 0
        UIEdgeInsets sectionInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
        {
            // если значение было переопределено в классе делегата возвращаем его
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        else
        {
            // я использую значение по умолчанию
            sectionInset = self.sectionInset;
        }
        
        // находим ширину. она ровна ширине collectionView за вычетом отступов справа и слева
        // width = 375
        CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
        //NSLog(@"width = %f", width);
        
        // получаем количество колонок для секции
        // у меня это значение = 2
        NSInteger columnCount = [self columnCountForSection:section];
        
         // 4 itemWidth
        
        // находим ширину для элемента
        // по формуле floor(value * scale) / scale
        // вычтем из полученной ширины width пространство между колонками
        // колонок 2 штуки, значит пространство = columnSpacing * 1
        // value = (375 - (2-1)*5)/ 2 = 185
        // scale = 2.0 - Retina display, значит, что одна точка представлена четырьмя пикселями
        // itemWidth = floor(value * scale) / scale = (185 * 2)/2 = 185
        
        // itemWidth = 185.0f
        CGFloat itemWidth = FloorCGFloat((width - (columnCount - 1) * columnSpacing) / columnCount);
       // NSLog(@"itemWidth = %f", itemWidth);
        
        
        // определим высоту header для секции
        // 5 headerHeight
        CGFloat headerHeight;
        // по умолчанию = 0
        // хидера у меня нету
        headerHeight = self.headerHeight;
        
        // поскольку хидера у меня нет, то и отступы у меня все 0
        UIEdgeInsets headerInset;
        headerInset = self.headerInset;
        
        // выше определено top = 0
        // новое значение top тоже будет = 0, так как headerInset.top = 0        
        top += headerInset.top;        
        
        // выше определено top = 0
        // новое значение top тоже будет = 0, так как sectionInset.top = 20
        top += sectionInset.top;
        
        for (idx = 0; idx < columnCount; idx++)
        {
            // в наш массив со значениями высоты в каждой колонке добавляем получившееся значение top = 0
            self.columnHeights[section][idx] = @(top);
        }
        
        
        // определим отступы для секции - Section items
        
        // найдем количество элементов в секции
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        // создадим переменныю типа указатель на изменяемый массив
        // в ней будем хданить массивы атрибутов для каждого элемента в секции
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        
        // элементы будут добавляться в колонку, которая имеет наименьшую высоту
        
        // реализуем цикл по всем элементам в секции
        for (idx = 0; idx < itemCount; idx++)
        {
            // получаем indexPath для текущего элемента в секции
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            
            // узнаем в какую колонку будем размещать элемент
            // для этого находим индекс колонки (колонка с наименьшей высотой)
            NSUInteger columnIndex = [self nextColumnIndexForItem:idx inSection:section];
            
            // находим X-координату верхнего левого угла элемента (ячейки)
            // учтем все отступы и умножим на текущий индекс колонки
            CGFloat xOffset = sectionInset.left + (itemWidth + columnSpacing) * columnIndex;
            
            // находим Y-координату верхнего левого угла элемента (ячейки)
            // для этого получаем значение высоты соответствующей колнки
            CGFloat yOffset = [self.columnHeights[section][columnIndex] floatValue];
            
            // получаем размер ячейки по умолчанию...(размеры задавались рандомно в методе ViewController)
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            CGFloat itemHeight = 0;
            if (itemSize.height > 0 && itemSize.width > 0)
            {
                
                // преобразуем высоту ячейки для нашего вида.
                // все по той же формуле floor(value * scale) / scale
                // найдем сразу value
                // value = itemSize.height * 185 / itemSize.width
                itemHeight = FloorCGFloat(itemSize.height * itemWidth / itemSize.width);
                
                // itemHeight для каждого элемента будет разная
                
            }
            // получаем атрибуты для для каждой ячейки
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            // задаем новые, нами рассчитанные чуть ранее
            attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
            
            // добавляем в массив атрибуты для каждого элемента (ячейки)
            [itemAttributes addObject:attributes];
            
            // добавляем этот массив, в другой массив, в котором хранятся все атрибуты для всех элементов (headers, footers and cells)
            [self.allItemAttributes addObject:attributes];
            
            // добавим новую высоту для колонки
            // получим максимальный Y у фрейма текущей ячейки и прибавим пространство между ячейками
            // оно у меня = 5
            self.columnHeights[section][columnIndex] = @(CGRectGetMaxY(attributes.frame) + minimumInteritemSpacing);
        }
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
        //  Section footer
        
        // высота для footer
        // по умолчанию = 0
        // в моем примере изменяться не будет
        CGFloat footerHeight;
        footerHeight = self.footerHeight;
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        top = [self.columnHeights[section][columnIndex] floatValue] - minimumInteritemSpacing + sectionInset.bottom;

        
        // отступы для footer
        // по умолчанию все отступы = 0
        // в моем примере изменяться не будут
        UIEdgeInsets footerInset;
        footerInset = self.footerInset;
        
        top += footerInset.top;

        
        // добавим в массив новую высоту для каждой колонки
        for (idx = 0; idx < columnCount; idx++)
        {
            self.columnHeights[section][idx] = @(top);
        }
        
    } // end of for (NSInteger section = 0; section < numberOfSections; ++section)
    
    
    
    // построим прямоугольник и учтем все атрибуты
    idx = 0;
    // количество атрибутов для всех элементов
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts)
    {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++)
        {
            // получаем значение фрейма для каждого элемента из его атрибутов
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        // добавляем фрейм каждого элемента в массив _unionRects
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
    
}

- (CGSize)collectionViewContentSize
{
    // определим размер контента
    
    // получим количество секций
    // у меня оно = 1
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0)
    {
        return CGSizeZero;
    }
    
    // размер контента получим
    CGSize contentSize = self.collectionView.bounds.size;
    
    // высота контента будет равена высоте колонки
    contentSize.height = [[[self.columnHeights lastObject] firstObject] floatValue];    
    
    if (contentSize.height < self.minimumContentHeight)
    {
        // если высота контента получилась меньшей  чем минимальное значение
        contentSize.height = self.minimumContentHeight;
    }
    
    // возвращаем размерчик
    return contentSize;
}



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    if (path.section >= [self.sectionItemAttributes count])
    {
        return nil;
    }
    if (path.item >= [self.sectionItemAttributes[path.section] count])
    {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // будем определять что показывать в текущем прямоугольнике rect
    NSInteger i;
    NSInteger begin = 0;
    NSInteger end = self.unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    // просматриваем фреймы для каждого элемента, если они пересекаются с данной областью (rect), — добавляем в массив attrs и возвращаем
    
    for (i = 0; i < self.unionRects.count; i++)
    {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue]))
        {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--)
    {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue]))
        {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++)
    {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame))
        {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds))
    {
        // возвращает YES, если новый newBounds не совпадает с текущими границами
        return YES;
    }
    return NO;
}



// метод возвращает атрибуты для дополнительных view (header, footer)
// я не использую этот метод,  так как у меня нет header, footer
// и я не прдполагаю, что мне понадобятся header, footer
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:CollectionElementKindSectionHeader])
    {
        attribute = self.headersAttribute[@(indexPath.section)];
    }
    else if ([kind isEqualToString:CollectionElementKindSectionFooter])
    {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    return attribute;
}



#pragma mark - Private Methods


// возвращает индекс самой короткой колонки
- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section
{
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    // проверяем значения высоты для каждой колонки
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
        // полученное значение высоты
        CGFloat height = [obj floatValue];
        if (height < shortestHeight)
        {
            // если для какой-то колонки оно меньшее
            // сохраняем его для следующей проверки
            shortestHeight = height;
            // сохраняем индекс этой колонки
            index = idx;
        }
    }];
    
    // и возвращаем этот индекс
    return index;
}


// возвращает индекс самой длинной колонки
- (NSUInteger)longestColumnIndexInSection:(NSInteger)section
{
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
        // полученное значение высоты
        CGFloat height = [obj floatValue];
        if (height > longestHeight)
        {
            // находим большее значение
            // сохраняем его для следующей проверки
            longestHeight = height;
            // сохраняем индекс этой колонки
            index = idx;
        }
    }];
    
    // возвращаем то что получилось
    return index;
}


// решаем как куда будем размещать элементы
// возвращает индекс для следующей колонки
- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section
{
    // сразу интекс колонки = 0
    NSUInteger index = 0;
    // еще раз находим какое у нас количество колонок
    NSInteger columnCount = [self columnCountForSection:section];
    
    // есть 3 варианта...
    switch (self.itemRenderDirection)
    {
        // если хотим размещать в той колонке, которая имеет наименьшую высоту
        case CollectionViewLayoutItemRenderDirectionShortestFirst:
            index = [self shortestColumnIndexInSection:section];
            break;
            
        // если хотим размещать слева направо
        case CollectionViewLayoutItemRenderDirectionLeftToRight:
            index = (item % columnCount);
            break;
        
        // если хотим размещать справа налево
        case CollectionViewLayoutItemRenderDirectionRightToLeft:
            index = (columnCount - 1) - (item % columnCount);
            break;
            
        default:
            // по умолчанию размещаем в колонке, которая имеет наименьшую высоту
            index = [self shortestColumnIndexInSection:section];
            break;
    }
    return index;
}


@end
