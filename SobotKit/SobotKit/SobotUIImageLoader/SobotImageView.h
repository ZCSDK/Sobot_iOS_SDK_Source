//
//  SobotImageView.h
//  SobotUIImageLoader
//
//  Created by zhangxy on 2021/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  UIImageViewURLDownloadState  ENUM
 */
typedef NS_ENUM(NSInteger, UIImageViewURLDownloadState) {
    /** 未知状态 */
    UIImageViewURLDownloadStateUnknown = 0,
    /** 加载 */
    UIImageViewURLDownloadStateLoaded,
    /** 等待加载 */
    UIImageViewURLDownloadStateWaitingForLoad,
    /** 重新加载 */
    UIImageViewURLDownloadStateNowLoading,
    /** 加载失败 */
    UIImageViewURLDownloadStateFailed,
};


@interface SobotImageView : UIImageView


// url
@property (nonatomic, strong) NSURL *url;

// download state
@property (nonatomic, readonly) UIImageViewURLDownloadState loadingState;

// UI
@property (nonatomic, strong) UIView *loadingView;
// Set UIActivityIndicatorView as loadingView
- (void)setDefaultLoadingView;

// instancetype
+ (id)imageViewWithURL:(NSURL *)url autoLoading:(BOOL)autoLoading;

// Get instance that has UIActivityIndicatorView as loadingView by default
+ (id)indicatorImageView;
+ (id)indicatorImageViewWithURL:(NSURL *)url autoLoading:(BOOL)autoLoading;

// Download
- (void)loadWithURL:(NSURL *)url;
- (void)loadWithURL:(NSURL *)url placeholer:(UIImage *__nullable)placeholerImage;
- (void)loadWithURL:(NSURL *)url placeholer:(UIImage *__nullable)placeholerImage showActivityIndicatorView:(BOOL)show;
- (void)loadWithURL:(NSURL *)url placeholer:(UIImage *)placeholerImage showActivityIndicatorView:(BOOL)show completionBlock:(void(^)(UIImage *image, NSURL *url, NSError *error))handler;

- (void)setUrl:(NSURL *)url autoLoading:(BOOL)autoLoading;
- (void)load;


+ (void)dataWithContentsOfURL:(NSURL *)url completionBlock:(void (^)(NSURL *, NSData *, NSError *))completion;
@end

NS_ASSUME_NONNULL_END
