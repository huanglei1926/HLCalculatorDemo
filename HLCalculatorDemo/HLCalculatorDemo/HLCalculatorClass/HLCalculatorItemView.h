//
//  HLCalculatorItemView.h
//  HLCalculatorDemo
//
//  Created by cainiu on 2019/1/17.
//  Copyright © 2019 HL. All rights reserved.
//

#import <UIKit/UIKit.h>

//@(0):@"0",
//@(1):@"1",
//@(2):@"2",
//@(3):@"3",
//@(4):@"4",
//@(5):@"5",
//@(6):@"6",
//@(7):@"7",
//@(8):@"8",
//@(9):@"9",
//@(10):@".",
//@(11):@"+",
//@(12):@"-",
//@(13):@"×",
//@(14):@"÷",
//@(15):@"c",
//@(16):@"←",
//@(17):@"=",

NS_ASSUME_NONNULL_BEGIN

#define kHLHEXCOLORA(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:a]
#define kHLButtonWhiteColor [UIColor whiteColor]
#define kHLButtonGrayColor kHLHEXCOLORA(0xd5d5d5,1.0)
#define kHLButtonOrangeColor kHLHEXCOLORA(0xE9943A,1.0)

@interface HLCalculatorItemView : UIView

/** 数字按钮集合(包含小数点) */
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numButtonArray;

/** 清除 */
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
/** 加 */
@property (weak, nonatomic) IBOutlet UIButton *addButton;
/** 减 */
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
/** 乘 */
@property (weak, nonatomic) IBOutlet UIButton *multiplyButton;
/** 除 */
@property (weak, nonatomic) IBOutlet UIButton *divideButton;
/** 回退 */
@property (weak, nonatomic) IBOutlet UIButton *backButton;
/** 结果 */
@property (weak, nonatomic) IBOutlet UIButton *resultButton;

@property (nonatomic, copy) NSDictionary *calculatorItemDatas;

@property (nonatomic, copy) void(^clickButtonBlock)(NSInteger clickTag,NSString *clickTitle);

@end

NS_ASSUME_NONNULL_END
