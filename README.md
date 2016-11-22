# WZBDatePicker
一句话实现一个可以自动计算年龄和星座的DatePicker



![普通显示在界面上](https://github.com/WZBbiao/WZBDatePicker/blob/master/0.png?raw=true)
![从屏幕下边弹出](https://github.com/WZBbiao/WZBDatePicker/blob/master/1.gif?raw=true)
![做键盘显示](https://github.com/WZBbiao/WZBDatePicker/blob/master/2.gif?raw=true)

 #####2、使用方法：
 
将WZBDatePicker.h和WZBDatePicker.m拖入工程

只需要在需要使用的地方直接导入头文件WZBDatePicker.h，然后调用下边这个方法即可

```

/* 显示方法 view：如果WZBDatePickerInputView传拥有inputView的空间，其他传普通的view，pickerType：显示方式 resultDidChange：滑动picker的时候调用  block参数age：年龄，constellation：星座 **/
    [WZBDatePicker showToView:self.view pickerType:WZBDatePickerNormal resultDidChange:^(NSString *age, NSString *constellation){
        // to do
    }];
    
```


```
typedef NS_ENUM(NSInteger, WZBDatePickerType) {
    WZBDatePickerNormal = 0,    // 普通的显示在界面上
    WZBDatePickerInputView = 1,      // 做键盘显示
    WZBDatePickerBottomPop          // 从视图底部弹出
};

@interface WZBDatePicker : UIView

/* 显示方法 view：如果WZBDatePickerInputView传拥有inputView的空间，其他传普通的view，pickerType：显示方式 resultDidChange：滑动picker的时候调用  block参数age：年龄，constellation：星座 **/
+ (instancetype)showToView:(UIView *)view pickerType:(WZBDatePickerType)pickerType resultDidChange:(void(^)(NSString *age, NSString *constellation))resultDidChange;

/* 设置初始时间 **/
- (void)setCurrentDate:(NSDate *)date;

/* 隐藏 **/
- (void)hidden;

/* 是否有黑色半透明遮罩，默认没有，在pickerType!=WZBDatePickerBottomPop时不起任何作用 **/
@property (nonatomic, assign, getter=isEnableDarkMask) BOOL enableDarkMask;
    
```

>h文件中提供了这些方法和属性，注释写的很清楚，可以直接使用。

如果做键盘显示，需要这样：
```

/* 显示方法 view：如果WZBDatePickerInputView传拥有inputView的空间，其他传普通的view，pickerType：显示方式 resultDidChange：滑动picker的时候调用  block参数age：年龄，constellation：星座 **/
    [WZBDatePicker showToView:self.textField pickerType:WZBDatePickerInputView resultDidChange:^(NSString *age, NSString *constellation){
        self.textField.text = [NSString stringWithFormat:@"%@--%@", age, constellation];
    }];

```

 #####3、实现大致原理：
 

>里边是一个tableView，tableView的headerView是一个label，显示信息。tableView的footerView是个UIDatePicker，显示日期。这样写是因为比较好控制中间两行cell的显示与隐藏，headerView和footerView也不用单独管理size

监听picker的滚动，并刷新tableView或者调用block更新时间，如果是键盘，隐藏了中间两行cell，所以不需要刷新tableView

```
- (void)dateDidChanged:(UIDatePicker *)datePicker {
    self.checkedDate = datePicker.date;
    self.pickerType == WZBDatePickerInputView ? [self upData] : [self.tableView reloadData];
}

```

如果enableDarkMask为yes，背景颜色变成半透明颜色
```

- (void)setEnableDarkMask:(BOOL)enableDarkMask {
    _enableDarkMask = enableDarkMask;
    if (self.pickerType == WZBDatePickerBottomPop) {
        self.backgroundColor = self.isEnableDarkMask ? [UIColor colorWithWhite:0 alpha:0.2] : [UIColor clearColor];
    }
}

```

此demo较为简单，就讲这么多，如还有不清楚的，请加入我的技术群，我详细的讲给你听！

请不要吝惜，随手点个star吧！您的支持是我最大的动力😊！
 此系列文章持续更新，您可以关注我以便及时查看我的最新文章或者您还可以加入我们的技术群，大家庭期待您的加入！
 
![我们的社区](https://raw.githubusercontent.com/WZBbiao/WZBSwitch/master/IMG_1850.JPG)
