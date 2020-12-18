//
//  ZCButton.m
//  GCDtestDemo
//
//  Created by lizhihui on 2016/11/1.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import "ZCButton.h"
#import "ZCLibGlobalDefine.h"

@implementation ZCButton

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.type == 1) {
        // 图片靠右   语音cell的btn 设置样式
        CGPoint  imgCenter = self.imageView.center;
        imgCenter.x = (self.frame.size.width - 10) - self.imageView.frame.size.width/2;
        self.imageView.center = imgCenter;
        
        CGRect newFrame = [self titleLabel].frame;
        newFrame.origin.x = 5;
        newFrame.size.width = self.frame.size.width - 40;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
//        self.titleLabel.backgroundColor = [UIColor blueColor];
//        self.imageView.backgroundColor = [UIColor redColor];
        
    }else if(self.type == 2){
        // 多轮会话中的展开
        // 图片靠右
        CGPoint  imgCenter = self.imageView.center;
        imgCenter.x = (self.frame.size.width - 10) - self.imageView.frame.size.width/2 - _space;
        self.imageView.center = imgCenter;
        CGRect imgF = self.imageView.frame;
        imgF.size.width = 9;
        imgF.size.height = 6;
        self.imageView.frame = imgF;
        
        
        CGRect newFrame = [self titleLabel].frame;
        newFrame.origin.x = 9 + _space;
        newFrame.size.width = self.frame.size.width -25;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
  
    }else if (self.type == 3){
        // 切换机器人按钮
        CGPoint center = self.imageView.center;
        center.x = self.frame.size.width/2;
        center.y = self.imageView.frame.size.height*3/5 + 5;
        self.imageView.center = center;
        
        CGRect newFrame = [self titleLabel].frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.imageView.frame.size.height + 5 + 5;
        newFrame.size.width = self.frame.size.width;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }else if (self.type == 4){
        // 通告不置顶 展开和收起按钮
        CGPoint  imgCenter = self.imageView.center;
        imgCenter.x = (self.frame.size.width - 10) - self.imageView.frame.size.width/2;
        self.imageView.center = imgCenter;
        
        CGRect newFrame = [self titleLabel].frame;
        newFrame.origin.x = 5;
        newFrame.size.width = self.frame.size.width;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
    }else if (self.type == 5){
        // 图片在左，文字在右
        CGPoint center = self.titleLabel.center;
        
            center.x = self.frame.size.width/2 + ZCNumber(2);
       
        self.titleLabel.center = center;

        CGPoint centerimg = self.imageView.center;
      
            centerimg.x = centerimg.x - ZCNumber(2) ;
        
        self.imageView.center = centerimg;
    
        
    }else{
        CGPoint center = self.imageView.center;
        center.x = self.frame.size.width/2;
        center.y = self.imageView.frame.size.height*3/5;
        self.imageView.center = center;
        
        CGRect newFrame = [self titleLabel].frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.imageView.frame.size.height + 10;
        newFrame.size.width = self.frame.size.width;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
//    self.backgroundColor = [UIColor yellowColor];
}


@end
