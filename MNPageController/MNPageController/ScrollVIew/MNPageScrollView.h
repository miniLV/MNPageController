//
//  MNPageScrollView.h
//  MNPageController
//
//  Created by TB-Mac-107 on 2019/2/13.
//  Copyright © 2019年 TB-Mac-107. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MNPageScrollView;



@protocol MNPageScrollViewDelegate <NSObject>

///返回pageScrollView 的 headerView
- (UIView *)tableHeaderViewInPageScrollView:(MNPageScrollView *)pageScrollView;

///返回分页视图
- (UIView *)pageViewInPageScrollView:(MNPageScrollView *)pageScrollView;

///返回当前的listView
- (NSArray*)listViewsInPageScrollView:(MNPageScrollView *)pageScrollView;
//- (NSArray <id <MNPageScrollView>> *)listViewsInPageScrollView:(MNPageScrollView *)pageScrollView;

- (NSUInteger)tableHeaderViewHeightInPagerView:(MNPageScrollView *)pagerView;

@optional

/**
 mainTableView滑动，用于实现导航栏渐变、头图缩放等
 
 @param scrollView mainTableView
 @param isMainCanScroll 是否到达临界点，YES表示到达临界点，mainTableView不再滑动，NO表示我到达临界点，mainTableView仍可滑动
 */
- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll;


@end

@interface MNPageScrollView : UIScrollView

@property (nonatomic, weak) id<MNPageScrollViewDelegate> delegate;

// 是否允许子列表下拉刷新
@property (nonatomic, assign, getter=isAllowListRefresh) BOOL allowListRefresh;

// 初始化并设置代理
- (instancetype)initWithDelegate:(id<MNPageScrollViewDelegate>)delegate;

// 处理左右滑动与上下滑动的冲突
- (void)horizonScrollViewWillBeginScroll;
- (void)horizonScrollViewDidEndedScroll;

@end

NS_ASSUME_NONNULL_END
