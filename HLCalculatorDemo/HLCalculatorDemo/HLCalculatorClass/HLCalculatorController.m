//
//  HLCalculatorController.m
//  HLCalculatorDemo
//
//  Created by cainiu on 2019/1/17.
//  Copyright © 2019 HL. All rights reserved.
//

#import "HLCalculatorController.h"
#import "HLCalculatorItemView.h"
#import "HLCalculatorHistoryListCell.h"

// 屏幕的宽度
#define kHLScreenW [UIScreen mainScreen].bounds.size.width
// 屏幕的高度
#define kHLScreenH [UIScreen mainScreen].bounds.size.height
#define kHLColorWith22 kHLHEXCOLORA(0x222222, 1.0)
#define kHLWeakSelf __weak typeof(self) weakSelf = self;


@interface HLCalculatorController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) UIScrollView *resultView;
@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong) HLCalculatorItemView *calculatorView;

/** 最后点击按钮的Tag */
@property (nonatomic, assign) NSInteger lastClickTag;

@property (nonatomic, strong) NSMutableString *showString;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

static NSString *hlCalculatorHistoryListCellId= @"HLCalculatorHistoryListCell";
@implementation HLCalculatorController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableString *)showString{
    if (!_showString) {
        _showString = [NSMutableString string];
    }
    return _showString;
}

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, kHLScreenW, kHLScreenH * 0.5 - 60 - self.resultView.frame.size.height) style:UITableViewStylePlain];
        tableView.backgroundColor = kHLColorWith22;
        tableView.estimatedRowHeight = 31;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
        _tableView = tableView;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kHLColorWith22;
    [self initSubViews];
}

- (void)initSubViews{
    [self initCalculatorView];
    [self initResultView];
    [self initTableView];
    [self initBackButton];
    [self initClearButton];
    [self initDatas];
}

- (void)initTableView{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:hlCalculatorHistoryListCellId bundle:[NSBundle mainBundle]] forCellReuseIdentifier:hlCalculatorHistoryListCellId];
}

- (void)initDatas{
    NSArray *localDatas = [[NSUserDefaults standardUserDefaults] objectForKey:@"HLCalculateResult"];
    if (localDatas && localDatas.count) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:localDatas];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)initClearButton{
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [clearButton sizeToFit];
    clearButton.frame = CGRectMake(12, self.tableView.frame.origin.y + self.tableView.frame.size.height * 0.5, clearButton.frame.size.width, clearButton.frame.size.height);
    [self.view addSubview:clearButton];
}

- (void)clearButtonAction{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提醒" message:@"是否要清空当前记录?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:cancelAction];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearDataAction];
    }];
    [alertVc addAction:sureAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)initBackButton{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(12, 40, 30, 30);
    [leftButton setImage:[UIImage imageNamed:@"nav_backbtn_white"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
}

- (void)leftButtonAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCalculatorView{
    _calculatorView = [[NSBundle mainBundle] loadNibNamed:@"HLCalculatorItemView" owner:nil options:nil].lastObject;
    _calculatorView.frame = CGRectMake(0, kHLScreenH * 0.5, kHLScreenW, kHLScreenH * 0.5);
    kHLWeakSelf
    _calculatorView.clickButtonBlock = ^(NSInteger clickTag, NSString * _Nonnull clickTitle) {
        [weakSelf updateDataWithClickTag:clickTag clickTitle:clickTitle];
    };
    [self.view addSubview:_calculatorView];
}

- (void)initResultView{
    UIScrollView *resultView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.calculatorView.frame.origin.y - 75, kHLScreenW, 75)];
    self.resultView = resultView;
    resultView.backgroundColor = kHLColorWith22;
    _resultLabel = [UILabel new];
    _resultLabel.textColor = [UIColor whiteColor];
    _resultLabel.font = [UIFont boldSystemFontOfSize:35];
    _resultLabel.frame = resultView.bounds;
    _resultLabel.textAlignment = NSTextAlignmentRight;
    [resultView addSubview:_resultLabel];
    [self.view addSubview:resultView];
}

- (void)updateDataWithClickTag:(NSInteger)clickTag clickTitle:(NSString *)clickTitle{
    NSMutableString *showStr = [self.showString mutableCopy];
    if (clickTag == 0) {
        //0
        if ([showStr isEqualToString:@"0"]){
            return;
        }else{
            if (self.lastClickTag == 17) {
                showStr = [[NSMutableString alloc] initWithString:clickTitle];
            }else{
                [showStr appendString:clickTitle];
            }
            self.lastClickTag = clickTag;
        }
    }else if (clickTag > 0 && clickTag < 10){
        //数字
        if ([showStr isEqualToString:@"0"] || self.lastClickTag == 17) {
            showStr = [[NSMutableString alloc] initWithString:clickTitle];
        }else{
            [showStr appendString:clickTitle];
        }
        self.lastClickTag = clickTag;
    }else if (clickTag == 10){
        //.
        if (showStr.length == 0) {
            showStr = [[NSMutableString alloc] initWithFormat:@"0%@",clickTitle];
        }else{
            if (self.lastClickTag == 10) {
                return;
            }else if (self.lastClickTag > 10 && self.lastClickTag < 15){
                [showStr appendFormat:@"0%@",clickTitle];
            }else if (self.lastClickTag == 17){
                showStr = [[NSMutableString alloc] initWithFormat:@"0%@",clickTitle];
            }else if (self.lastClickTag >= 0 && self.lastClickTag < 10){
                if ([self isCanAppendSpotWithString:showStr]) {
                    [showStr appendString:clickTitle];
                }else{
                    return;
                }
            }
        }
        self.lastClickTag = clickTag;
    }else if (clickTag > 10 && clickTag < 15){
        //加减乘除
        if (showStr.length == 0) {
            showStr = [[NSMutableString alloc] initWithFormat:@"0%@",clickTitle];
        }else{
            if (self.lastClickTag >= 0 && self.lastClickTag < 10) {
                [showStr appendString:clickTitle];
            }else if(self.lastClickTag >= 10 && self.lastClickTag < 15){
                [showStr replaceCharactersInRange:NSMakeRange(showStr.length - 1, 1) withString:clickTitle];
            }else if(self.lastClickTag == 17){
                [showStr appendString:clickTitle];
            }
        }
        self.lastClickTag = clickTag;
    }else if (clickTag == 15){
        //c
        if ([showStr isEqualToString:@"0"]) {
            return;
        }
        showStr = [[NSMutableString alloc] initWithFormat:@"0"];
        self.lastClickTag = 0;
    }else if (clickTag == 16){
        //←
        if (showStr.length == 0) {
            return;
        }
        [showStr replaceCharactersInRange:NSMakeRange(showStr.length - 1, 1) withString:@""];
        if (showStr.length > 0) {
            NSString *lastStr = [showStr substringFromIndex:showStr.length - 1];
            NSDictionary *datas = self.calculatorView.calculatorItemDatas;
            for (NSNumber *keyStr in datas.allKeys) {
                if ([datas[keyStr] isEqualToString:lastStr]) {
                    self.lastClickTag = [keyStr integerValue];
                    break;
                }
            }
        }else{
            self.lastClickTag = -1;
        }
    }else if (clickTag == 17){
        //=
        if (showStr.length == 0 || self.lastClickTag == 17) {
            return;
        }
        if (self.lastClickTag >= 10 && self.lastClickTag < 15) {
            [showStr replaceCharactersInRange:NSMakeRange(showStr.length - 1, 1) withString:@""];
        }
        //获取计算结果
        NSString *result = [self getCalculatorResultWithString:showStr];
        if (result == nil) {
            [self showAlertMessage:@"计算错误"];
            return;
        }else{
            //增加计算记录
            NSDictionary *data = @{@"guId":[self stringWithGUID],@"text":[NSString stringWithFormat:@"%@=%@",showStr,result]};
            [self saveData:data];
            [self.dataSource addObject:data];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            showStr = [[NSMutableString alloc] initWithString:result];
        }
        self.lastClickTag = clickTag;
    }
    self.showString = showStr;
    [self updateShowTitle];
}

- (void)updateShowTitle{
    self.resultLabel.text = self.showString;
    [self.resultLabel sizeToFit];
    CGFloat width = self.resultLabel.frame.size.width > kHLScreenW ? self.resultLabel.frame.size.width : kHLScreenW;
    self.resultLabel.frame = CGRectMake(0, 0, width, self.resultView.frame.size.height);
    self.resultView.contentSize = CGSizeMake(width, self.resultView.frame.size.height);
    [self.resultView setContentOffset:CGPointMake(width - kHLScreenW, 0) animated:NO];
}


//是否能够拼接.
- (BOOL)isCanAppendSpotWithString:(NSString *)string{
    if ([string containsString:@"."]){
        NSString *lastStr = [string componentsSeparatedByString:@"."].lastObject;
        if ([lastStr containsString:@"+"] ||
            [lastStr containsString:@"-"] ||
            [lastStr containsString:@"×"] ||
            [lastStr containsString:@"÷"]) {
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}

//获取计算结果
- (NSString *)getCalculatorResultWithString:(NSString *)string{
    NSDecimalNumber *decimalNumber = [self calculateResult:string];
    if (decimalNumber) {
        NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:kResultScale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        NSDecimalNumber *roundedOunces = [decimalNumber decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
        return roundedOunces.stringValue;
    }else{
        return nil;
    }
}


/**
 计算精确值
 */
- (NSDecimalNumber *)calculateResult:(NSString *)number{
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:@"0"];
    if ([number containsString:@"+"] ||
        [number containsString:@"-"] ||
        [number containsString:@"×"] ||
        [number containsString:@"÷"]) {
        if ([number containsString:@"+"]) {
            NSArray *array = [number componentsSeparatedByString:@"+"];
            for (NSString *num in array) {
                if (![self calculateResult:num.copy]) {
                    return nil;
                }
                decimalNumber = [decimalNumber decimalNumberByAdding:[self calculateResult:num.copy]];
            }
            return decimalNumber;
        }
        if ([number containsString:@"-"]) {
            NSArray *array = [number componentsSeparatedByString:@"-"];
            if (![self calculateResult:array.firstObject]) {
                return nil;
            }
            decimalNumber = [self calculateResult:array.firstObject];
            for (int i = 1; i < array.count ;i++) {
                NSString *num = array[i];
                if (![self calculateResult:num.copy]) {
                    return nil;
                }
                decimalNumber = [decimalNumber decimalNumberBySubtracting:[self calculateResult:num.copy]];
            }
            return decimalNumber;
        }
        
        if ([number containsString:@"×"]) {
            NSArray *array = [number componentsSeparatedByString:@"×"];
            decimalNumber = [[NSDecimalNumber alloc] initWithInt:1];
            for (NSString *num in array) {
                if (![self calculateResult:num.copy]) {
                    return nil;
                }
                decimalNumber = [decimalNumber decimalNumberByMultiplyingBy:[self calculateResult:num.copy]];
            }
            return decimalNumber;
        }
        
        if ([number containsString:@"÷"]) {
            NSArray *array = [number componentsSeparatedByString:@"÷"];
            if (![self calculateResult:array.firstObject]) {
                return nil;
            }
            decimalNumber = [self calculateResult:array.firstObject];
            for (int i = 1; i < array.count ;i++) {
                NSString *num = array[i];
                if (![self calculateResult:num.copy]) {
                    return nil;
                }
                if ([self calculateResult:num.copy].doubleValue == 0) {
                    return nil;
                }
                decimalNumber = [decimalNumber decimalNumberByDividingBy:[self calculateResult:num.copy]];
            }
            return decimalNumber;
        }
    }else{
        return [NSDecimalNumber decimalNumberWithString:number];
    }
    return decimalNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = self.dataSource[indexPath.row];
    HLCalculatorHistoryListCell *cell = [tableView dequeueReusableCellWithIdentifier:hlCalculatorHistoryListCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.resultLabel.text = data[@"text"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeData:self.dataSource[indexPath.row]];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)saveData:(NSDictionary *)data{
    NSArray *localDatas = [[NSUserDefaults standardUserDefaults] objectForKey:@"HLCalculateResult"];
    if (!localDatas) {
        localDatas = @[];
    }
    localDatas = [localDatas arrayByAddingObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:localDatas forKey:@"HLCalculateResult"];
}

- (void)removeData:(NSDictionary *)data{
    NSArray *localDatas = [[NSUserDefaults standardUserDefaults] objectForKey:@"HLCalculateResult"];
    if (localDatas == nil || localDatas.count == 0) {
        return;
    }
    NSInteger currentIndex = -1;
    for (NSInteger i = 0; i < localDatas.count; i++) {
        NSDictionary *tempData = localDatas[i];
        if ([tempData[@"guId"] isEqualToString:data[@"guId"]]) {
            currentIndex = i;
            break;
        }
    }
    if (currentIndex != -1) {
        NSMutableArray *tempDatas = [NSMutableArray arrayWithArray:localDatas];
        [tempDatas removeObjectAtIndex:currentIndex];
        [[NSUserDefaults standardUserDefaults] setObject:tempDatas forKey:@"HLCalculateResult"];
    }
}

- (void)clearDataAction{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HLCalculateResult"];
}

- (void)showAlertMessage:(NSString *)message{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:action];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (NSString *)stringWithGUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}

@end
