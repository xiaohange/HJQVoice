//
//  HToolVoice.h
//  SpeakForTest
//
//  Created by 韩俊强 on 16/4/27.
//  Copyright © 2016年 韩俊强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iflyMSC/iflyMSC.h"
@class PopupView;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;
/**
 语音听写demo
 使用该功能仅仅需要四步
 1.创建识别对象；
 2.设置识别参数；
 3.有选择的实现识别回调；
 4.启动识别
 */
typedef void (^PassResultString)(NSString *passValueString);

@interface HToolVoice : NSObject<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSString *pcmFilePath;//音频文件路径
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;//带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象
@property (nonatomic, strong) PopupView *popUpView;
@property (nonatomic, strong) NSString * result;
@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, strong) UITextView *textViewString;
@property (nonatomic, strong) UIButton *cancleImageButton; // 取消视图
@property (nonatomic, strong) PassResultString passValue;
@property (nonatomic, strong) UIView *myView;       // 弹框
@property (nonatomic, strong) UILabel *resultLabel; // 弹框显示的文字

// 回调结果
- (void)returnString:(PassResultString)block;

// 初始化配置
- (void)startForVoice:(UIView*)view;

/**
 启动听写
 *****/
- (void)startBtnHandler:(UITextField *)textField;

/**
 停止录音
 YN : 收回键盘
 *****/
- (void)stopBtnHandler:(UITextField *)textField resignFirstResponderYesOrNo:(BOOL)YN;

/**
 取消听写
 *****/
- (void)cancelBtnHandler:(UITextField *)textField;


@end
