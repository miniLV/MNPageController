//
//  Demo0ViewController.m
//  MNPageController
//
//  Created by TB-Mac-107 on 2019/2/13.
//  Copyright © 2019年 TB-Mac-107. All rights reserved.
//

#import "Demo0ViewController.h"
#import "Masonry.h"

typedef void(^MNListViewScrollBlock)(UIScrollView *scrollView);

@interface Demo0ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, copy) MNListViewScrollBlock listViewScrollBlock;

@property (nonatomic, strong) UITableView   *tableView;

@end

@implementation Demo0ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.tableView.backgroundColor = [UIColor redColor];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.listViewScrollBlock = callback;
}

#pragma mark - <UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [UITableViewCell new];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"test --- %ld",(long)indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}

#pragma mark - MNPageListViewDelegate
- (UIScrollView *)listScrollView {
    //返回给mainTableView的cell显示的内容，一般是tableView
    return self.tableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.listViewScrollBlock) {
        self.listViewScrollBlock(scrollView);
    }
}
@end
