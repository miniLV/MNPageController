//
//  MNPageListViewProtocol.h
//  MNPageController
//
//  Created by TB-Mac-107 on 2019/2/13.
//  Copyright © 2019年 TB-Mac-107. All rights reserved.
//

#ifndef MNPageListViewProtocol_h
#define MNPageListViewProtocol_h


@protocol MNPageListViewDelegate <NSObject>

//@required
@optional
/**
 返回VC内部持有的scrollView(场景是tableView)
 */
- (UIScrollView *)listScrollView;

/**
 当listView所持有的UIScrollView或UITableView或UICollectionView的代理方法`scrollViewDidScroll`回调时，
 需要调用该代理方法传入callback
 
 @param callback `scrollViewDidScroll`回调时调用的callback
 */
- (void)listViewDidScrollCallback:(void (^)(UIScrollView *scrollView))callback;

@end

#endif /* MNPageListViewProtocol_h */
