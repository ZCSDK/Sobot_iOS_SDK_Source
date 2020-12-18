//
//  ZCXJAlbumController.h
//  SobotKit
//
//  Created by zhangxy on 2017/4/5.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCUIBaseController.h"

/**
 *  XJAlbumOutImgViewPoint enum
 */
typedef enum
{
    /** 左上 */
    XJAlbumOutImgViewPointLeftUp =1,
    /** 右上 */
    XJAlbumOutImgViewPointRightUp,
    /** 左下 */
    XJAlbumOutImgViewPointLeftDown,
    /** 右下 */
    XJAlbumOutImgViewPointRightDown
}XJAlbumOutImgViewPointType;


@protocol ZCXJAlbumDelegate <NSObject>

- (void)getCurPage:(NSInteger)curPage;

- (void)delCurPage:(NSInteger)curPage;

@end


/// 上传多图是，浏览图片页面
@interface ZCXJAlbumController :ZCUIBaseController<UIScrollViewDelegate>

@property (nonatomic,assign)CGRect photoFrame;
@property (nonatomic,strong)id<ZCXJAlbumDelegate>myDelegate;

-(id)initWithImgUrlArr:(NSMutableArray*)array CurPage:(NSInteger)curpage;

-(id)initWithImgULocationArr:(NSMutableArray*)array CurPage:(NSInteger)curpage;

@end

