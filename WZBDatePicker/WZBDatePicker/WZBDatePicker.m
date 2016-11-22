//
//  WZBDatePicker.m
//  WZBDatePicker
//
//  Created by normal on 2016/11/15.
//  Copyright © 2016年 WZB. All rights reserved.
//

#import "WZBDatePicker.h"

#define WZBScreenWidth  [UIScreen mainScreen].bounds.size.width
#define WZBScreenHeight [UIScreen mainScreen].bounds.size.height

static const unsigned int allCalendarUnitFlags = NSCalendarUnitYear | NSCalendarUnitQuarter | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitEra | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekOfYear;

@interface WZBDatePickerCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subLabel;

@end

// 创建一条线
static UIView * getLineView() {
    UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, 39, WZBScreenWidth, 1}];
    lineView.backgroundColor = [UIColor lightGrayColor];
    return lineView;
}

// 自定义cell
@implementation WZBDatePickerCell
#pragma mark - lazy
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLabel];
        _titleLabel.frame = CGRectMake(5, 0, 50, self.contentView.frame.size.height);
    }
    return _titleLabel;
}

- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_subLabel];
        _subLabel.frame = CGRectMake(55, 0, WZBScreenWidth - 60, self.contentView.frame.size.height);
        _subLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.subLabel.textColor = [UIColor blackColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor lightGrayColor];
        _subLabel.backgroundColor = _titleLabel.backgroundColor = [UIColor clearColor];
        _subLabel.textColor = _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:getLineView()];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.size.height -= 1;
    [super setFrame:frame];
}

+ (NSString *)cellReuseIdentifier {
    return @"WZBDatePickerCellId";
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
    self.titleLabel.text = title;
    self.subLabel.text = subTitle;
}

@end

@interface WZBDatePicker () <UITableViewDataSource, UITableViewDelegate>
// datePicker
@property (nonatomic, strong) UIDatePicker *picker;
// tableView
@property (nonatomic, strong) UITableView *tableView;
// block回调
@property (nonatomic, copy) void(^resultDidChange)(NSString *age, NSString *constellation);
// view类型
@property (nonatomic, assign) WZBDatePickerType pickerType;
// 父视图
@property (nonatomic, strong) UIView *hostView;
// 选中的时间
@property (nonatomic, strong) NSDate *checkedDate;
// 计算出的年龄
@property (nonatomic, copy) NSString *age;
// 计算出的星座
@property (nonatomic, copy) NSString *constellation;

@end

@implementation WZBDatePicker
#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.allowsSelection = NO;
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.frame = CGRectMake(0, 0, WZBScreenWidth, 40);
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.text = @"滚动时间,系统自动计算年龄、星座";
        titleLable.textColor = [UIColor colorWithRed:0.5843 green:0.5843 blue:0.5843 alpha:1.0];
        titleLable.font = [UIFont systemFontOfSize:13.0f];
        [titleLable addSubview:getLineView()];
        _tableView.tableHeaderView = titleLable;
        _tableView.backgroundColor = [UIColor whiteColor];
        if (self.pickerType == WZBDatePickerInputView) {
            _tableView.frame = CGRectMake(0, 0, WZBScreenWidth, WZBScreenHeight / 2);
        } else {
            CGRect frame = _tableView.frame;
            frame.size = CGSizeMake(WZBScreenWidth, WZBScreenHeight / 2);
            _tableView.frame = frame;
            _tableView.center = CGPointMake(WZBScreenWidth / 2, WZBScreenHeight / 2);
        }
    }
    return _tableView;
}

- (UIDatePicker *)picker {
    if (!_picker) {
        _picker = [[UIDatePicker alloc] init];
        _picker.backgroundColor = [UIColor whiteColor];
        [_picker addTarget:self action:@selector(dateDidChanged:) forControlEvents:UIControlEventValueChanged];
        _picker.datePickerMode = UIDatePickerModeDate;
        _picker.frame = CGRectMake(0, 0, WZBScreenWidth, _tableView.frame.size.height - 44 * 3);
        [_picker setMaximumDate:[NSDate date]];
    }
    return _picker;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.checkedDate = [NSDate date];
        self.backgroundColor = self.isEnableDarkMask ? [UIColor colorWithWhite:0 alpha:0.2] : [UIColor clearColor];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)]];
    }
    return self;
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    if (self.pickerType != WZBDatePickerBottomPop) return;
    if (self.isEnableDarkMask) {
        if (CGRectContainsPoint(self.tableView.frame, [tap locationInView:self])) return;
        [self hidden];
    }
}

- (void)setEnableDarkMask:(BOOL)enableDarkMask {
    _enableDarkMask = enableDarkMask;
    if (self.pickerType == WZBDatePickerBottomPop) {
        self.backgroundColor = self.isEnableDarkMask ? [UIColor colorWithWhite:0 alpha:0.2] : [UIColor clearColor];
    }
}

//* 显示，pickerType：显示方式 resultDidChange：滑动picker的时候调用 **/
+ (instancetype)showToView:(UIView *)view pickerType:(WZBDatePickerType)pickerType resultDidChange:(void(^)(NSString *age, NSString *constellation))resultDidChange {
    WZBDatePicker *datePicker = [[WZBDatePicker alloc] initWithFrame:CGRectMake(0, WZBScreenHeight, WZBScreenWidth, pickerType == WZBDatePickerInputView ? 275 :WZBScreenHeight)];
    datePicker.pickerType = pickerType;
    datePicker.resultDidChange = resultDidChange;
    datePicker.hostView = view;
    [datePicker addSubview:datePicker.tableView];
    datePicker.tableView.tableFooterView = datePicker.picker;
    
    if (pickerType == WZBDatePickerNormal) {
        [view addSubview:datePicker];
        datePicker.transform = CGAffineTransformMakeTranslation(0, -datePicker.frame.size.height);
        NSLog(@"%@", NSStringFromCGRect(datePicker.frame));
        [view addSubview:datePicker];
        CGRect frame = datePicker.tableView.frame;
        frame.origin.y = WZBScreenHeight - frame.size.height;
        datePicker.tableView.frame = frame;
    } else if (pickerType == WZBDatePickerInputView) {
        //        if ([view respondsToSelector:@selector(inputView)]) {
        //            [view setValue:datePicker forKey:@"inputView"];
        //        } else {
        //            NSException *exception = [];
        //        }
        // 判断传进来的view是否有键盘属性
        NS_DURING [view setValue:datePicker forKey:@"inputView"];
        NS_HANDLER NSLog(@"您传进来的View没有键盘属性");
        NS_ENDHANDLER
        
    } else {
        [view addSubview:datePicker];
        [UIView animateWithDuration:0.4 delay:1 usingSpringWithDamping:0.4 initialSpringVelocity:15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            datePicker.transform = CGAffineTransformMakeTranslation(0, -datePicker.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
    return datePicker;
}

- (void)dateDidChanged:(UIDatePicker *)datePicker {
    self.checkedDate = datePicker.date;
    self.pickerType == WZBDatePickerInputView ? [self upData] :
    [self.tableView reloadData];
}

- (void)setCurrentDate:(NSDate *)date {
    self.picker.date = date;
}

// 获取年份
- (NSInteger)yearWithDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = allCalendarUnitFlags;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    return [dateComponents year];
}

//* 隐藏 **/
- (void)hidden {
    if (self.pickerType == WZBDatePickerNormal) {
        [self removeFromSuperview];
    } else if (self.pickerType == WZBDatePickerBottomPop) {
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.hostView resignFirstResponder];
    }
}


#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pickerType == WZBDatePickerInputView ? 0 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [WZBDatePickerCell cellReuseIdentifier];
    WZBDatePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[WZBDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [self upData];
    if (indexPath.row == 0) {
        [cell setTitle:@"年龄:" subTitle:self.age];
    } else {
        [cell setTitle:@"星座:" subTitle:self.constellation];
    }
    return cell;
}

- (void)upData {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy MM dd"];
    NSDate *ret = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
    NSInteger year = [self yearWithDate:ret] - [self yearWithDate:self.checkedDate];
    self.age = [NSString stringWithFormat:@"%ld岁", year + 1];
    self.constellation = [self getConstellationName:self.checkedDate];
    if (self.resultDidChange) {
        self.resultDidChange(self.age, self.constellation);
    }
}

// 计算星座
- (NSString *)getConstellationName:(NSDate *)date {
    
    NSString *retStr = @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    int i_month = 0;
    NSString *theMonth = [dateFormat stringFromDate:date];
    if ([[theMonth substringToIndex:0] isEqualToString:@"0"]) {
        i_month = [[theMonth substringFromIndex:1] intValue];
    } else {
        i_month = [theMonth intValue];
    }
    
    [dateFormat setDateFormat:@"dd"];
    int i_day = 0;
    NSString *theDay = [dateFormat stringFromDate:date];
    if ([[theDay substringToIndex:0] isEqualToString:@"0"]) {
        i_day = [[theDay substringFromIndex:1] intValue];
    } else {
        i_day = [theDay intValue];
    }
    
    switch (i_month) {
        case 1:
            if (i_day >= 20 && i_day <= 31) {
                retStr = @"水瓶座";
            }
            if (i_day >= 1 && i_day <= 19) {
                retStr = @"摩羯座";
            }
            break;
        case 2:
            if (i_day >= 1 && i_day <= 18) {
                retStr = @"水瓶座";
            }
            if (i_day >= 19 && i_day <= 31) {
                retStr = @"双鱼座";
            }
            break;
        case 3:
            if (i_day >= 1 && i_day <= 20) {
                retStr = @"双鱼座";
            }
            if (i_day >= 21 && i_day <= 31) {
                retStr = @"白羊座";
            }
            break;
        case 4:
            if (i_day >= 1 && i_day <= 19) {
                retStr = @"白羊座";
            }
            if (i_day >= 20 && i_day <= 31) {
                retStr = @"金牛座";
            }
            break;
        case 5:
            if (i_day >= 1 && i_day <= 20) {
                retStr = @"金牛座";
            }
            if (i_day >= 21 && i_day <= 31) {
                retStr = @"双子座";
            }
            break;
        case 6:
            if (i_day >= 1 && i_day <= 21) {
                retStr = @"双子座";
            }
            if (i_day >= 22 && i_day <= 31) {
                retStr = @"巨蟹座";
            }
            break;
        case 7:
            if (i_day >= 1 && i_day <= 22) {
                retStr = @"巨蟹座";
            }
            if (i_day >= 23 && i_day <= 31) {
                retStr = @"狮子座";
            }
            break;
        case 8:
            if (i_day >= 1 && i_day <= 22) {
                retStr = @"狮子座";
            }
            if (i_day >= 23 && i_day <= 31) {
                retStr = @"处女座";
            }
            break;
        case 9:
            if (i_day >= 1 && i_day <= 22) {
                retStr = @"处女座";
            }
            if (i_day >= 23 && i_day <= 31) {
                retStr = @"天秤座";
            }
            break;
        case 10:
            if (i_day >= 1 && i_day <= 23) {
                retStr = @"天秤座";
            }
            if (i_day >= 24 && i_day <= 31) {
                retStr = @"天蝎座";
            }
            break;
        case 11:
            if (i_day >= 1 && i_day <= 21) {
                retStr = @"天蝎座";
            }
            if (i_day >= 22 && i_day <= 31) {
                retStr = @"射手座";
            }
            break;
        case 12:
            if (i_day >= 1 && i_day <= 21) {
                retStr = @"射手座";
            }
            if (i_day >= 21 && i_day <= 31) {
                retStr = @"摩羯座";
            }
            break;
    }
    return retStr;
}

// cell分割线对其
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    cell.preservesSuperviewLayoutMargins = NO;
}
- (void)viewDidLayoutSubviews {
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

@end
