//
//  HLCalculatorItemView.m
//  HLCalculatorDemo
//
//  Created by cainiu on 2019/1/17.
//  Copyright © 2019 HL. All rights reserved.
//

#import "HLCalculatorItemView.h"



@implementation HLCalculatorItemView

- (NSDictionary *)calculatorItemDatas{
    if (!_calculatorItemDatas) {
        _calculatorItemDatas = @{
                                 @(0):@"0",
                                 @(1):@"1",
                                 @(2):@"2",
                                 @(3):@"3",
                                 @(4):@"4",
                                 @(5):@"5",
                                 @(6):@"6",
                                 @(7):@"7",
                                 @(8):@"8",
                                 @(9):@"9",
                                 @(10):@".",
                                 @(11):@"+",
                                 @(12):@"-",
                                 @(13):@"×",
                                 @(14):@"÷",
                                 @(15):@"c",
                                 @(16):@"←",
                                 @(17):@"=",
                                 };
    }
    return _calculatorItemDatas;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self configButton];
}

- (void)configButton{
    [self initButtons:self.numButtonArray];
    [self initButtons:@[self.clearButton,self.addButton,self.minusButton,self.multiplyButton,self.divideButton,self.backButton,self.resultButton]];
}

- (void)initButtons:(NSArray *)buttons{
    [self initButtonBackgroundColorWithButtons:buttons];
    [self addButtonTargetActions:buttons];
}

- (void)initButtonBackgroundColorWithButtons:(NSArray *)buttons{
    for (UIButton *button in buttons) {
        if (button.tag <= 10) {
            button.backgroundColor = [UIColor whiteColor];
        }else{
            button.backgroundColor = kHLButtonGrayColor;
        }
    }
}

- (void)addButtonTargetActions:(NSArray *)buttons{
    
    for (UIButton *button in buttons) {
        [button addTarget:self action:@selector(clickAllButtonTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(clickAllButtonTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(clickAllButtonTouchUpOutsideAction:) forControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void)clickAllButtonTouchDownAction:(UIButton *)button{
    button.backgroundColor = kHLButtonOrangeColor;
}

- (void)clickAllButtonTouchUpInsideAction:(UIButton *)button{
    if (button.tag <= 10) {
        button.backgroundColor = [UIColor whiteColor];
    }else{
        button.backgroundColor = kHLButtonGrayColor;
    }
    if (self.clickButtonBlock) {
        self.clickButtonBlock(button.tag, self.calculatorItemDatas[@(button.tag)]);
    }
}

- (void)clickAllButtonTouchUpOutsideAction:(UIButton *)button{
    if (button.tag <= 10) {
        button.backgroundColor = [UIColor whiteColor];
    }else{
        button.backgroundColor = kHLButtonGrayColor;
    }
}

@end
