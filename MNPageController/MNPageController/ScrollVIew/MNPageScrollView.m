//
//  MNPageScrollView.m
//  MNPageController
//
//  Created by TB-Mac-107 on 2019/2/13.
//  Copyright © 2019年 TB-Mac-107. All rights reserved.
//

#import "MNPageScrollView.h"
#import "MNMainTableView.h"
#import "MNPageListViewProtocol.h"
//屏幕宽高
#define ScreenH  [[UIScreen mainScreen] bounds].size.height
#define ScreenW  [[UIScreen mainScreen] bounds].size.width

@interface MNPageScrollView()<UITableViewDelegate, UITableViewDataSource, MNPageListViewDelegate>

@property (nonatomic, strong) UITableView *mainTableView;

// 当前滑动的listView
@property (nonatomic, weak) UIScrollView *currentListScrollView;

// 是否滑动到滚动临界点临界点
@property (nonatomic, assign, getter=isCriticalPoint) BOOL criticalPoint;
/**
 可以理解为 - mainTableView 与 listScrollView 滚动互斥
 */
// mainTableView是否可滑动
@property (nonatomic, assign, getter=isMainCanScroll) BOOL mainCanScroll;
// listScrollView是否可滑动
@property (nonatomic, assign, getter=isListCanScroll) BOOL listCanScroll;

@end

@implementation MNPageScrollView


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.mainTableView.frame = self.bounds;
    self.mainTableView.backgroundColor = [UIColor purpleColor];
}

- (instancetype)initWithDelegate:(id<MNPageScrollViewDelegate>)delegate{
    
    if (self = [super init]) {
        
        self.delegate = delegate;
        
        [self p_prepareSubViews];
    }
    return self;
}

#pragma mark - setupUI
- (void)p_prepareSubViews{
    self.criticalPoint = NO;
    self.mainCanScroll = YES;
    self.listCanScroll = NO;
    
    /**
     必须开启多手势 - 不然嵌套的scrollView - 只会响应最上面的scrollView
     */
    self.mainTableView = [[MNMainTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainTableView.showsVerticalScrollIndicator = NO;
    self.mainTableView.showsHorizontalScrollIndicator = NO;
    self.mainTableView.tableHeaderView = [self.delegate tableHeaderViewInPageScrollView:self];
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.mainTableView];
    
    // listScrollview滑动处理
    [self configListViewScroll];
}

#pragma mark - Private Methods
- (void)configListViewScroll {
    
    NSArray *vcList = [self.delegate listViewsInPageScrollView:self];
    
    [vcList enumerateObjectsUsingBlock:^(id<MNPageListViewDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(self) weakSelf = self;
        
        // vc内的scrollView 滚动的时候 - 回调 vc.tableView
        [obj listViewDidScrollCallback:^(UIScrollView * _Nonnull scrollView) {

            [weakSelf listScrollViewDidScroll:scrollView];
        }];
    }];
}

//vc内部的scrollView滚动！ - 有mainTableView 决定
/**
 self.isListCanScroll = YES;
 vc的listView滚动的情况只有2种
 - 往上滚动到临界值 - headerView miss，同时继续往上拉，(vc.listView offsetY 还 < 0)
 - mainTableView在起始的位置（offsetY == 0）且 isAllowListRefresh == YES， 且此时正在做下拉刷新的操作(vc.listView offsetY 还 < 0)
 */
- (void)listScrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.currentListScrollView = scrollView;
    
    // 获取listScrollview偏移量
    CGFloat offsetY = scrollView.contentOffset.y;
    
    // listScrollView下滑至offsetY小于0，禁止其滑动，让mainTableView可下滑
    if (offsetY <= 0) {
        //说明正在往下拉
        // 起始位置 - self.mainTableView设置偏移 headerView 高度！！ - 不然就看不到headerView
        // listView在 mainTableView上，如果mainTableView 偏移量是0，正好 listVIew盖在 mainTableView上，看不到headerView！
        
        if (self.isAllowListRefresh && offsetY < 0 && self.mainTableView.contentOffset.y == 0) {

            //如果允许下拉刷新 && self.mainTableView回到初始位置
            self.mainCanScroll = NO;
            self.listCanScroll = YES;
        }else {
            
            //不能下拉刷新 - 下拉的时候动的是 mainTableView！
            self.mainCanScroll = YES;
            self.listCanScroll = NO;
            
            //vc.listView - 不滚动 - 偏移 = 0(不设置的话)
            scrollView.contentOffset = CGPointZero;
            scrollView.showsVerticalScrollIndicator = NO;
        }
    }else {
        //正在往上拉的时候
        
        if (self.isListCanScroll)
        {
            //轮到vc.listView 滚动了！
            
            scrollView.showsVerticalScrollIndicator = YES;
            
            // 如果此时mianTableView并没有滑动，则禁止listView滑动
            if (self.mainTableView.contentOffset.y == 0) {
                self.mainCanScroll = YES;
                self.listCanScroll = NO;
                
                scrollView.contentOffset = CGPointZero;
                scrollView.showsHorizontalScrollIndicator = NO;
            }else { // 矫正mainTableView的位置
                CGFloat criticalPoint = [self.mainTableView rectForSection:0].origin.y;
                self.mainTableView.contentOffset = CGPointMake(0, criticalPoint);
            }
        }
        else {
            //还是mainTableView滚动，此时 vc.list 修正(不要动) - 此时滚动的是 - mainTableView
            scrollView.contentOffset = CGPointZero;
        }
    }
}

//一开始都是matinTableVIew 滚动，由他决定是不是要到vc.listView滚动
- (void)mainScrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取mainScrollview偏移量
    CGFloat offsetY = scrollView.contentOffset.y;
    
    // 临界点 - headerView高度 - 到临界点之前，滚动的都是mainTableView - headerView 才可以滚动
    CGFloat tableHeaderViewH = [self.delegate tableHeaderViewHeightInPagerView:self];
    CGFloat criticalPoint = tableHeaderViewH;
    
    // 根据偏移量判断是否上滑到临界点
    if (offsetY >= criticalPoint) {
        
        //offsetY - 往上是正的，往上 headerView的高度，正好headerView miss，说明到了临界点了
        self.criticalPoint = YES;
    }else {
        self.criticalPoint = NO;
    }
    
    if (self.isCriticalPoint) {
        // 上滑到临界点后，固定mainTableView位置 - 保证menuView 悬浮
        scrollView.contentOffset = CGPointMake(0, criticalPoint);
        
        //让 vc.listView 滚动
        self.mainCanScroll = NO;
        self.listCanScroll = YES;
        
    }else {
        // 如果允许列表刷新，并且mainTableView的offsetY小于0 或者 当前列表的offsetY小于0
        if (self.isAllowListRefresh && (offsetY <= 0 || self.currentListScrollView.contentOffset.y < 0)) {
            
            //如果可以下拉刷新的话 - 滚动的是 listView，mainTableView 不用动
            scrollView.contentOffset = CGPointZero;
        }else
        {
            if (self.isMainCanScroll) {
                //当前mainTableView滚动，listView就不要滚动
                [self listScrollViewOffsetFixed];
            }else {
                //当前listView滚动，mainTableView就不要滚动
                [self mainScrollViewOffsetFixed];
            }
        }
    }
}

// 修正listScrollView的位置
- (void)listScrollViewOffsetFixed {
    
    //vcList
    NSArray *vcList = [self.delegate listViewsInPageScrollView:self];
    [vcList enumerateObjectsUsingBlock:^(id<MNPageListViewDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //每个vcListView - 都不要滚动 - 偏移量都设置为0
        UIScrollView *listScrollView = [obj listScrollView];
        
        listScrollView.contentOffset = CGPointZero;
        listScrollView.showsVerticalScrollIndicator = NO;
    }];
}

// 修正mainTableView的位置
- (void)mainScrollViewOffsetFixed {
    
    // 获取临界点位置
    CGFloat tableHeaderView = [self.delegate tableHeaderViewHeightInPagerView:self];
    
    //self.mainTableView 默认偏移 - tableHeaderView
    self.mainTableView.contentOffset = CGPointMake(0, tableHeaderView);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self mainScrollViewDidScroll:scrollView];
}


//只有一个cell - cell的内容是当前的 pageView！！
#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //每个实际展示的pageView，实际上是一个cell，cell的大小 = 屏幕大小 ==> pageView 在 cell 里面展示
    UIView *pageView = [self.delegate pageViewInPageScrollView:self];
    pageView.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    [cell.contentView addSubview:pageView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ScreenH;
}

#pragma mark - horizonScrollView
- (void)horizonScrollViewWillBeginScroll {
    self.mainTableView.scrollEnabled = NO;
}

- (void)horizonScrollViewDidEndedScroll {
    self.mainTableView.scrollEnabled = YES;
}


@end
