//
//  HJQPulseView.h
//  HJQPulseView
//
//  Created by HaRi on 06/21/16.
//  Copyright © 2016 HanJunqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJQPulseView : UIView

//gradient layer property
@property (nonatomic, copy  ) NSArray    *colors;
@property (nonatomic, copy  ) NSArray    *locations;
@property (nonatomic, assign) CGPoint    startPoint;
@property (nonatomic, assign) CGPoint    endPoint;

//replicator layer property
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) CGFloat    duration;

//circle layer property
@property (nonatomic, assign) CGFloat    minRadius;
@property (nonatomic, assign) CGFloat    maxRadius;
@property (nonatomic, assign) CGFloat    lineWidth;

//animation property
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

- (void)startAnimation;
- (void)stopAnimation;

@end
