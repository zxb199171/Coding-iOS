//
//  TaskActivityCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kTaskActivityCell_LeftContentPading (kPaddingLeftWidth + 40)
#define kTaskActivityCell_ContentWidth (kScreen_Width - kTaskActivityCell_LeftContentPading - kPaddingLeftWidth)

#import "TaskActivityCell.h"

@interface TaskActivityCell ()
@property (strong, nonatomic) UIImageView *tipIconView, *timeLineView;
@property (strong, nonatomic) UILabel *contentLabel;
@end

@implementation TaskActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_timeLineView) {
            _timeLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, 1)];
            [_timeLineView setImage:[UIImage imageNamed:@"timeline_line_read"]];
            [self.contentView addSubview:_timeLineView];
        }
        if (!_tipIconView) {
            CGFloat borderWidth = 2;
            _tipIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth - borderWidth, 10, 28 + 2*borderWidth, 28 + 2*borderWidth)];
            _tipIconView.contentMode = UIViewContentModeCenter;
            
            _tipIconView.layer.masksToBounds = YES;
            _tipIconView.layer.cornerRadius = _tipIconView.frame.size.width/2;
            _tipIconView.layer.borderWidth = borderWidth;
            _tipIconView.layer.borderColor = kColorTableBG.CGColor;
            
            [self.contentView addSubview:_tipIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kTaskActivityCell_LeftContentPading, 13, kTaskActivityCell_ContentWidth, 15)];
            _contentLabel.numberOfLines = 0;
            [self.contentView addSubview:_contentLabel];
        }
    }
    return self;
}


- (void)setCurActivity:(ProjectActivity *)curActivity{
    _curActivity = curActivity;
    if (!_curActivity) {
        return;
    }
    NSString *tipIconImageName;
    if ([curActivity.target_type isEqualToString:@"Task"]) {
        tipIconImageName = [NSString stringWithFormat:@"task_activity_icon_%@", _curActivity.action];
    }else if ([curActivity.target_type isEqualToString:@"ProjectFile"]){
        tipIconImageName = [NSString stringWithFormat:@"file_activity_icon_%@", _curActivity.action];
    }
    _tipIconView.image = [UIImage imageNamed:tipIconImageName];
    NSAttributedString *attrContent = [[self class] attrContentWithObj:_curActivity];
    CGFloat contentHeight = [attrContent boundingRectWithSize:CGSizeMake(kTaskActivityCell_ContentWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    [self.contentLabel setHeight:contentHeight];
    self.contentLabel.attributedText = attrContent;
}

- (void)configTop:(BOOL)isTop andBottom:(BOOL)isBottom{
    if (isTop && isBottom) {
        _timeLineView.hidden = YES;
    }else{
        _timeLineView.hidden = NO;
        [_timeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(2.0);
            make.centerX.equalTo(_tipIconView);
            make.top.equalTo(isTop? _tipIconView.mas_centerY: self.contentView);
            make.bottom.equalTo(isBottom? _tipIconView.mas_centerY: self.contentView);
        }];
    }
}

+ (NSAttributedString *)attrContentWithObj:(ProjectActivity *)curActivity{
    if (![curActivity.target_type isEqualToString:@"Task"]) {
        return nil;
    }

    NSString *userName, *contentStr;
    userName = curActivity.user.name? curActivity.user.name: @"";
    NSMutableAttributedString *attrContent;
    
    if ([curActivity.action isEqualToString:@"create"]) {
        contentStr = [NSString stringWithFormat:@"创建了任务 - %@", [curActivity.created_at stringDisplay_HHmm]];
    }else if ([curActivity.action isEqualToString:@"update"]) {
        contentStr = [NSString stringWithFormat:@"更新了任务 - %@", [curActivity.created_at stringDisplay_HHmm]];
    }else if ([curActivity.action isEqualToString:@"update_priority"]) {
        contentStr = [NSString stringWithFormat:@"更新了任务优先级为 「%@」 - %@", kTaskPrioritiesDisplay[curActivity.task.priority.intValue], [curActivity.created_at stringDisplay_HHmm]];
    }else if ([curActivity.action isEqualToString:@"update_deadline"]) {
        if (curActivity.task.deadline_date) {
            contentStr = [NSString stringWithFormat:@"更新了任务截止日期为 「%@」 - %@", [NSDate convertStr_yyyy_MM_ddToDisplay:curActivity.task.deadline], [curActivity.created_at stringDisplay_HHmm]];
        }else{
            contentStr = [NSString stringWithFormat:@"移除了任务的截止日期 - %@", [curActivity.created_at stringDisplay_HHmm]];
        }
    }else if ([curActivity.action isEqualToString:@"update_description"]) {
        contentStr = [NSString stringWithFormat:@"更新了任务描述 - %@", [curActivity.created_at stringDisplay_HHmm]];
    }else if ([curActivity.action isEqualToString:@"update_label"]) {
        contentStr = [NSString stringWithFormat:@"更新了任务标签为 - %@", [[curActivity.labels valueForKey:@"name"] componentsJoinedByString:@","]];
    }else if ([curActivity.action isEqualToString:@"reassign"]) {
        contentStr = [NSString stringWithFormat:@"重新指派了任务给了 「%@」 - %@", curActivity.task.owner.name, [curActivity.created_at stringDisplay_HHmm]];
    }else if ([curActivity.action isEqualToString:@"finish"]) {
        contentStr = [NSString stringWithFormat:@"完成了任务 - %@", [curActivity.created_at stringDisplay_HHmm]];
    }else if ([curActivity.action isEqualToString:@"restore"]) {
        contentStr = [NSString stringWithFormat:@"重新开启了任务 - %@", [curActivity.created_at stringDisplay_HHmm]];
    }else if ([curActivity.action isEqualToString:@"commit_refer"]) {
        contentStr = [NSString stringWithFormat:@"在分支 %@ 中提交的代码提到了任务 - %@\n%@", curActivity.commit.ref, [curActivity.created_at stringDisplay_HHmm], curActivity.commit.contentStr];
    }else{
        contentStr = @"...";
    }
    
    attrContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", userName, contentStr]];
    [attrContent addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13],
                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]}
                        range:NSMakeRange(0, userName.length)];
    [attrContent addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],
                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x999999"]}
                        range:NSMakeRange(userName.length + 1, contentStr.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.minimumLineHeight = 18;
    
    [attrContent addAttribute:NSParagraphStyleAttributeName
                          value:paragraphStyle
                          range:NSMakeRange(0, [attrContent length])];
    return attrContent;
}


+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectActivity class]]) {
        NSAttributedString *attrContent = [self  attrContentWithObj:obj];
        CGFloat contentHeight = [attrContent boundingRectWithSize:CGSizeMake(kTaskActivityCell_ContentWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        cellHeight = ceilf(contentHeight + 26);
        cellHeight = MAX(44, cellHeight);
    }
    return cellHeight;
}
@end
