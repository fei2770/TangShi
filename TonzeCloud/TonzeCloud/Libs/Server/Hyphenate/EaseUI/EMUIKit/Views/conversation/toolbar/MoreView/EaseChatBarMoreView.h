/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

typedef enum{
    EMChatToolbarTypeChat,
    EMChatToolbarTypeGroup,
}EMChatToolbarType;

@protocol EaseChatBarMoreViewDelegate;
@interface EaseChatBarMoreView : UIView

@property (nonatomic,assign) id<EaseChatBarMoreViewDelegate> delegate;

@property (nonatomic) UIColor *moreViewBackgroundColor UI_APPEARANCE_SELECTOR;  //moreview背景颜色,default whiteColor

/*
 
 */
- (instancetype)initWithFrame:(CGRect)frame type:(EMChatToolbarType)type;


@end

@protocol EaseChatBarMoreViewDelegate <NSObject>

@optional

/*!
  @method
  @brief 拍照
  @discussion
  @param moreView 功能view
  @result
  */
- (void)moreViewTakePicAction:(EaseChatBarMoreView *)moreView;

/*!
 @method
 @brief 相册
 @discussion
 @param moreView 功能view
 @result
 */
- (void)moreViewPhotoAction:(EaseChatBarMoreView *)moreView;

/*!
 @method
 @brief 发送位置
 @discussion
 @param moreView 功能view
 @result
 */
- (void)moreViewLocationAction:(EaseChatBarMoreView *)moreView;

/*!
 @method
 @brief 拨打实时语音
 @discussion
 @param moreView 功能view
 @result
 */
- (void)moreViewAudioCallAction:(EaseChatBarMoreView *)moreView;

/*!
 @method
 @brief 拨打实时通话
 @discussion
 @param moreView 功能view
 @result
 */
- (void)moreViewVideoCallAction:(EaseChatBarMoreView *)moreView;

/*!
 @method
 @brief 自定义功能
 @discussion
 @param moreView    功能view
 @param index       按钮索引
 @result
 */
- (void)moreView:(EaseChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index;

@end
