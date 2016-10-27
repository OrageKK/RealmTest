//
//  ViewController.m
//  RealmTest
//
//  Created by 黄坤 on 16/10/26.
//  Copyright © 2016年 oragekk. All rights reserved.
//
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#import "ViewController.h"
#import <Realm/Realm.h>
#import "Student.h"
#import "Masonry.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) RLMRealm *realm;
@property (strong, nonatomic) RLMResults<Student *> *allStudents;
@property (nonatomic,strong) UITextField *nameTF;
@property (nonatomic,strong) UITextField *ageTF;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    self.title = @"RealmTest";
    
    [self setupUI];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
        
    [self creatdataBase];
    _allStudents = [Student allObjectsInRealm:_realm];
    
    

    
    
    
}

#pragma mark - 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (nil == _allStudents) {
        return 0;
    }
    return [_allStudents count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (_allStudents.count < indexPath.row+1) {
        [[cell textLabel] setText:@"NONE"];
        return cell;
    }
    
    Student *s = [_allStudents objectAtIndex:indexPath.row];
    [[cell textLabel] setText:s.name];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%ld",s.age]];
    return cell;
}
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - 增
- (void)add:(id)sender {
    if (_nameTF.text.length ==0 || _ageTF.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty"
                                                        message:@"Name or Age is empty!"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        return ;
    }
    Student *s= [Student new];
    s.name = _nameTF.text;
    s.age = [_ageTF.text intValue];
    
    [_realm beginWriteTransaction];
    [_realm addObject:s];
    [_realm commitWriteTransaction];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucess"
                                                    message:@"Add Sucess!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    _allStudents = [Student allObjectsInRealm:_realm];
    _nameTF.text = @"";
    _ageTF.text = @"";
    [self.tableView reloadData];
}
#pragma mark - 删
- (void)delete:(id)sender {
//    [_realm beginWriteTransaction];
//    // 删除单条记录
////    [_realm deleteObject:Car];
//    // 删除多条记录
////    [_realm deleteObjects:CarResult];
//    // 删除所有记录
//    [_realm deleteAllObjects];
//    
//    [_realm commitWriteTransaction];
//    [self.tableView reloadData];
}

#pragma mark - 查
- (void)query:(id)sender {
    if(_nameTF.text.length == 0 && _ageTF.text.length == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"缺少关键字"
                                                        message:@"进行全部结果查询"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        _allStudents = [Student allObjectsInRealm:_realm];
        [self.tableView reloadData];
        return;
    }
    
    if (_ageTF.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"年龄为空"
                                                        message:@"将进行姓名查询"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"name = %@",_nameTF.text];
        _allStudents = [Student objectsInRealm:_realm withPredicate:filter];

    }else if (_nameTF.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"姓名为空"
                                                        message:@"将进行年龄大于查询"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"age > %d", [_ageTF.text intValue ]];
        _allStudents = [Student objectsInRealm:_realm withPredicate:filter];

    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"精确查询"
                                                        message:@"将进行精确查询"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"name = %@ AND age = %d",_nameTF.text,[_ageTF.text intValue]];
        _allStudents = [Student objectsInRealm:_realm withPredicate:filter];
        [self.tableView reloadData];
        if (_allStudents.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty"
                                                            message:@"Filter Age is empty!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Return"
                                                  otherButtonTitles:nil];
            [alert show];
            return ;
        }
    }
    
    
    [self.tableView reloadData];
    

}
#pragma mark -创建数据库
- (void)creatdataBase {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent:@"crud"]
                      URLByAppendingPathExtension:@"realm"];
    NSLog(@"Realm file path: %@", config.fileURL);
    NSError *error;
    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
    _realm = realm;
}

- (void)setupUI {
//    //标签
//    UILabel *result = [[UILabel alloc] init];
//    result.numberOfLines = 0;
//    result.backgroundColor = [UIColor whiteColor];
//    
//    [self.tableView.tableHeaderView addSubview:result];
//    [result mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.tableView.tableHeaderView.mas_left).offset(30);
//        make.right.equalTo(self.tableView.tableHeaderView.mas_right).offset(-30);
//        make.top.equalTo(self.tableView.tableHeaderView.mas_top).offset(220);
//        make.height.equalTo(@40);
//    }];
    
    //输入
    UITextField *textName = [[UITextField alloc] init];
    textName.backgroundColor = [UIColor whiteColor];
    textName.placeholder = @"姓名";
    UITextField *textAge = [[UITextField alloc] init];
    textAge.backgroundColor = [UIColor whiteColor];
    textAge.placeholder = @"年龄";
    [self.tableView.tableHeaderView addSubview:textName];
    [self.tableView.tableHeaderView addSubview:textAge];
    _nameTF = textName;
    _ageTF = textAge;
    [textName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tableView.tableHeaderView.mas_left).offset(30);
        make.right.equalTo(self.tableView.tableHeaderView.mas_right).offset(-100);
        make.top.equalTo(self.tableView.tableHeaderView.mas_top).offset(30);
        make.height.equalTo(@30);
    }];
    
    [textAge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tableView.tableHeaderView.mas_left).offset(30);
        make.right.equalTo(textName);
        make.top.equalTo(textName.mas_bottom).offset(30);
        make.height.equalTo(@30);
    }];
    //增加
    UIButton *addBtn = [self creatBtn:@"Add" andBtnColor:[UIColor orangeColor]];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textName.mas_right).offset(10);
        make.right.equalTo(self.tableView.tableHeaderView.mas_right).offset(-10);
        make.top.equalTo(textName);
        make.bottom.equalTo(textAge);
    }];
    [addBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    //查询
    UIButton *quere = [self creatBtn:@"Quere" andBtnColor:[UIColor orangeColor]];
    [quere mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textAge.mas_left).offset(-5);
        make.top.equalTo(textAge.mas_bottom).offset(20);
        make.width.equalTo(@100);
        make.bottom.equalTo(self.tableView.tableHeaderView.mas_bottom).offset(-10);
    }];
    [quere addTarget:self action:@selector(query:) forControlEvents:UIControlEventTouchUpInside];
    //更改
    UIButton *updateBtn = [self creatBtn:@"Update" andBtnColor:[UIColor orangeColor]];
    [updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(quere.mas_right).offset(20);
        make.top.bottom.width.equalTo(quere);
    }];
    
    // 删除
    UIButton *deleBtn = [self creatBtn:@"Delete" andBtnColor:[UIColor orangeColor]];
    [deleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(updateBtn.mas_right).offset(20);
        make.top.bottom.width.equalTo(quere);
    }];
    [deleBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 创建按钮工厂
- (UIButton *)creatBtn:(NSString *)btnName andBtnColor:(UIColor *)color {
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:btnName forState:UIControlStateNormal];
    btn.backgroundColor = color;
    [self.tableView.tableHeaderView addSubview:btn];
    
    return btn;
}

@end
