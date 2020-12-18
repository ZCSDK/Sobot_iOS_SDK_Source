//
//  ZCSectionPropertyCell.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 2020/7/23.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCSectionPropertyCell.h"

#import "EntityConvertUtils.h"

@implementation ZCSectionPropertyCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemsView];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
    }
    return self;
}


- (void)createItemsView {
    // Initialization code
    if(!_titleLab){
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, ScreenWidth - 44, 21)];
        _titleLab.textColor = UIColorFromRGB(0x333333);
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.numberOfLines = 1;
        [self addSubview:_titleLab];
    }
    if(!_detailLab){
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_titleLab.frame)+5, ScreenWidth - 54, 0)];
        _detailLab.textColor = UIColorFromRGB(0x3D4966);
        _detailLab.numberOfLines = 0;
        _detailLab.font = [UIFont systemFontOfSize:13];
        [self addSubview:_detailLab];
    }
    
    if(!_img){
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 44, 20, 20, 20)];
        _img.image = [UIImage imageNamed:@"next_icon"];
        _img.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_img];
    }
    
}

-(void)initWithNSDictionary:(NSDictionary*)dict{
    
    _titleLab.text = [NSString stringWithFormat:@"%@ %@",dict[@"code"],dict[@"name"]];
    CGFloat space = 5;
    if(dict[@"desc"]!=nil){
        space = 0;
    }
    _detailLab.frame = CGRectMake(10, CGRectGetMaxY(_titleLab.frame) + space, ScreenWidth - 54, 0);
    _detailLab.text = dict[@"desc"];
    [_detailLab sizeToFit];
    
    CGFloat h = CGRectGetMaxY(_detailLab.frame)+12;
    CGRect imgf = _img.frame;
    imgf.origin.y = h/2 - 10;
    _img.frame = imgf;
    
    
    self.frame = CGRectMake(0, 0, ScreenWidth, h);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
