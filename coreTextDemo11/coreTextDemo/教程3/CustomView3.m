//
//  CustomView3.m
//  coreTextDemo
//
//  Created by zhouwude on 16/1/11.
//  Copyright © 2016年 zhouwude. All rights reserved.
//

#import "CustomView3.h"
@import CoreText;
@implementation CustomView3
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    /*本篇文章为CoreText系列的第三篇，讨论下纯文本排版的一些细节，会有中文，英文，数字以及emoji表情。主要涉及到使用CTLineDraw来一行一行的绘制，而非之前CTFrameDraw一气呵成，因为CTFrameDraw会因为行高不一致导致排版不美观，CTLineDraw尽管依然存在行高不一致的问题，但却可指定每行的行高保持一致以使得排版相对美观，毕竟，英文和中文字符的ascent，descent本来就不一样。
     
     使用CTLineDraw来一行一行的绘制时，最重要的就是在绘制前设置CoreText的坐标的Y值，这也是本文的重点所在。
     在设置坐标时，需要注意的是，CoreText的origin是在图中的baseLine处的。
     
     分行绘制的原理主要就是从CTFrame中获得每一个CTLine对象，并针对每一个CTLine设置好该行的坐标，然后利用CTLineDraw函数进行绘制。
     
     主要使用到的函数为：
     
     CTFrameGetLines，传入CTFrame，返回一个装有多个CTLine对象的数组。
     
     CTFrameGetLineOrigins，传入CTFrame，CFRange，和一个CGPoint的结构体数组指针，该函数会把每一个CTLine的origin坐标写到数组里。
     
     CGContextSetTextPosition，设置CoreText绘制前的坐标。
     
     CTLineDraw，绘制CTLine。
     
     我这里分了两种实现方式
*/
 //第一种只按照系统的方式来排版
   // 自己设定一个行间距之后不去理会行高，每一个CTLine直接绘制.其实就相当于把CTFrameDraw要做的事情分步来实现而已。
    
    
    /**
     *  高度 = 每行的asent + 每行的descent + 行数*行间距
     *  行间距为指定的数值
     *  对应第三篇博文
     */
  
    
    //代码见 另一个demo
    
    
}
/**
 *  高度 = 每行的asent + 每行的descent + 行数*行间距
 *  行间距为指定的数值
 *  对应第三篇博文
 */
@end
