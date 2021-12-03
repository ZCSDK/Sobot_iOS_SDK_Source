//
//  XHImageViewer.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507
//  本人QQ群（142557668）. All rights reserved.
//

#import "SobotXHImageViewer.h"
#import "SobotXHViewState.h"
#import "SobotXHZoomingImageView.h"
#import "SobotImageView.h"

#define kXHImageViewerBaseTopToolBarTag 100
#define kXHImageViewerBaseBottomToolBarTag 200

@interface SobotXHImageViewer () <UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSArray *imgViews;

@property(nonatomic, copy) WillDismissWithSelectedViewBlock willDismissWithSelectedViewBlock;
@property(nonatomic, copy) DidDismissWithSelectedViewBlock didDismissWithSelectedViewBlock;
@property(nonatomic, copy) DidChangeToImageViewBlock didChangeToImageViewBlock;




@end

@implementation SobotXHImageViewer

- (void)setImageViewsFromArray:(NSArray *)views {
    NSMutableArray *imgViews = [NSMutableArray array];
    for (id obj in views) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [imgViews addObject:obj];
            
            UIImageView *view = obj;
            
            SobotXHViewState *state = [SobotXHViewState viewStateForView:view];
            [state setStateWithView:view];
            
            view.userInteractionEnabled = NO;
        }
    }
    _imgViews = [imgViews copy];
}

- (UIImage *)currentImage {
    return [self currentView].image;
}

- (void)showWithImageViews:(NSArray *)views
              selectedView:(UIImageView *)selectedView {
    [self setImageViewsFromArray:views];
    
    if (_imgViews.count > 0) {
        if (![selectedView isKindOfClass:[UIImageView class]] ||
            ![_imgViews containsObject:selectedView]) {
            selectedView = _imgViews[0];
        }
        [self showWithSelectedView:selectedView];
    }
}

#pragma mark - Life Cycle

- (void)_setup {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
//    self.backgroundColor = ZCColorWithWhiteAlpha(0.1,1);
    self.backgroundScale = 0.95;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];
}

- (id)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self _setup];
    }
    return self;
}

- (id)initWithImageViewerWillDismissWithSelectedViewBlock:(WillDismissWithSelectedViewBlock)willDismissWithSelectedViewBlock
                          didDismissWithSelectedViewBlock:(DidDismissWithSelectedViewBlock)didDismissWithSelectedViewBlock
                                didChangeToImageViewBlock:(DidChangeToImageViewBlock)didChangeToImageViewBlock {
    
    if (self = [self initWithFrame:CGRectZero]) {
        self.willDismissWithSelectedViewBlock = willDismissWithSelectedViewBlock;
        self.didDismissWithSelectedViewBlock = didDismissWithSelectedViewBlock;
        self.didChangeToImageViewBlock = didChangeToImageViewBlock;
        
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self _setup];
    }
    return self;
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[backgroundColor colorWithAlphaComponent:0]];
}

- (NSInteger)pageIndex {
    return (_scrollView.contentOffset.x / _scrollView.frame.size.width);
}

#pragma mark - Getter Method

- (UIView *)topToolBar {
    UIView *topToolBar = [self viewWithTag:kXHImageViewerBaseTopToolBarTag];
    if (!topToolBar) {
        if ([self.delegate respondsToSelector:@selector(customTopToolBarOfImageViewer:)]) {
            topToolBar = [self.delegate customTopToolBarOfImageViewer:self];
            topToolBar.frame = CGRectMake(0, -CGRectGetHeight(topToolBar.bounds), CGRectGetWidth(topToolBar.bounds), CGRectGetHeight(topToolBar.bounds));
        }
    }
    
    return topToolBar;
}

- (UIView *)bottomToolBar {
    UIView *bottomToolBar = [self viewWithTag:kXHImageViewerBaseBottomToolBarTag];
    if (!bottomToolBar) {
        if ([self.delegate respondsToSelector:@selector(customBottomToolBarOfImageViewer:)]) {
            bottomToolBar = [self.delegate customBottomToolBarOfImageViewer:self];
            bottomToolBar.tag = kXHImageViewerBaseBottomToolBarTag;
            bottomToolBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(bottomToolBar.bounds), CGRectGetHeight(bottomToolBar.bounds));
        }
    }
    return bottomToolBar;
}

#pragma mark - View management

- (UIImageView *)currentView {
    return [_imgViews objectAtIndex:self.pageIndex];
}

- (void)showWithSelectedView:(UIImageView *)selectedView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    const NSInteger currentPage = [_imgViews indexOfObject:selectedView];
    
    UIWindow *window = [self getCurWindow];
//    _window = [[[UIApplication sharedApplication] delegate] window];
    
    UIView *topToolBar = [self topToolBar];
    if (topToolBar) {
        if (![self.subviews containsObject:topToolBar]) {
            topToolBar.alpha = 0.0;
            [self addSubview:topToolBar];
        }
    }
    
    UIView *bottomToolBar = [self bottomToolBar];
    if (bottomToolBar) {
        if (![self.subviews containsObject:bottomToolBar]) {
            bottomToolBar.alpha = 0.0;
            [self addSubview:bottomToolBar];
        }
    }
    
    CGRect scrollViewFrame = self.bounds;
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor =
        [self.backgroundColor colorWithAlphaComponent:1];
        _scrollView.alpha = 0;
        _scrollView.delegate = self;
    }
    
    [self insertSubview:_scrollView atIndex:0];
    [window addSubview:self];
    
    const CGFloat fullW = window.frame.size.width;
    const CGFloat fullH = window.frame.size.height;
    
    selectedView.frame =
    [window convertRect:selectedView.frame fromView:selectedView.superview];
    [window addSubview:selectedView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
        self->_scrollView.alpha = 1;
//                         window.rootViewController.view.transform = CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale);
                         
                         selectedView.transform = CGAffineTransformIdentity;
                         
                         CGSize size = (selectedView.image) ? selectedView.image.size
                         : selectedView.frame.size;
                         CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                         CGFloat W = ratio * size.width;
                         CGFloat H = ratio * size.height;
                         selectedView.frame =
                         CGRectMake((fullW - W) / 2, (fullH - H) / 2, W, H);
                     }
                     completion:^(BOOL finished) {
        self->_scrollView.contentSize = CGSizeMake(self->_imgViews.count * fullW, 0);
        self->_scrollView.contentOffset = CGPointMake(currentPage * fullW, 0);
                         
                         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(tappedScrollView:)];
        [self->_scrollView addGestureRecognizer:gesture];
                         
        for (SobotImageView *view in self->_imgViews) {
                             view.transform = CGAffineTransformIdentity;
                             
                             if ([view respondsToSelector:@selector(largePhotoURLString)]) {
                                 UIImageView <SobotXHImageURLDataSource> *dataSource = (UIImageView <SobotXHImageURLDataSource> *)view;
                                 
                                 [view loadWithURL:[NSURL URLWithString:[dataSource largePhotoURLString]]];
                             }
                             
                             CGSize size = (view.image) ? view.image.size : view.frame.size;
                             CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             view.frame = CGRectMake((fullW - W) / 2, (fullH - H) / 2, W, H);
                             
                             SobotXHZoomingImageView *tmp = [[SobotXHZoomingImageView alloc]
                                                             initWithFrame:CGRectMake([self->_imgViews indexOfObject:view] * fullW,
                                                                                 0, fullW, fullH)];
                             tmp.imageView = view;
                             
                             [self->_scrollView addSubview:tmp];
                         }
                         
                         [self showToolBar];
                     }];
}

- (void)showToolBar {
    [UIView animateWithDuration:0.3 animations:^{
        UIView *topToolBar = [self topToolBar];
        UIView *bottomToolBar = [self bottomToolBar];
        topToolBar.frame = CGRectMake(0, 0, CGRectGetWidth(topToolBar.bounds), CGRectGetHeight(topToolBar.bounds));
        topToolBar.alpha = 1.0;
        
        bottomToolBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - CGRectGetHeight(bottomToolBar.bounds), CGRectGetWidth(bottomToolBar.bounds), CGRectGetHeight(bottomToolBar.bounds));
        bottomToolBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissToolBar {
    [UIView animateWithDuration:0.3 animations:^{
        UIView *topToolBar = [self topToolBar];
        UIView *bottomToolBar = [self bottomToolBar];
        topToolBar.frame = CGRectMake(0, -CGRectGetHeight(topToolBar.bounds), CGRectGetWidth(topToolBar.bounds), CGRectGetHeight(topToolBar.bounds));
        topToolBar.alpha = 0.0;
        
        bottomToolBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(bottomToolBar.bounds), CGRectGetHeight(bottomToolBar.bounds));
        bottomToolBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)prepareToDismiss {
    UIImageView *currentView = [self currentView];
    
    if ([self.delegate respondsToSelector:@selector(imageViewer:willDismissWithSelectedView:)]) {
        [self.delegate imageViewer:self willDismissWithSelectedView:currentView];
    }
    
    if (self.willDismissWithSelectedViewBlock) {
        self.willDismissWithSelectedViewBlock(self, currentView);
    }
    
    [self dismissToolBar];
    
    for (UIImageView *view in _imgViews) {
        if (view != currentView) {
            SobotXHViewState *state = [SobotXHViewState viewStateForView:view];
            view.transform = CGAffineTransformIdentity;
            view.frame = state.frame;
            view.transform = state.transform;
            [state.superview addSubview:view];
        }
    }
}


- (void)dismissWithAnimate {
    [self dismissWithAnimate:0.3];
}

- (void)dismissWithAnimate:(CGFloat) animate{
    UIImageView *currentView = [self currentView];
    UIWindow *window = [self getCurWindow];
    
    CGRect rct = currentView.frame;
    currentView.transform = CGAffineTransformIdentity;
    currentView.frame = [window convertRect:rct fromView:currentView.superview];
    [window addSubview:currentView];
    if(animate == 0){
         _scrollView.alpha = 0;
        //                         window.rootViewController.view.transform = CGAffineTransformIdentity;

        SobotXHViewState *state = [SobotXHViewState viewStateForView:currentView];
        currentView.frame =
        [window convertRect:state.frame fromView:state.superview];
        currentView.transform = state.transform;



        currentView.transform = CGAffineTransformIdentity;
        currentView.frame = state.frame;
        currentView.transform = state.transform;
        [state.superview addSubview:currentView];

        for (UIView *view in _imgViews) {
         if ([view respondsToSelector:@selector(largePhotoURLString)]) {
             UIImageView <SobotXHImageURLDataSource> *dataSource = (UIImageView <SobotXHImageURLDataSource> *)view;
             [((SobotImageView *)view) loadWithURL:[NSURL URLWithString:[dataSource thnumbnailPhotoURLString]]];
         }
         SobotXHViewState *_state = [SobotXHViewState viewStateForView:view];
         view.userInteractionEnabled = _state.userInteratctionEnabled;
        }
        [self removeFromSuperview];

        if ([self.delegate
          respondsToSelector:@selector(imageViewer:didDismissWithSelectedView:)]) {
         [self.delegate imageViewer:self
         didDismissWithSelectedView:currentView];
        }

        if (self.didDismissWithSelectedViewBlock) {
         self.didDismissWithSelectedViewBlock(self, currentView);
        }
    }else{
    
        [UIView animateWithDuration:animate
                     animations:^{
            self->_scrollView.alpha = 0;
//                         window.rootViewController.view.transform = CGAffineTransformIdentity;
                         
                         SobotXHViewState *state = [SobotXHViewState viewStateForView:currentView];
                         currentView.frame =
                         [window convertRect:state.frame fromView:state.superview];
                         currentView.transform = state.transform;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             SobotXHViewState *state = [SobotXHViewState viewStateForView:currentView];
                             currentView.transform = CGAffineTransformIdentity;
                             currentView.frame = state.frame;
                             currentView.transform = state.transform;
                             [state.superview addSubview:currentView];
                             
                             for (UIView *view in self->_imgViews) {
                                 if ([view respondsToSelector:@selector(largePhotoURLString)]) {
                                     UIImageView <SobotXHImageURLDataSource> *dataSource = (UIImageView <SobotXHImageURLDataSource> *)view;
                                     [((SobotImageView *)view) loadWithURL:[NSURL URLWithString:[dataSource thnumbnailPhotoURLString]]];
                                 }
                                 SobotXHViewState *_state = [SobotXHViewState viewStateForView:view];
                                 view.userInteractionEnabled = _state.userInteratctionEnabled;
                             }
                             [self removeFromSuperview];
                             
                             if ([self.delegate
                                  respondsToSelector:@selector(imageViewer:didDismissWithSelectedView:)]) {
                                 [self.delegate imageViewer:self
                                 didDismissWithSelectedView:currentView];
                             }
                             
                             if (self.didDismissWithSelectedViewBlock) {
                                 self.didDismissWithSelectedViewBlock(self, currentView);
                             }
                         }
                     }];
                                 }
}

#pragma mark - Gesture events

- (void)tappedScrollView:(UITapGestureRecognizer *)sender {
    if (self.disableTouchDismiss) {
        return;
    }
    [self prepareToDismiss];
    [self dismissWithAnimate];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)sender {
    if (self.disableTouchDismiss) {
        return;
    }
    static UIImageView *currentView = nil;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentView = [self currentView];
        
        UIView *targetView = currentView.superview;
        while (![targetView isKindOfClass:[SobotXHZoomingImageView class]]) {
            targetView = targetView.superview;
        }
        
        if (((SobotXHZoomingImageView *)targetView).isViewing) {
            currentView = nil;
        } else {
            UIWindow *window = [self getCurWindow];
            currentView.frame =
            [window convertRect:currentView.frame fromView:currentView.superview];
            [window addSubview:currentView];
            
            [self prepareToDismiss];
        }
    }
    
    if (currentView) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            if (_scrollView.alpha > 0.5) {
                [self showWithSelectedView:currentView];
            } else {
                [self dismissWithAnimate];
            }
            currentView = nil;
        } else {
            CGPoint p = [sender translationInView:self];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, p.y);
            transform = CGAffineTransformScale(transform, 1 - fabs(p.y) / 1000,
                                               1 - fabs(p.y) / 1000);
            currentView.transform = transform;
            
            CGFloat r = 1 - fabs(p.y) / 200;
            _scrollView.alpha = MAX(0, MIN(1, r));
        }
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(imageViewer:didChangeToImageView:)]) {
        [self.delegate imageViewer:self didChangeToImageView:[self currentView]];
    }
    
    if (self.didChangeToImageViewBlock) {
        self.didChangeToImageViewBlock(self, [self currentView]);
    }
}




-(UIWindow *)getCurWindow{
    UIWindow* window = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        window = [appDelegate window];
        
        // 获取最上层Window，2.8.5添加，如果新建一个window会导致无法看到适配页面
        for (UIWindow *win in [[UIApplication sharedApplication].windows reverseObjectEnumerator]) {
            if ([win isEqual:window]) {
                continue;
            }
            if (win.windowLevel >= window.windowLevel && win.hidden != YES && win.isKeyWindow) {
                window =win;
            }
        }
    }
    
    if(window == nil){
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 13.0)
        {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
            {
                if (windowScene.activationState == UISceneActivationStateForegroundActive)
                {
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        }
    }
    return window;
}

@end
