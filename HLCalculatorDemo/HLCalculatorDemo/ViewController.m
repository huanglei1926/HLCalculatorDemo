//
//  ViewController.m
//  HLCalculatorDemo
//
//  Created by cainiu on 2019/1/17.
//  Copyright © 2019 HL. All rights reserved.
//

#import "ViewController.h"
#import "HLCalculatorClass/HLCalculatorController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *calculatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [calculatorButton setTitle:@"计算器" forState:UIControlStateNormal];
    calculatorButton.backgroundColor = [UIColor blueColor];
    [calculatorButton addTarget:self action:@selector(calculatorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    calculatorButton.frame = CGRectMake(120, 200, 80, 30);
    [self.view addSubview:calculatorButton];
}

- (void)calculatorButtonAction:(UIButton *)button{
    HLCalculatorController *calculatorVc = [HLCalculatorController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:calculatorVc];
    [self presentViewController:nav animated:YES completion:nil];
}


@end
