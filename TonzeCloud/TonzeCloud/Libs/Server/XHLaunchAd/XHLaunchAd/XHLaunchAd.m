//
//  XHLaunchAd.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 2016/6/13.
//  Copyright © 2016年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import "XHLaunchAd.h"
#import "XHLaunchAdView.h"
#import "XHLaunchAdImageView+XHLaunchAdCache.h"
#import "XHLaunchAdDownloader.h"
#import "XHLaunchAdCache.h"
#import "FLAnimatedImage.h"
#import "XHLaunchAdController.h"

typedef NS_ENUM(NSInteger, XHLaunchAdType) {
    XHLaunchAdTypeImage,
    XHLaunchAdTypeVideo
};

static NSInteger defaultWaitDataDuration = 3;
static  SourceType _sourceType = SourceTypeLaunchImage;
@interface XHLaunchAd()

@property(nonatomic,assign)XHLaunchAdType launchAdType;
@property(nonatomic,assign)NSInteger waitDataDuration;
@property(nonatomic,strong)XHLaunchImageAdConfiguration * imageAdConfiguration;
@property(nonatomic,strong)XHLaunchVideoAdConfiguration * videoAdConfiguration;
@property(nonatomic,strong)XHLaunchAdButton * skipButton;
@property(nonatomic,strong)XHLaunchAdVideoView * adVideoView;
@property(nonatomic,strong)UIWindow * window;
@property(nonatomic,copy)dispatch_source_t waitDataTimer;
@property(nonatomic,copy)dispatch_source_t skipTimer;
@property (nonatomic, assign) BOOL detailPageShowing;
@property(nonatomic,assign) CGPoint clickPoint;


@end

@implementation XHLaunchAd

+(void)setWaitDataDuration:(NSInteger )waitDataDuration{
    XHLaunchAd *launchAd = [XHLaunchAd shareLaunchAd];
    launchAd.waitDataDuration = waitDataDuration;
}
+(void)setLaunchSourceType:(SourceType)sourceType{
    _sourceType = sourceType;
}

+(XHLaunchAd *)imageAdWithImageAdConfiguration:(XHLaunchImageAdConfiguration *)imageAdconfiguration{
    return [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:nil];
}

+(XHLaunchAd *)imageAdWithImageAdConfiguration:(XHLaunchImageAdConfiguration *)imageAdconfiguration delegate:(id)delegate{
    XHLaunchAd *launchAd = [XHLaunchAd shareLaunchAd];
    if(delegate) launchAd.delegate = delegate;
    launchAd.imageAdConfiguration = imageAdconfiguration;
    return launchAd;
}

+(XHLaunchAd *)videoAdWithVideoAdConfiguration:(XHLaunchVideoAdConfiguration *)videoAdconfiguration{
    return [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:nil];
}

+(XHLaunchAd *)videoAdWithVideoAdConfiguration:(XHLaunchVideoAdConfiguration *)videoAdconfiguration delegate:(nullable id)delegate{
    XHLaunchAd *launchAd = [XHLaunchAd shareLaunchAd];
    if(delegate) launchAd.delegate = delegate;
    launchAd.videoAdConfiguration = videoAdconfiguration;
    return launchAd;
}

+(void)downLoadImageAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray{
    [self downLoadImageAndCacheWithURLArray:urlArray completed:nil];
}

+ (void)downLoadImageAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray completed:(nullable XHLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock{
    if(urlArray.count==0) return;
    [[XHLaunchAdDownloader sharedDownloader] downLoadImageAndCacheWithURLArray:urlArray completed:completedBlock];
}

+(void)downLoadVideoAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray{
    [self downLoadVideoAndCacheWithURLArray:urlArray completed:nil];
}

+(void)downLoadVideoAndCacheWithURLArray:(NSArray <NSURL *> * )urlArray completed:(nullable XHLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock{
    if(urlArray.count==0) return;
    [[XHLaunchAdDownloader sharedDownloader] downLoadVideoAndCacheWithURLArray:urlArray completed:completedBlock];
}
+(void)removeAndAnimated:(BOOL)animated{
    [[XHLaunchAd shareLaunchAd] removeAndAnimated:animated];
}

+(BOOL)checkImageInCacheWithURL:(NSURL *)url{
    return [XHLaunchAdCache checkImageInCacheWithURL:url];
}

+(BOOL)checkVideoInCacheWithURL:(NSURL *)url{
    return [XHLaunchAdCache checkVideoInCacheWithURL:url];
}
+(void)clearDiskCache{
    [XHLaunchAdCache clearDiskCache];
}

+(void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *> *)imageUrlArray{
    [XHLaunchAdCache clearDiskCacheWithImageUrlArray:imageUrlArray];
}

+(void)clearDiskCacheExceptImageUrlArray:(NSArray<NSURL *> *)exceptImageUrlArray{
    [XHLaunchAdCache clearDiskCacheExceptImageUrlArray:exceptImageUrlArray];
}

+(void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *> *)videoUrlArray{
    [XHLaunchAdCache clearDiskCacheWithVideoUrlArray:videoUrlArray];
}

+(void)clearDiskCacheExceptVideoUrlArray:(NSArray<NSURL *> *)exceptVideoUrlArray{
    [XHLaunchAdCache clearDiskCacheExceptVideoUrlArray:exceptVideoUrlArray];
}

+(float)diskCacheSize{
    return [XHLaunchAdCache diskCacheSize];
}

+(NSString *)xhLaunchAdCachePath{
    return [XHLaunchAdCache xhLaunchAdCachePath];
}

+(NSString *)cacheImageURLString{
    return [XHLaunchAdCache getCacheImageUrl];
}

+(NSString *)cacheVideoURLString{
    return [XHLaunchAdCache getCacheVideoUrl];
}

#pragma mark - 过期
/** 请使用removeAndAnimated: */
+(void)skipAction{
    [[XHLaunchAd shareLaunchAd] removeAndAnimated:YES];
}
/** 请使用setLaunchSourceType: */
+(void)setLaunchImagesSource:(LaunchImagesSource)launchImagesSource{
    switch (launchImagesSource) {
        case LaunchImagesSourceLaunchImage:
            _sourceType = SourceTypeLaunchImage;
            break;
        case LaunchImagesSourceLaunchScreen:
            _sourceType = SourceTypeLaunchScreen;
            break;
        default:
            break;
    }
}

#pragma mark - private
+(XHLaunchAd *)shareLaunchAd{
    static XHLaunchAd *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[XHLaunchAd alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupLaunchAd];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self setupLaunchAdEnterForeground];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:XHLaunchAdDetailPageWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            _detailPageShowing = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:XHLaunchAdDetailPageShowFinishNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            _detailPageShowing = NO;
        }];
    }
    return self;
}

-(void)setupLaunchAdEnterForeground{
    switch (_launchAdType) {
        case XHLaunchAdTypeImage:{
            if(!_imageAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupImageAdForConfiguration:_imageAdConfiguration];
        }
            break;
        case XHLaunchAdTypeVideo:{
            if(!_videoAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupVideoAdForConfiguration:_videoAdConfiguration];
        }
            break;
        default:
            break;
    }
}

-(void)setupLaunchAd{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [XHLaunchAdController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    window.alpha = 1;
    _window = window;
    /** 添加launchImageView */
    [_window addSubview:[[XHLaunchImageView alloc] initWithSourceType:_sourceType]];
}

/**图片*/
-(void)setupImageAdForConfiguration:(XHLaunchImageAdConfiguration *)configuration{
    if(_window == nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    XHLaunchAdImageView *adImageView = [[XHLaunchAdImageView alloc] init];
    [_window addSubview:adImageView];
    /** frame */
    if(configuration.frame.size.width>0 && configuration.frame.size.height>0) adImageView.frame = configuration.frame;
    if(configuration.contentMode) adImageView.contentMode = configuration.contentMode;
    /** webImage */
    if(configuration.imageNameOrURLString.length && XHISURLString(configuration.imageNameOrURLString)){
        [XHLaunchAdCache async_saveImageUrl:configuration.imageNameOrURLString];
        /** 自设图片 */
        if ([self.delegate respondsToSelector:@selector(xhLaunchAd:launchAdImageView:URL:)]) {
            [self.delegate xhLaunchAd:self launchAdImageView:adImageView URL:[NSURL URLWithString:configuration.imageNameOrURLString]];
        }else{
            if(!configuration.imageOption) configuration.imageOption = XHLaunchAdImageDefault;
            XHWeakSelf
            [adImageView xh_setImageWithURL:[NSURL URLWithString:configuration.imageNameOrURLString] placeholderImage:nil GIFImageCycleOnce:configuration.GIFImageCycleOnce options:configuration.imageOption completed:^(UIImage *image,NSData *imageData,NSError *error,NSURL *url){
                if(!error){
                    if ([weakSelf.delegate respondsToSelector:@selector(xhLaunchAd:imageDownLoadFinish:)]) {
                        [weakSelf.delegate xhLaunchAd:self imageDownLoadFinish:image];
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(xhLaunchAd:imageDownLoadFinish:imageData:)]) {
                        [weakSelf.delegate xhLaunchAd:self imageDownLoadFinish:image imageData:imageData];
                    }
                }else{
                    //下载错误
                }
            }];
            if(configuration.imageOption == XHLaunchAdImageCacheInBackground){
                /** 缓存中未有 */
                if(![XHLaunchAdCache checkImageInCacheWithURL:[NSURL URLWithString:configuration.imageNameOrURLString]]){
                    [self removeAndAnimateDefault]; return; /** 完成显示 */
                }
            }
        }
    }else{
        if(configuration.imageNameOrURLString.length){
            NSData *data = XHDataWithFileName(configuration.imageNameOrURLString);
            if(XHISGIFTypeWithData(data)){
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                adImageView.animatedImage = image;
                adImageView.image = nil;
                __weak typeof(adImageView) w_adImageView = adImageView;
                adImageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if(configuration.GIFImageCycleOnce) [w_adImageView stopAnimating];
                };
            }else{
                adImageView.animatedImage = nil;
                adImageView.image = [UIImage imageWithData:data];
            }
            if ([self.delegate respondsToSelector:@selector(xhLaunchAd:imageDownLoadFinish:)]) {
                [self.delegate xhLaunchAd:self imageDownLoadFinish:[UIImage imageWithData:data]];
            }
        }else{
            XHLaunchAdLog(@"未设置广告图片");
        }
    }
    /** skipButton */
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    /** customView */
    if(configuration.subViews.count>0)  [self addSubViews:configuration.subViews];
    XHWeakSelf
    adImageView.click = ^(CGPoint point) {
        [weakSelf clickAndPoint:point];
    };
}

-(void)addSkipButtonForConfiguration:(XHLaunchAdConfiguration *)configuration{
    if(!configuration.duration) configuration.duration = 5;
    if(!configuration.skipButtonType) configuration.skipButtonType = SkipTypeTimeText;
    if(configuration.customSkipView){
        [_window addSubview:configuration.customSkipView];
    }else{
        if(_skipButton == nil){
            _skipButton = [[XHLaunchAdButton alloc] initWithSkipType:configuration.skipButtonType];
            _skipButton.hidden = YES;
            [_skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
        }
        [_window addSubview:_skipButton];
        [_skipButton setTitleWithSkipType:configuration.skipButtonType duration:configuration.duration];
    }
}

/**视频*/
-(void)setupVideoAdForConfiguration:(XHLaunchVideoAdConfiguration *)configuration{
    if(_window ==nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    if(!_adVideoView){
        _adVideoView = [[XHLaunchAdVideoView alloc] init];
    }
    [_window addSubview:_adVideoView];
    /** frame */
    if(configuration.frame.size.width>0&&configuration.frame.size.height>0) _adVideoView.frame = configuration.frame;
    if(configuration.scalingMode) _adVideoView.videoScalingMode = configuration.scalingMode;
    _adVideoView.videoCycleOnce = configuration.videoCycleOnce;
    /** video 数据源 */
    if(configuration.videoNameOrURLString.length && XHISURLString(configuration.videoNameOrURLString)){
        [XHLaunchAdCache async_saveVideoUrl:configuration.videoNameOrURLString];
        NSURL *pathURL = [XHLaunchAdCache getCacheVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString]];
        if(pathURL){
            if ([self.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadFinish:)]) {
                [self.delegate xhLaunchAd:self videoDownLoadFinish:pathURL];
            }
            _adVideoView.videoPlayer.contentURL = pathURL;
            [_adVideoView.videoPlayer prepareToPlay];
        }else{
            XHWeakSelf
            [[XHLaunchAdDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString] progress:^(unsigned long long total, unsigned long long current) {
                if ([weakSelf.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadProgress:total:current:)]) {
                    [weakSelf.delegate xhLaunchAd:self videoDownLoadProgress:current/(float)total total:total current:current];
                }
            }  completed:^(NSURL * _Nullable location, NSError * _Nullable error){
                if(!error){
                    if ([weakSelf.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadFinish:)]){
                        [weakSelf.delegate xhLaunchAd:self videoDownLoadFinish:location];
                    }
                }
            }];
            /***视频缓存,提前显示完成 */
            [self removeAndAnimateDefault]; return;
        }
    }else{
        if(configuration.videoNameOrURLString.length){
            NSString *path = [[NSBundle mainBundle]pathForResource:configuration.videoNameOrURLString ofType:nil];
            if(path.length){
                NSURL *pathURL = [NSURL fileURLWithPath:path];
                if ([self.delegate respondsToSelector:@selector(xhLaunchAd:videoDownLoadFinish:)]) {
                    [self.delegate xhLaunchAd:self videoDownLoadFinish:pathURL];
                }
                _adVideoView.videoPlayer.contentURL = pathURL;;
                [_adVideoView.videoPlayer prepareToPlay];
            }else{
                XHLaunchAdLog(@"Error:广告视频未找到,请检查名称是否有误!");
            }
        }else{
            XHLaunchAdLog(@"未设置广告视频");
        }
    }
    /** skipButton */
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    /** customView */
    if(configuration.subViews.count>0) [self addSubViews:configuration.subViews];
    XHWeakSelf
    _adVideoView.click = ^(CGPoint point) {
        [weakSelf clickAndPoint:point];
    };
}

#pragma mark - add subViews
-(void)addSubViews:(NSArray *)subViews{
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [_window addSubview:view];
    }];
}

#pragma mark - set
-(void)setImageAdConfiguration:(XHLaunchImageAdConfiguration *)imageAdConfiguration{
    _imageAdConfiguration = imageAdConfiguration;
    _launchAdType = XHLaunchAdTypeImage;
    [self setupImageAdForConfiguration:imageAdConfiguration];
}

-(void)setVideoAdConfiguration:(XHLaunchVideoAdConfiguration *)videoAdConfiguration{
    _videoAdConfiguration = videoAdConfiguration;
    _launchAdType = XHLaunchAdTypeVideo;
    [self setupVideoAdForConfiguration:videoAdConfiguration];
}

-(void)setWaitDataDuration:(NSInteger)waitDataDuration{
    _waitDataDuration = waitDataDuration;
    /** 数据等待 */
    [self startWaitDataDispathTiemr];
}

#pragma mark - Action
-(void)skipButtonClick{
    [self removeAndAnimated:YES];
}

-(void)removeAndAnimated:(BOOL)animated{
    if(animated){
        [self removeAndAnimate];
    }else{
        [self removeAndAnimateDefault];
    }
}

-(void)clickAndPoint:(CGPoint)point{
    self.clickPoint = point;
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
    if ([self.delegate respondsToSelector:@selector(xhLaunchAd:clickAndOpenURLString:clickPoint:)]) {
        [self.delegate xhLaunchAd:self clickAndOpenURLString:configuration.openURLString clickPoint:point];
        [self removeAndAnimateDefault];
    }else{
        if ([self.delegate respondsToSelector:@selector(xhLaunchAd:clickAndOpenURLString:)]) {
            [self.delegate xhLaunchAd:self clickAndOpenURLString:configuration.openURLString];
            [self removeAndAnimateDefault];
        }
    }
}

-(XHLaunchAdConfiguration *)commonConfiguration{
    XHLaunchAdConfiguration *configuration = nil;
    switch (_launchAdType) {
        case XHLaunchAdTypeVideo:
            configuration = _videoAdConfiguration;
            break;
        case XHLaunchAdTypeImage:
            configuration = _imageAdConfiguration;
            break;
        default:
            break;
    }
    return configuration;
}

-(void)startWaitDataDispathTiemr{
    __block NSInteger duration = defaultWaitDataDuration;
    if(_waitDataDuration) duration = _waitDataDuration;
    _waitDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    NSTimeInterval period = 1.0;
    dispatch_source_set_timer(_waitDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_waitDataTimer, ^{
        if(duration==0){
            DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:XHLaunchAdWaitDataDurationArriveNotification object:nil];
                [self removeAndAnimateDefault];
                return ;
            });
        }
        duration--;
    });
    dispatch_resume(_waitDataTimer);
}

-(void)startSkipDispathTimer{
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer);
    if(!configuration.skipButtonType) configuration.skipButtonType = SkipTypeTimeText;//默认
    __block NSInteger duration = 5;//默认
    if(configuration.duration) duration = configuration.duration;
    if(configuration.skipButtonType == SkipTypeRoundProgressTime || configuration.skipButtonType == SkipTypeRoundProgressText){
        [_skipButton startRoundDispathTimerWithDuration:duration];
    }
    NSTimeInterval period = 1.0;
    _skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_skipTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_skipTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(xhLaunchAd:customSkipView:duration:)]) {
                [self.delegate xhLaunchAd:self customSkipView:configuration.customSkipView duration:duration];
            }
            if(!configuration.customSkipView){
                [_skipButton setTitleWithSkipType:configuration.skipButtonType duration:duration];
            }
            if(duration==0){
                DISPATCH_SOURCE_CANCEL_SAFE(_skipTimer);
                [self removeAndAnimate]; return ;
            }
            duration--;
        });
    });
    dispatch_resume(_skipTimer);
}

-(void)removeAndAnimate{
    
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
    CGFloat duration = showFinishAnimateTimeDefault;
    if(configuration.showFinishAnimateTime>0) duration = configuration.showFinishAnimateTime;
    switch (configuration.showFinishAnimate) {
        case ShowFinishAnimateNone:{
            [self remove];
        }
            break;
        case ShowFinishAnimateFadein:{
            [self removeAndAnimateDefault];
        }
            break;
        case ShowFinishAnimateLite:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
                _window.transform = CGAffineTransformMakeScale(1.5, 1.5);
                _window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case ShowFinishAnimateFlipFromLeft:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                _window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case ShowFinishAnimateFlipFromBottom:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                _window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case ShowFinishAnimateCurlUp:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionCurlUp animations:^{
                _window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        default:{
            [self removeAndAnimateDefault];
        }
            break;
    }
}

-(void)removeAndAnimateDefault{
    XHLaunchAdConfiguration * configuration = [self commonConfiguration];
    CGFloat duration = showFinishAnimateTimeDefault;
    if(configuration.showFinishAnimateTime>0) duration = configuration.showFinishAnimateTime;
    [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionNone animations:^{
        _window.alpha = 0;
    } completion:^(BOOL finished) {
        [self remove];
    }];
}

-(void)remove{
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer)
    DISPATCH_SOURCE_CANCEL_SAFE(_skipTimer)
    REMOVE_FROM_SUPERVIEW_SAFE(_skipButton)
    if(_launchAdType==XHLaunchAdTypeVideo){
        if(_adVideoView==nil) return;
        [_adVideoView stopVideoPlayer];
        REMOVE_FROM_SUPERVIEW_SAFE(_adVideoView)
    }
    [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        REMOVE_FROM_SUPERVIEW_SAFE(obj)
    }];
    _window.hidden = YES;
    _window = nil;
    if ([self.delegate respondsToSelector:@selector(xhLaunchShowFinish:)]) {
        [self.delegate xhLaunchShowFinish:self];
    }
    if ([self.delegate respondsToSelector:@selector(xhLaunchAdShowFinish:)]) {
        [self.delegate xhLaunchAdShowFinish:self];
    }
}

-(void)removeSubViewsExceptLaunchAdImageView{
    [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj isKindOfClass:[XHLaunchImageView class]]){
            REMOVE_FROM_SUPERVIEW_SAFE(obj)
        }
    }];
}

@end
