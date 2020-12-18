//
//  ZCConfigCodeCell.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/28.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCConfigCodeCell.h"


#import "EntityConvertUtils.h"

@implementation ZCConfigCodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemsView];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        self.contentView.userInteractionEnabled = YES;
        [self createItemsView];
    }
    return self;
}

-(void)createItemsView{
    if(!_labTitle){
        _labTitle = [self createLabel];
        _labTitle.tag = 0;
        [self.contentView addSubview:_labTitle];
    }
    if(!_labTitle2){
        _labTitle2 = [self createLabel];
        _labTitle2.tag = 1;
        [self.contentView addSubview:_labTitle2];
    }
}

-(UILabel *)createLabel{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, ScreenWidth - 20, 21)];
    [label setTextColor:UIColor.blueColor];
    [label setFont:[UIFont systemFontOfSize:14]];
    label.numberOfLines = 0;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkClick:)];
    [label addGestureRecognizer:tap];
    return label;
}

-(void)linkClick:(UITapGestureRecognizer *) tap{
    
    NSInteger index = tap.view.tag;
    if(self.delegate && [self.delegate respondsToSelector:@selector(openURLString:)]){
        NSString *url = self.tempData[index];
        url = [url stringByReplacingOccurrencesOfString:@"#" withString:@"$$$"];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [url stringByReplacingOccurrencesOfString:@"$$$" withString:@"#"];
        [self.delegate openURLString:url];
    }
    
}


-(void)dataToView:(NSArray *)codeData{
    
    CGFloat maxHeight = 44;
    _labTitle2.hidden = YES;
    if(codeData){
        self.tempData = codeData;
         for(int i=0;i<codeData.count;i++){
             
            if(i==0){
                _labTitle.text = codeData[i];
                [_labTitle sizeToFit];
                maxHeight = CGRectGetMaxY(_labTitle.frame) + 10;
            }else if(i==1){
                _labTitle2.hidden = NO;
                _labTitle2.text = codeData[i];
                [_labTitle2 sizeToFit];
                CGRect f = _labTitle2.frame;
                f.origin.y = CGRectGetMaxY(_labTitle.frame) + 5;
                _labTitle2.frame = f;
                maxHeight = CGRectGetMaxY(_labTitle2.frame) + 10;
            }
        }
        
    }
    self.frame = CGRectMake(0, 0, ScreenWidth, maxHeight);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
