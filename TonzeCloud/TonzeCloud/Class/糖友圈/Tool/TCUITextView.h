//
//  TCUITextView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/8/15.
//  Copyright © 2017年 tonze. All rights reserved.
//
//   https://github.com/lele8446/TextViewDemo

#import <UIKit/UIKit.h>


//记录插入文本的索引
#define SPECIAL_TEXT_NUM   @"specialTextNum"

@class TCUITextView;

@protocol TCUITextViewDelegate <NSObject>

@optional
/**
 *  CJUITextView输入了done的回调
 *  一般在self.textView.returnKeyType = UIReturnKeyDone;时执行该回调
 *
 *  @param textView
 *
 *  @return
 */
- (void)CJUITextViewEnterDone:(TCUITextView *)textView;

/**
 *  CJUITextView自动改变高度
 *
 *  @param textView
 *  @param size     改变高度后的size
 */
- (void)CJUITextView:(TCUITextView *)textView heightChanged:(CGRect)frame;

- (BOOL)textViewShouldBeginEditing:(TCUITextView *)textView;
- (BOOL)textViewShouldEndEditing:(TCUITextView *)textView;

- (void)textViewDidBeginEditing:(TCUITextView *)textView;
- (void)textViewDidEndEditing:(TCUITextView *)textView;

- (BOOL)textView:(TCUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(TCUITextView *)textView;

- (void)textViewDidChangeSelection:(TCUITextView *)textView;

- (BOOL)textView:(TCUITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);
- (BOOL)textView:(TCUITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0);

- (BOOL)textView:(TCUITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead");
- (BOOL)textView:(TCUITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead");

/**
 *  placeHoldLabel是否显示
 *
 *  @param textView
 *  @param hidden
 */
- (void)CJUITextView:(TCUITextView *)textView placeHoldLabelHidden:(BOOL)hidden;
/**
 *  光标移动
 *
 *  @param textView
 *  @param selectedRange
 */
- (void)CJUITextView:(TCUITextView *)textView changeSelectedRange:(NSRange)selectedRange;
@end

@interface TCUITextView : UITextView

@property (nonatomic, weak) id<TCUITextViewDelegate> myDelegate;
@property (nonatomic, copy, setter=setPlaceHoldString:)   NSString *placeHoldString;
@property (nonatomic, strong, setter=setPlaceHoldTextFont:) UIFont *placeHoldTextFont;
@property (nonatomic, strong, setter=setPlaceHoldTextColor:) UIColor *placeHoldTextColor;

/**
 *  placeHold提示内容Insets值(default (4, 4, 4, 4))
 */
@property (nonatomic, assign, setter=setPlaceHoldContainerInset:) UIEdgeInsets placeHoldContainerInset;

/**
 *  是否根据输入内容自动调整高度(default NO)
 */
@property (nonatomic, assign, setter=setAutoLayoutHeight:) BOOL autoLayoutHeight;
/**
 *  autoLayoutHeight为YES时的最大高度(default MAXFLOAT)
 */
@property (nonatomic, assign) CGFloat maxHeight;

/**
 *  插入文本的颜色(default self.textColor)
 */
@property (nonatomic, strong, getter=getSpecialTextColor) UIColor *specialTextColor;

/**
 *  插入文本是否可编辑(default NO)
 */
@property (nonatomic, assign) BOOL enableEditInsterText;

/**
 *  在指定位置插入字符，并返回插入字符后的SelectedRange值
 *
 *  @param specialText    要插入的字符
 *  @param selectedRange  插入位置
 *  @param attributedText 插入前的文本
 *
 *  @return 插入字符后的光标位置
 */
- (NSRange)insterSpecialTextAndGetSelectedRange:(NSAttributedString *)specialText
                                  selectedRange:(NSRange)selectedRange
                                           text:(NSAttributedString *)attributedText;

/**
 * dealloc方法时，主动移除CJUITextView内部的相关KVO监测
 * 请在该 CJUITextView 所在的 父view 或者 ViewController 中的 dealloc 方法中调用
 * 注意!!!  iOS9以下系统必须调用，不然会crash !!!
 * 注意!!!  iOS9以下系统必须调用，不然会crash !!!
 * 注意!!!  iOS9以下系统必须调用，不然会crash !!!
 */
- (void)removeObserver;

@end

