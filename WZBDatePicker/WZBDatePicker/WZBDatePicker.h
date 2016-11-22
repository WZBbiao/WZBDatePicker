//
//  WZBDatePicker.h
//  WZBDatePicker
//
//  Created by normal on 2016/11/15.
//  Copyright © 2016年 WZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZBDatePickerCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle;
+ (NSString *)cellReuseIdentifier;
@end

typedef NS_ENUM(NSInteger, WZBDatePickerType) {
    WZBDatePickerNormal = 0,    // 普通的显示在界面上
    WZBDatePickerInputView = 1,      // 做键盘显示
    WZBDatePickerBottomPop          // 从视图底部弹出
};

@interface WZBDatePicker : UIView
//* 显示，pickerType：显示方式 resultDidChange：滑动picker的时候调用  block参数age：年龄，constellation：星座 **/
+ (instancetype)showToView:(UIView *)view pickerType:(WZBDatePickerType)pickerType resultDidChange:(void(^)(NSString *age, NSString *constellation))resultDidChange;
//* 是否有黑色半透明遮罩，默认没有，在pickerType=WZBDatePickerInputView时不起任何作用 **/
@property (nonatomic, assign, getter=isEnableDarkMask) BOOL enableDarkMask;
//* 设置初始时间 **/
- (void)setCurrentDate:(NSDate *)date;

//* 隐藏 **/
- (void)hidden;

@end
