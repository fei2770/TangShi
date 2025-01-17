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

#import "EaseMessageTimeCell.h"

CGFloat const EaseMessageTimeCellPadding = 5;

@interface EaseMessageTimeCell()

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation EaseMessageTimeCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseMessageTimeCell *cell = [self appearance];
    cell.titleLabelColor = [UIColor grayColor];
    cell.titleLabelFont = [UIFont systemFontOfSize:12];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self _setupSubview];
    }
    
    return self;
}

#pragma mark - setup subviews

- (void)_setupSubview
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor bgColor_Gray];
    _titleLabel.layer.cornerRadius=3;
    _titleLabel.clipsToBounds=YES;
    _titleLabel.textColor = _titleLabelColor;
    _titleLabel.font = _titleLabelFont;
    [self.contentView addSubview:_titleLabel];
}



#pragma mark - setter

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
    
    CGFloat titleWidth=[title boundingRectWithSize:CGSizeMake(kScreenWidth, 30) withTextFont:self.titleLabelFont].width;
    _titleLabel.frame=CGRectMake((kScreenWidth-floor(titleWidth)-10)/2, 5, floor(titleWidth)+10, 25);

}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont
{
    _titleLabelFont = titleLabelFont;
    _titleLabel.font = _titleLabelFont;
}

- (void)setTitleLabelColor:(UIColor *)titleLabelColor
{
    _titleLabelColor = titleLabelColor;
    _titleLabel.textColor = _titleLabelColor;
}

#pragma mark - public

+ (NSString *)cellIdentifier
{
    return @"MessageTimeCell";
}

@end
