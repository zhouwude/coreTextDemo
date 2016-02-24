//
//  ViewController.m
//  coreTextDemo
//
//  Created by zhouwude on 16/1/7.
//  Copyright © 2016年 zhouwude. All rights reserved.
//

#import "ViewController.h"
#import "customView1.h"
#import "CustomView2.h"
#import  <objc/runtime.h>
#import  <objc/message.h>
@interface ViewController ()

@end
@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    customView1 *view = [[customView1 alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:view];
    CustomView2 *view = [[CustomView2 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    //view.backgroundColor = [UIColor whiteColor];
    view.backgroundColor = [UIColor colorWithRed:0.0028 green:1.0 blue:0.0044 alpha:0.395770474137931];
    //[self performSelector:@selector(hehe)];

    
    /*本次CoreText教程为一个系列，大概总共分4-5篇博文来叙述，内容分布为：
     
     第一篇介绍CoreText的一些基础知识和绘制流程，仅绘制纯文本内容，且不去讲究排版的细节，先画出来为主。
     
     第二篇进行图文混排，有本地图片和网络图片两种形式，文本部分保持跟第一篇博文一致。
     
     第三篇仔细探究纯文本的排版，包括中文，英文，数字和表情。对齐与不对齐的文本排版区别。
     
     第四篇讨论文本字符行数超过可以显示的行数时，在最后加省略号的问题。
     
     第五篇介绍使用正则表达式识别人名、电话，对用户点击人名、电话做出响应。
     
     对图片点击的识别，其实原理差不多，《iOS开发进阶》里边讲的更清楚。
     
     本篇教程为第一篇，仅实现在一个UIView的子控件上绘制纯文本。
     
     学习CoreText需要有一些基础知识储备，关于字符和字形的知识请点击这里以及这里。另外还需要对NSAttributedString有一些了解，CoreText对文本和图片的绘制就是依赖于NSAttributedString属性字符串的。
     
*/

    // Do any additional setup after loading the view, typically from a nib.
}
//+(BOOL)resolveInstanceMethod:(SEL)sel{
////    SEL select = sel;
////    SEL sel1 = @selector(hehe);
////    if(select == sel1){
//////        class_addMethod([self class], sel, , <#const char *types#>)
////        return YES;
////    }
//
//    return [super resolveClassMethod:sel];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
