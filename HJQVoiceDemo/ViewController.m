//
//  ViewController.m
//  HJQVoiceDemo
//
//  Created by HanJunQiang on 16/6/27.
//  Copyright © 2016年 HaRi. All rights reserved.
//

#import "ViewController.h"
#import "HToolVoice.h"
#import "IATViewController.h"
#import "HJQInputAccessoryView.h"

@interface ViewController ()<HJQInputViewDelegate>
{
    HToolVoice *hVoice;                           // 初始化类
    __weak IBOutlet UILabel *resultLabel;         // 样式2回调结果
    __weak IBOutlet UITextField *keywordTextFiled;// 样式1回调结果
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 第一步授权: 在 appdelegate 授权;
    // 第二步: 选择样式 目前支持两种样式;
    // 样式1: 有UITextFiled唤醒的语音界面,键盘上放置的语音按钮;
    // 样式1注意:引入 HToolVoice.h  HJQInputAccessoryView.h 并遵循HJQInputViewDelegate 代理方法
    
    
    // 样式1初始化
    hVoice = [[HToolVoice alloc]init];
    // 样式1初始化配置
    [hVoice startForVoice:self.view];
    // 样式1自定义键盘辅助视图
    [self configureTopView:keywordTextFiled];
    
    __block typeof(self)weakSelf = self;
    hVoice.passValue = ^(NSString *passValueString){
        // 样式1回调结果
       weakSelf->keywordTextFiled.text = passValueString;
    };
}

#pragma mark ------ 样式1 -----
#pragma mark ------ HJQInputViewDelegate ------
- (void)configureTopView:(UITextField*)textField
{
    HJQInputAccessoryView *aaa = [[HJQInputAccessoryView alloc] initWithTitle:@"按住 说出你查的东东" andInputTextFiled:keywordTextFiled];
    aaa.delegate = self;
}

#pragma mark ------ 关于麦克风按钮的操作-------
- (void)holdDownButtonTouchDown {
    keywordTextFiled.text = @"";
    // 开始说话
    [hVoice startBtnHandler:keywordTextFiled];
}

- (void)holdDownButtonTouchUpOutside {
    // 取消录音
    [hVoice cancelBtnHandler:keywordTextFiled];
}

- (void)holdDownButtonTouchUpInside {
    // 完成录音
    [hVoice stopBtnHandler:keywordTextFiled resignFirstResponderYesOrNo:YES];
}

// 点击事件
- (void)btnClicked
{
    //    NSLog(@"11111");
}


#pragma mark ---- 样式2 ----
// 样式2 只需引入 IATViewController.h 调用回调结果方法即可
- (IBAction)searchVoiceAction:(id)sender
{
    // 样式2: 按钮调用自定义语音页面;
    IATViewController *hjqVC = [[IATViewController alloc]init];
    [self presentViewController:hjqVC animated:YES completion:^{
        
     hjqVC.passValues = ^(NSString *resultString){
        // 样式2回调结果
        resultLabel.text = resultString;
    };
 }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
