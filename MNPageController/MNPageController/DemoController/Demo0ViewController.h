//
//  Demo0ViewController.h
//  MNPageController
//
//  Created by TB-Mac-107 on 2019/2/13.
//  Copyright © 2019年 TB-Mac-107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNPageListViewProtocol.h"
NS_ASSUME_NONNULL_BEGIN

/**
 遵守 - MNPageListViewDelegate，可以监听内部scrollView滚动，并返回当前控制器内部的listView(正常是tableView) 给 mainTableView
 从而设置对应的 哪个scrollView滚动操作
 */
@interface Demo0ViewController : UIViewController<MNPageListViewDelegate>

@end

NS_ASSUME_NONNULL_END
