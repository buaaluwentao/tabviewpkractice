//
//  AddressListViewController.m
//  TableViewPractice
//
//  Created by luwentao on 2018/8/9.
//  Copyright © 2018年 cmb. All rights reserved.
//
/*
 以组的方式生成好友列表
 允许添加、删除、编辑好友列表
 允许点击查看好友详细信息
 允许通过搜索栏进行搜索
 */
#import "AddressListTableViewController.h"

@interface AddressListTableViewController ()<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UISearchResultsUpdating>

@property (nonatomic,strong )UITableView * userInfo;
@property (nonatomic,strong )NSArray * friendsGroupList;
@property (nonatomic,strong) NSDictionary * friendsList;
@property (nonatomic,strong) UISearchController * searchController;
//b@property (nonatomic,strong) NSArray * filter
@end

@implementation AddressListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad ...d");
    // Do any additional setup after loading the view.
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * friendsListPath = [bundle pathForResource:@"friendsList" ofType:@"plist"];
    NSDictionary * frinedsListInfo = [[NSDictionary alloc]initWithContentsOfFile:friendsListPath];
    self.friendsList = frinedsListInfo ;
    NSArray* tempKeys = [self.friendsList allKeys];
    self.friendsGroupList = [tempKeys sortedArrayUsingSelector:@selector(compare:)];
    //self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] ;


    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeigth = [UIScreen mainScreen].bounds.size.height;
    UITableView *userInfo = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+40, screenWidth, screenHeigth-64-40) style:UITableViewStyleGrouped] ;
    userInfo.delegate = self;
    userInfo.dataSource = self;
    self.userInfo = userInfo;
    [self.view addSubview:userInfo];
    
    //UISearchController *searchBar = [[UISearchController alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
    [self filterContentForSearchText:@"" scope:-1];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.scopeButtonTitles = @[@"中文",@"英文" ];
    self.searchController.searchBar.delegate = self;
    self.userInfo.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    //self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+40, screenWidth, screenHeigth-64-40) style:UITableViewStyleGrouped] ;
//    self.tableView.frame = CGRectMake(0, 104, screenWidth, screenHeigth);
    
    //self.view = [UITableView alloc] initWith;
    NSLog(@"HELLO");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*要实现分节，需要实现UITableViewDataSource协议中的tableview:numberofRowsInSection:方法*/
/*同时实现tableview:cellForRowAtIndexPath*/

#pragma mark -- UITableViewDataSource  协议
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.friendsList count];
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * groupName = self.friendsGroupList[section];
    return groupName;
}
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    NSString * sectionName = self.friendsGroupList[section];
    //NSLog(@"好");
    return [self.friendsList[sectionName] count];
    //return 1;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSString * cellIndentifier = @"CellIdentifier";
    [self.userInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIndentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    cell.textLabel.text = self.friendsList[self.friendsGroupList[section]][row];
    //NSLog(@"好的");
    return cell;
    
}

- (NSArray*) sectionIndexTitlesForTableView:(UITableView *) tableview{
    NSMutableArray * listTitles = [[NSMutableArray alloc] init];
    for(NSString * title in self.friendsList){
        [listTitles addObject: [title substringToIndex:1]];
    }
    //NSLog(@"好的");
    return listTitles;
}


/*
 删除 单元格
 
 */
/*
- (void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:<#editing#> animated:<#animated#>];
    [self.tableView setEditing:editing animated: TRUE];
    if(editing){
        //self
        
    }
}*/
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // []
    return UITableViewCellEditingStyleDelete;
    /*if (indexPath.row != [self.friendsGroupList[[indexPath section]] count]  - 1){
        //允许删除
        
    }*/
}

- (void) tableView:(UITableView*) tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.userInfo deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSInteger row = [indexPath row];
        NSInteger section = [indexPath section];
        [self.friendsList[self.friendsGroupList[section]] removeObjectAtIndex:row];
    }
}

-(void) filterContentForSearchText:(NSString*)searchText scope:(NSUInteger) scope{
    if([searchText length] == 0){
        return;
    }
    
    NSMutableArray *friends = nil;
    for(NSArray* key in [self.friendsList allKeys]){
        for(NSString * value in self.friendsList[key]){
            [friends addObject:value];
        }
    }
    //NSPredicate *scopePridicate;
    NSMutableArray *tempArray = nil;
    //构建新的分组
    switch(scope) {
        case -1:
            break;
        default:
            //[NSPredicate predicateWithFormat:@"SELF.name contains[c]%@" ,searchText];
            for(NSString *friend in friends){
                NSLog(@"searchText=%@" ,friend);
                //NSString *temp= [friend stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                //NSString *temp = [friend stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if([friend rangeOfString:searchText].location != NSNotFound){
                    [tempArray addObject:friend];
                }
            }
            break;
        
    }
   
    //return
}
#pragma mark --实现UISearchBarDelegate方法
- (void) searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}
#pragma mark --实现UISearchResultUpdating协议方法
- (void) updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString * searchText = searchController.searchBar.text;
    [self filterContentForSearchText:searchText scope:1];
    NSLog(@"works well ...");
    //x[self.userInfo reloadData];
}
- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}
//-(BOOL )
@end




