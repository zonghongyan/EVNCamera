//
//  EVNCameraWarnView.m
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2020 仁伯. All rights reserved.
//

#import "EVNCameraWarnView.h"
#import "Masonry.h"
#import "UIColor+EVNExt.h"

@interface EVNCameraWarnView ()

/// 标题
@property (nonatomic, strong) UILabel *titleLab;
/// 描述信息
@property (nonatomic, strong) UILabel *detailLab;


@end
@implementation EVNCameraWarnView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.titleLab];
    [self addSubview:self.detailLab];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.titleLab.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@20);
    }];
}

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _titleLab.text = @"请在照片中包含以下信息：";
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UILabel *)detailLab
{
    if (!_detailLab)
    {
        _detailLab = [[UILabel alloc] init];
        _detailLab.font = [UIFont systemFontOfSize:12];
        _detailLab.textColor = [UIColor colorWithHexString:@"#ffffff"];
//        _detailLab.text = @"❶ ① XXXXXX ❷   ② YYYYYYYY";
        _detailLab.text = @"❶ XXXXXX    ❷ YYYYYYYY";
        _detailLab.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLab;
}

@end
