//
//  HJQInputAccessoryView.h
//  purchasingManager
//
//  Created by BestKai on 16/6/17.
//  Copyright © 2016年 郑州悉知. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define screenWidth ([[UIScreen mainScreen] bounds].size.width)
#define screenHeight ([[UIScreen mainScreen] bounds].size.height)
/**
 *  分割线颜色(E0E1E0)
 *
 *  @return <#return value description#>
 */
#define COLOR_LINE_SEPARATER UIColorFromRGB(0xE0E1E0)
@protocol HJQInputViewDelegate <NSObject>

- (void)holdDownButtonTouchDown;

- (void)holdDownButtonTouchUpOutside;

- (void)holdDownButtonTouchUpInside;


@end



@interface HJQInputAccessoryView : UIView
{
    NSString *inputTitle;
    
    
}

@property (assign,nonatomic) id <HJQInputViewDelegate> delegate;



- (instancetype)initWithTitle:(NSString *)title andInputTextFiled:(UITextField *)textFiled;



@end
