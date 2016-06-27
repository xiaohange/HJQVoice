//
//  HJQInputAccessoryView.m
//  purchasingManager
//
//  Created by BestKai on 16/6/17.
//  Copyright © 2016年 郑州悉知. All rights reserved.
//

#import "HJQInputAccessoryView.h"
#import "UIButton+GCAlignment.h"


@implementation HJQInputAccessoryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithTitle:(NSString *)title andInputTextFiled:(UITextField *)textFiled {
    
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, screenWidth, 44);
        self.backgroundColor = [UIColor whiteColor];
        
        
        
        inputTitle = title;
        
        [self setUpUI];
        
        textFiled.inputAccessoryView = self;
    }
    return self;
}


- (void)setUpUI
{
    UIView *slideView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    slideView.backgroundColor = COLOR_LINE_SEPARATER;
    [self addSubview:slideView];
    
    // 往自定义view中添加各种UI控件
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 100,5,200,35)];
    [btn setTitle:inputTitle forState:UIControlStateNormal];
    [btn setTitle:@"松开搜索" forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btnClicked)forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [btn addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"microphone1"] forState:UIControlStateNormal];
    [btn horizontalCenterImageAndTitle:10.0f];
    [self addSubview:btn];
}



- (void)holdDownButtonTouchDown {
    // 开始说话
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(holdDownButtonTouchDown)]) {
        [self.delegate holdDownButtonTouchDown];
    }
}

- (void)holdDownButtonTouchUpOutside {
    // 取消录音
    if (self.delegate && [self.delegate respondsToSelector:@selector(holdDownButtonTouchUpOutside)]) {
        [self.delegate holdDownButtonTouchUpOutside];
    }
}

- (void)holdDownButtonTouchUpInside {
    // 完成录音
    if (self.delegate && [self.delegate respondsToSelector:@selector(holdDownButtonTouchUpInside)]) {
        [self.delegate holdDownButtonTouchUpInside];
    }
}

// 点击事件
- (void)btnClicked
{
    //    NSLog(@"11111");
}




@end
