# HJQVoice
前言
===
一款在科大讯飞基础上二次开发的语音识别功能的开源框架，目前支持两种样式：
- 1.键盘上方语音按钮；
- 2.按钮调用自定义语音界面；
![](https://github.com/xiaohange/HJQVoice/blob/master/v1.1.png?raw=true)

![](https://github.com/xiaohange/HJQVoice/blob/master/v1.gif?raw=true)

## Installation
Drag all source files under floder `HJQVoice` to your project.
并加入 `pod "HJQiflyMSC"` 基础包

```
pod "HJQiflyMSC"
```
注意:上线前要替换pod中`libSunFlower.a`, 换成你申请的包中的`libSunFlower.a`文件,否则无法跟你自己的账户下数据关联;

## Usage

```
    // 第一步授权: 在 appdelegate 授权;
    // 第二步: 选择样式 目前支持两种样式;
    // 样式1: 有UITextFiled唤醒的语音界面,键盘上放置的语音按钮;
    // 样式1注意:引入 HToolVoice.h  HJQInputAccessoryView.h 
                并遵循HJQInputViewDelegate 代理方法
```
在AppDelegate中授权:

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 使用方法：第一步：授权登录
    [self registerIFlyVoice];
   
    return YES;
}

- (void)registerIFlyVoice
{
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    //Appid是应用的身份信息,具有唯一性,初始化时必须要传入Appid。//5770bc82  这是一个测试号
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"5770bc82"];
    [IFlySpeechUtility createUtility:initString];
}
```
在需要的地方:

```
#import "HToolVoice.h"
#import "IATViewController.h"
#import "HJQInputAccessoryView.h"

    HToolVoice *hVoice;                           // 初始化类
    __weak IBOutlet UILabel *resultLabel;         // 样式2回调结果
    __weak IBOutlet UITextField *keywordTextFiled;// 样式1回调结果
    
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
```
```
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
```

## Other
[JQTumblrHud-高仿Tumblr App 加载指示器hud](https://github.com/xiaohange/JQTumblrHud)

[JQScrollNumberLabel：仿tumblr热度滚动数字条数](https://github.com/xiaohange/JQScrollNumberLabel)

[TumblrLikeAnimView-仿Tumblr点赞动画效果](https://github.com/xiaohange/TumblrLikeAnimView)

[JQMenuPopView-仿Tumblr弹出视图发音频、视频、图片、文字的视图](https://github.com/xiaohange/JQMenuPopView)

## Star

[CSDN博客](http://blog.csdn.net/qq_31810357)    

iOS开发者交流群：446310206

喜欢就❤️❤️❤️star一下吧！你的支持是我更新的动力！
 
Love is every every every star! Your support is my renewed motivation!


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).





