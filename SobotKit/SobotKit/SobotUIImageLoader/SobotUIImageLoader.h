//
//  SobotUIImageLoader.h
//  SobotUIImageLoader
//
//  Created by zhangxy on 2021/8/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SobotUIImageLoader : NSObject

+(NSString *)getImageLoaderVersion;



/// 根据颜色返回图片
/// @param color 颜色对象
+ (UIImage *)sobotImageWithColor:(UIColor *)color;


//等比例缩放
+(UIImage *)sobotImageScaleToSize:(CGSize)size with:(UIImage *) image;



/// 根据图片类型展示图片，识别gif格式
+ (UIImage *)sobotImageWithData:(NSData *)data;


///获取git图片
/// @param name  图片名称
+ (UIImage *)sobotAnimatedGIFNamed:(NSString *)name;




//**  获取图片类型 */
+ (NSString *)sobotContentTypeForImageData:(NSData *)data;



/// 重绘图片
/// @param image 图片资源
+(UIImage *) decode:(UIImage *)image;

@end
