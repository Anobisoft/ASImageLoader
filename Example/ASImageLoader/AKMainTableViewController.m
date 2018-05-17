//
//  AKMainTableViewController.m
//  ASImageLoader
//
//  Created by Stanislav Pletnev on 24.03.2018.
//  Copyright © 2018 Anobisoft. All rights reserved.
//

#import "AKMainTableViewController.h"
@import ASImageLoader;

@interface AKMainTableViewController ()
@property (nonatomic) NSArray<NSString *> *content;
@end

@implementation AKMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.content = @[
                @"http://www.catster.com/wp-content/uploads/2017/12/A-gray-kitten-meowing.jpg",
                @"http://www.catster.com/wp-content/uploads/2017/09/Two-calico-cats-who-looks-alike.jpg",
                @"http://www.catster.com/wp-content/uploads/2017/12/A-kitten-meowing.jpg",
                @"http://kittenrescue.org/wp-content/uploads/2017/03/KittenRescue_KittenCareHandbook.jpg",
                @"https://static1.squarespace.com/static/54e8ba93e4b07c3f655b452e/t/56c2a04520c64707756f4267/1493764650017",
                @"https://www.pets4homes.co.uk/images/articles/3715/dealing-with-fleas-on-young-kittens-57ec003b91a56.jpg",
                @"https://www.pets4homes.co.uk/images/articles/4051/interesting-things-about-kittens-5901d80a86e4f.jpg",
                @"http://www.saveacat.org/uploads/4/8/4/1/48413975/1454901839.png",
                @"https://static1.squarespace.com/static/54e8ba93e4b07c3f655b452e/t/57cf3d2846c3c4d2933a9d28/1474332420480/DSC_5454.jpg",
                @"https://g.acdn.no/obscura/API/dynamic/r1/ece5/tr_1080_715_l_f/0000/hama/2016/6/30/14/358774040.jpg?chk=4A6A5C"
                ];
    
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.tableView.tableFooterView.backgroundColor = self.tableView.backgroundColor;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];

    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.content.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<ASImagePresenter> *cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
    NSURL *URL = [NSURL URLWithString:self.content[indexPath.row]];
    [[ASImageLoader defaultLoader] imageFetchWithURL:URL forCell:cell inView:tableView atIndexPath:indexPath];
    return cell;
}

@end
