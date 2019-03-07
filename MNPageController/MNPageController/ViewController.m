//
//  ViewController.m
//  MNPageController
//
//  Created by TB-Mac-107 on 2019/2/13.
//  Copyright © 2019年 TB-Mac-107. All rights reserved.
//

#import "ViewController.h"
#import "DemoController/Demo0ViewController.h"
#import "Masonry.h"
#import "MNPageScrollView.h"

#import "JXCategoryView.h"

//屏幕宽高
#define ScreenH  [[UIScreen mainScreen] bounds].size.height
#define ScreenW  [[UIScreen mainScreen] bounds].size.width

#define kBaseHeaderHeight  kScreenW * 385.0f / 704.0f
#define kBaseSegmentHeight 60.0f

#define IS_iPhoneX  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?\
(\
CGSizeEqualToSize(CGSizeMake(375, 812),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(812, 375),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(414, 896),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(896, 414),[UIScreen mainScreen].bounds.size))\
:\
NO)

//  适配比例
#define ADAPTATIONRATIO     ScreenW / 750.0f

#define kNavBarHeight       (IS_iPhoneX ? 88.0f : 64.0f)

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,MNPageScrollViewDelegate>

//
//@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, strong) UIScrollView          *contentScrollView;
@property (nonatomic, strong) NSArray           *childVCs;

@property (nonatomic, strong)UIView *headerView;

// 核心 - pageScrollView
@property (nonatomic, strong) MNPageScrollView  *pageScrollView;

// 当前的内容
@property (nonatomic, strong) UIView                *pageView;;

@property (nonatomic, strong) JXCategoryTitleView   *segmentView;

@end

@implementation ViewController

static CGFloat headerViewH = 300;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.pageScrollView.backgroundColor = [UIColor blueColor];
    
    self.pageScrollView.allowListRefresh = YES;
    
    // 列表添加下拉刷新
//    [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *listVC, NSUInteger idx, BOOL * _Nonnull stop) {
////        [listVC addHeaderRefresh];
//    }];
    
    /*
     当translucent = YES，controller中self.view的原点是从导航栏左上角开始计算
     当translucent = NO，controller中self.view的原点是从导航栏左下角开始计算
     */
    self.navigationController.navigationBar.translucent = NO;
}



- (UIView *)headerView{
    if (!_headerView) {
        
        UIView *headerView = [UIView new];
        headerView.frame = CGRectMake(0, 0, ScreenW, headerViewH);
        headerView.backgroundColor = [UIColor orangeColor];
        _headerView = headerView;
    }
    return _headerView;
}


#pragma mark - MNPageScrollViewDelegate
- (UIView *)tableHeaderViewInPageScrollView:(MNPageScrollView *)pageScrollView{
    
    //每个单独的tableView - headerView 都从这里取 - 保证是同一个 headerView
    return self.headerView;
}

- (UIView *)pageViewInPageScrollView:(MNPageScrollView *)pageScrollView{
    
    //最终要展示在界面内的pageView - 包含 menuView的部分
    return self.pageView;
}

- (NSArray *)listViewsInPageScrollView:(MNPageScrollView *)pageScrollView{
    return self.childVCs;
}

- (NSUInteger)tableHeaderViewHeightInPagerView:(MNPageScrollView *)pagerView{
    return headerViewH;
}

#pragma mark - lazy
- (MNPageScrollView *)pageScrollView{
    if (!_pageScrollView) {
        
        _pageScrollView = [[MNPageScrollView alloc]initWithDelegate:self];
    }
    return _pageScrollView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        
//        [_pageView addSubview:self.segmentView];
        
        [_pageView addSubview:self.contentScrollView];
        _pageView.backgroundColor = [UIColor grayColor];
    }
    return _pageView;
}


- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        CGFloat scrollW = ScreenW;

        //整个屏幕的scrollView - 除了悬浮的menuView
        CGFloat scrollH = ScreenH - kBaseSegmentHeight - kNavBarHeight;

        //最早自定义切换的tableVIew - 只是之前是 headerView是同一个，scrollView 只包含 底下切换的 tableView，现在的 scrollContentView 是整个屏幕 ==>（其实真正滚动的 只有 heaerView 以下的 内容cell ）
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kBaseSegmentHeight, scrollW, scrollH)];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        
        [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:vc];
            [self->_contentScrollView addSubview:vc.view];
            
            vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
        }];
        _contentScrollView.contentSize = CGSizeMake(scrollW * self.childVCs.count, 0);
    }
    return _contentScrollView;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        Demo0ViewController *vc0= [Demo0ViewController new];
        
        Demo0ViewController *vc1= [Demo0ViewController new];
        
        Demo0ViewController *vc2 = [Demo0ViewController new];
        
        _childVCs = @[vc0, vc1, vc2];
    }
    return _childVCs;
}


#pragma mark - UIScrollViewDelegate - 保证只有单方向scrollView滚动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

@end
