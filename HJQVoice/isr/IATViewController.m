//
//  IATViewController.m
//  SpeakForTest
//
//  Created by 韩俊强 on 16/4/27.
//  Copyright © 2016年 韩俊强. All rights reserved.
//

#import "IATViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PopupView.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "HJQPulseView.h"

@interface IATViewController ()
{
    UIView *tmpView; // 背景大view
    UILabel *tmpLabel;
    UIImageView *voiceImageStr; //按住提示
    
}
// 录音按钮相关
@property (weak, nonatomic) IBOutlet UIButton *starSpeckButton;// 说话按钮

/**
 *  当录音按钮被按下所触发的事件，这时候是开始录音
 */
- (void)holdDownButtonTouchDown;

/**
 *  当手指在录音按钮范围之外离开屏幕所触发的事件，这时候是取消录音
 */
- (void)holdDownButtonTouchUpOutside;

/**
 *  当手指在录音按钮范围之内离开屏幕所触发的事件，这时候是完成录音
 */
- (void)holdDownButtonTouchUpInside;

/**
 *  当手指滑动到录音按钮的范围之外所触发的事件
 */
//- (void)holdDownDragOutside;

@end

@implementation IATViewController

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
  
    [_starSpeckButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_starSpeckButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [_starSpeckButton addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_starSpeckButton setBackgroundColor:[UIColor clearColor]];
//    [_starSpeckButton addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
//    [_starSpeckButton addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    
    // "按住说话－松开搜索"提示
    [voiceImageStr removeFromSuperview];
    voiceImageStr = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, kScreenHeight - 170, 80, 33)];
    voiceImageStr.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"speck"]];
    [self.view addSubview:voiceImageStr];

    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_textView.layer setCornerRadius:7.0f];
    
    CGFloat posY = self.textView.frame.origin.y+30;
    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, posY, 0, 0) withParentView:self.view];
    
    self.uploader = [[IFlyDataUploader alloc] init];
    
    //demo录音文件保存路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    _pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
}

// 结果回调的实现
- (void)returenResultstring:(PassValueBlock)block
{
    self.passValues = block;
}

#pragma mark ------ 关于按钮操作的一些事情-------
- (void)holdDownButtonTouchDown {
    
    // 动画开始
    HJQPulseView *pulseView = self.pulseArray[0];
    [pulseView startAnimation];

    [_starSpeckButton setImage:[UIImage imageNamed:@"Oval"] forState:UIControlStateHighlighted];
    
    // 开始说话
    [self startBtnHandler];
  
    // "按住说话－松开搜索"提示
    [voiceImageStr removeFromSuperview];
    voiceImageStr = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, kScreenHeight - 180, 80, 33)];
    voiceImageStr.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"searchVoice"]];
    [self.view addSubview:voiceImageStr];
    
}

- (void)holdDownButtonTouchUpOutside {
    [_starSpeckButton setImage:[UIImage imageNamed:@"client"] forState:UIControlStateNormal];
    
    // 动画结束
    HJQPulseView *pulseView = self.pulseArray[0];
    [pulseView stopAnimation];
 
    // 取消录音
    [self cancelBtnHandler];
    // "按住说话－松开搜索"提示
    [voiceImageStr removeFromSuperview];
    voiceImageStr = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, kScreenHeight - 170, 80, 33)];
    voiceImageStr.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"speck"]];
    [self.view addSubview:voiceImageStr];
}

- (void)holdDownButtonTouchUpInside {
 
    [_starSpeckButton setImage:[UIImage imageNamed:@"client"] forState:UIControlStateNormal];
    // 动画结束
    HJQPulseView *pulseView = self.pulseArray[0];
    [pulseView stopAnimation];
    
    // 完成录音
    [self stopBtnHandler];
    // "按住说话－松开搜索"提示
    [voiceImageStr removeFromSuperview];
    voiceImageStr = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, kScreenHeight - 170, 80, 33)];
    voiceImageStr.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"speck"]];
    [self.view addSubview:voiceImageStr];
}

-(void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"%s",__func__);
    
    [super viewWillAppear:animated];
    
    [self initRecognizer];    //初始化识别对象
    
    [self animationForVoice]; // 初始化动画
}

// 动画1
- (void)animationForVoice
{
    NSMutableArray *pulseArray = @[].mutableCopy;
    for ( int i = 0 ; i < 1 ; ++i ){
        [pulseArray addObject:[[HJQPulseView alloc]init]];
    }
    self.pulseArray = pulseArray;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    for ( int i = 0 ; i < 1; ++i )
    {
        for ( int j = 0 ; j < 1; ++j )
        {
            NSInteger index = i*1+j;
            HJQPulseView *pulseView = pulseArray[0];
            
            pulseView.frame = CGRectMake(0,
                                         [UIScreen mainScreen].bounds.size.height - 220,
                                         kScreenWidth,
                                         240);
            
            [self.view addSubview:pulseView];
            
            switch (index) {
                case 0:
                {
                    pulseView.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                    pulseView.colors = @[(__bridge id)[UIColor colorWithRed:0/255 green:120/255 blue:255/255 alpha:0.5].CGColor,(__bridge id)[UIColor colorWithRed:0/255 green:120/255 blue:255/255 alpha:0.5].CGColor];
                    
                    CGFloat posY = (CGRectGetHeight(screenRect)-320)/2/CGRectGetHeight(screenRect);
                    pulseView.startPoint = CGPointMake(0.5, posY);
                    pulseView.endPoint = CGPointMake(0.5, 1.0f - posY);
                    
                    pulseView.minRadius = 30.8;
                    pulseView.maxRadius = 130;
                    
                    pulseView.duration = 2;
                    pulseView.count = 4;
                    pulseView.lineWidth = 1.0f;
                    
                    //将btn拉到视图最前面
                    [self.view bringSubviewToFront:_starSpeckButton];

                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.view = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
//    NSLog(@"%s",__func__);
    
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
    
    
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - 按钮响应函数
/**
 启动听写
 *****/
- (void)startBtnHandler{
    
//    NSLog(@"%s[IN]",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        [_textView setText:@""];
        [_textView resignFirstResponder];
        self.isCanceled = NO;
        
        if(_iFlySpeechRecognizer == nil)
        {
            [self initRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //不带标点
        [IATConfig sharedInstance].dot = [IFlySpeechConstant ASR_PTT_NODOT];
        
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (ret) {

        }else{
            [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
        }
    }else {
        
        if(_iflyRecognizerView == nil)
        {
            [self initRecognizer ];
        }
        
        [_textView setText:@""];
        [_textView resignFirstResponder];
        
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
- (void)stopBtnHandler{
    
    [_iFlySpeechRecognizer stopListening];
    [_textView resignFirstResponder];
    
 
}

/**
 取消听写
 *****/
- (void)cancelBtnHandler{
    self.isCanceled = YES;
    
    [_iFlySpeechRecognizer cancel];
    
    [_popUpView removeFromSuperview];
    [_textView resignFirstResponder];
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        [_popUpView removeFromSuperview];
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
//    NSLog(@"onBeginOfSpeech");
    [_popUpView showText: @"正在聆听"];
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
//    NSLog(@"onEndOfSpeech");
    
//    [_popUpView showText: @"停止录音"];
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
        NSString *text ;
        
        if (self.isCanceled) {
            text = @"识别取消";
         [_popUpView showText: text];
        } else if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = @"无识别结果";
                [_popUpView showText: text];
                _textView.text = @"抱歉，没听清楚";
            }else {
                text = @"识别成功";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   
                    if ([_textView.text rangeOfString:@"抱歉，没听清楚"].location == NSNotFound) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            // 回调
                            self.passValues(_textView.text);
                        }];
                    }
                });
            }
        }else {
            // 错误暂不传递
//            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
#warning 后续自己添加提示框
            // 后续自己添加提示框
//         [SVProgressHUD showErrorWithStatus:@"识别错误,请重试"];
        }
        
       
        
    }else {
        [_popUpView showText:@"识别结束"];
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
    _result =[NSString stringWithFormat:@"%@%@", _textView.text,resultString];
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text,resultFromJson];
    
    if (isLast){
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
    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,result];
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
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
            
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


- (IBAction)goBackAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
