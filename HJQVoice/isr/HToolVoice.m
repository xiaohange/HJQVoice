//
//  HToolVoice.m
//  SpeakForTest
//
//  Created by 韩俊强 on 16/4/27.
//  Copyright © 2016年 韩俊强. All rights reserved.
//

#import "HToolVoice.h"
#import <QuartzCore/QuartzCore.h>
#import "ISRDataHelper.h"
#import "IATConfig.h"
#import "UIButton+GCAlignment.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@implementation HToolVoice

#pragma mark - 按钮响应函数

- (void)startForVoice:(UIView*)view
{
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
    else
    {
        [_iflyRecognizerView cancel]; //取消识别
        [_iflyRecognizerView setDelegate:nil];
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
    
    CGFloat posY = 50;
    
    // 初始化弹框
    [self customErrorMessage:view];
    
    self.uploader = [[IFlyDataUploader alloc] init];
    
    //录音文件保存路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    _pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
    
    _textViewString = [[UITextView alloc]initWithFrame:CGRectMake(kScreenWidth/2-100 ,posY+50 , 200, 35)];
    _textViewString.font = [UIFont systemFontOfSize:16.0];
    _textViewString.textAlignment = NSTextAlignmentCenter;
    _textViewString.textColor = [UIColor whiteColor];
    _textViewString.backgroundColor = [UIColor blackColor];
    _textViewString.alpha = 0.3;
    _textViewString.layer.cornerRadius = 6.0f;
    _textViewString.layer.masksToBounds = YES;
    _textViewString.hidden = YES;
    [view addSubview:_textViewString];
    
    _cancleImageButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2-90, 50, 180, 140)];
    _cancleImageButton.backgroundColor = [UIColor blackColor];
    _cancleImageButton.alpha = 0.7;
    _cancleImageButton.layer.cornerRadius = 5.0f;
    _cancleImageButton.layer.masksToBounds = YES;
    _cancleImageButton.userInteractionEnabled = NO;
    [_cancleImageButton setImage:[UIImage imageNamed:@"microphone2"] forState:UIControlStateNormal];
   
    [_cancleImageButton setTitle:@"向上滑 取消发送" forState:UIControlStateNormal];
    _cancleImageButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancleImageButton verticalCenterImageAndTitle:10];
    _cancleImageButton.hidden = YES;
    [view addSubview:_cancleImageButton];
}

// 弹框
- (void)customErrorMessage:(UIView*)view
{
    if (!_myView) {
        // 弹框View
        _myView = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 100, 50, 200, 44)];
        _myView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.6];
        _myView.layer.cornerRadius = 5.0f;
        _myView.layer.masksToBounds = YES;
        _myView.hidden = YES; // 默认隐藏
        [view addSubview:_myView];
        
        _resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _resultLabel.text = @" ";
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.textColor = [UIColor whiteColor];
        _resultLabel.font = [UIFont systemFontOfSize:14.0];
        _resultLabel.alpha = 1.0f;
        
        [_myView addSubview:_resultLabel];
    }
}

// 隐藏弹框
- (void)hiddenMyView
{
    _myView.hidden = YES;
    _resultLabel.text = @" ";
}

// 展示弹框
- (void)showMyView:(NSString*)text
{
    _myView.hidden = NO;
    _resultLabel.text = text;
}

// 回调结果
- (void)returnString:(PassResultString)block
{
    self.passValue = block;
}

/**
 启动听写
 *****/
- (void)startBtnHandler:(UITextField *)textField{
    
    //    NSLog(@"%s[IN]",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        [_textViewString setText:@""];
//        [textField resignFirstResponder];
        self.isCanceled = NO;
        
        if(_iFlySpeechRecognizer == nil)
        {
            [self initRecognizer];
        }
        
        //不带标点
        [IATConfig sharedInstance].dot = [IFlySpeechConstant ASR_PTT_NODOT];
        [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
        [_iFlySpeechRecognizer cancel];
        
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (ret) {
            
        }else{
//            [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
        }
    }else {
        
        if(_iflyRecognizerView == nil)
        {
            [self initRecognizer ];
        }
        
        [_textViewString setText:@""];
//        [textField resignFirstResponder];
        
        //设置音频来源为麦克风
        [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iflyRecognizerView start];
    }
}

/**
 停止录音
 *****/
- (void)stopBtnHandler:(UITextField *)textField resignFirstResponderYesOrNo:(BOOL)YN{
    
    [_iFlySpeechRecognizer stopListening];
    if (YN) {
      [textField resignFirstResponder];
    }
    
//    _textViewString.hidden = NO;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        for (int i = 0; i < 5; i++) {
//            _textViewString.alpha -= 0.1f;
//        }
//        _textViewString.hidden = YES;
//    });
}

/**
 取消听写
 *****/
- (void)cancelBtnHandler:(UITextField *)textField{
    self.isCanceled = YES;
    
    [_iFlySpeechRecognizer cancel];
    
    [self hiddenMyView];
//    [textField resignFirstResponder];
//    _textViewString.hidden = YES;
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        [self hiddenMyView];
        return;
    }
    
//    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
//    [_popUpView showText: vol];
}

/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
//    [self showMyView:@"正在聆听..."];
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
//    [_popUpView showText: @"停止录音"];  // 停止录音 暂不显示
}


/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    //    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO ) {
        
        if (self.isCanceled) {
            [self showMyView:@"识别取消"];
            
        } else if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                [self showMyView:@"识别失败"];
            }else {
//                text = @"识别成功"; // 成功的状态不给显示
            }
        }else {
            // 发生错误暂不传递，只给提示
//            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
            [self showMyView:@"识别失败"];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hiddenMyView];
        });
        
    }else {
//        [_popUpView showText:@"识别结束"]; // 识别结束暂不给提示
        //        NSLog(@"errorCode:%d",[error errorCode]);
    }
    
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    _result =[NSString stringWithFormat:@"%@%@", _textViewString.text,resultString];
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    _textViewString.text = [NSString stringWithFormat:@"%@%@", _textViewString.text,resultFromJson];
   
    if (isLast){
        [self hiddenMyView];
        // 回调
        self.passValue(_textViewString.text);
        //        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
    //    NSLog(@"_result=%@",_result);
    //    NSLog(@"resultFromJson=%@",resultFromJson);
    //    NSLog(@"isLast=%d,_textView.text=%@",isLast,_textView.text);
}



/**
 有界面，听写结果回调
 resultArray：听写结果
 isLast：表示最后一次
 ****/
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    _textViewString.text = [NSString stringWithFormat:@"%@%@",_textViewString.text,result];
}



/**
 听写取消回调
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    //    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    }else  {//有界面
        
        //单例模式，UI的实例
        if (_iflyRecognizerView == nil) {
            //UI显示剧中
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:_textViewString.center];
            
            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            
        }
        _iflyRecognizerView.delegate = self;
        
        if (_iflyRecognizerView != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            //设置最长录音时间
            [_iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                //设置语言
                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    }
}


@end
