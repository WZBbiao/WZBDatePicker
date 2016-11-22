//
//  ViewController.m
//  WZBDatePicker
//
//  Created by normal on 2016/11/15.
//  Copyright © 2016年 WZB. All rights reserved.
//

#import "ViewController.h"
#import "WZBDatePicker.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [WZBDatePicker showToView:self.textField pickerType:WZBDatePickerInputView resultDidChange:^(NSString *age, NSString *constellation){
        self.textField.text = [NSString stringWithFormat:@"%@--%@", age, constellation];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
