//
//  ZCItemView.h
//  CollectionViewDemo
//
//  Created by  on 2017/6/18.
//  Copyright © 2017年  All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCItemView : UIView

+(CGFloat)getHeightWithArray:(NSArray *)titles;

-(void)InitDataWithArray:(NSArray *)titles;
-(void)InitDataWithArray:(NSArray *)titles withCheckLabels:(NSString *) labels;

-(NSString *)getSeletedTitle;
@end
