//
//  MyLayerViewController.m
//  EVNCamera
//
//  Created by developer on 2017/7/25.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

#import "MyLayerViewController.h"

@interface MyLayerViewController ()
{
    CGFloat currentWidth;
}
@end

@implementation MyLayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentWidth = 50;
    [self drawMyLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawMyLayer
{
    CGSize size = [[UIScreen mainScreen] bounds].size;

    // 获得跟视图Layer
    CALayer *layer = [[CALayer alloc] init];
    // 设置背景颜色
    layer.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0].CGColor;
    // 设置中心点
    layer.position = CGPointMake(size.width/2, size.height/2.f);
    // 设置大小
    layer.bounds = CGRectMake(0, 0, currentWidth, currentWidth);

    // 设置半角
    layer.cornerRadius = currentWidth/2;
    // 设置阴影
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowOpacity = 0.9;

    [self.view.layer addSublayer:layer];

}

    // 点击放大
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CALayer *layer = [self.view.layer.sublayers lastObject];
    CGFloat width = layer.bounds.size.width;
    if (width == currentWidth)
    {
        width = currentWidth*4;
    }
    else
    {
        width = currentWidth;
    }
    layer.bounds = CGRectMake(0, 0, width, width);
    layer.position = [touch locationInView:self.view];
    NSLog(@"x=%lf, y=%lf", layer.position.x, layer.position.y);
    layer.cornerRadius = width/2;
}

@end
