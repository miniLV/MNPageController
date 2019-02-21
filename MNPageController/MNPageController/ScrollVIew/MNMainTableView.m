//
//  MNMainTableView.m
//  MNPageController
//
//  Created by TB-Mac-107 on 2019/2/13.
//  Copyright © 2019年 TB-Mac-107. All rights reserved.
//

#import "MNMainTableView.h"

@implementation MNMainTableView

// 同时多个手势识别 - 嵌套scrollView需要用到
// 如果 vc.list 添加到 mainTableView上，如果只允许单手势，mainTableView的scroll就会被截断 ==> 到vc.list滚动就截止了
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
