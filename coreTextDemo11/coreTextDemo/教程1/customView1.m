//
//  customView1.m
//  coreTextDemo
//
//  Created by zhouwude on 16/1/7.
//  Copyright © 2016年 zhouwude. All rights reserved.
//

#import "customView1.h"
#import <CoreText/CoreText.h>
@implementation customView1

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
/*
 
 
 */
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    /*首先不得不说 苹果编程中的坐标系花样百出，经常让开发者措手不及。 传统的Mac中的坐标系的原点在左下角，比如NSView默认的坐标系，原点就在左下角。但Mac中有些View为了其实现的便捷将原点变换到左上角，像NSTableView的坐标系坐标原点就在左上角。iOS UIKit的UIView的坐标系原点在左上角。
     往底层看，Core Graphics的context使用的坐标系的原点是在左下角。而在iOS中的底层界面绘制就是通过Core Graphics进行的，那么坐标系列是如何变换的呢？ 在UIView的drawRect方法中我们可以通过UIGraphicsGetCurrentContext()来获得当前的Graphics Context。drawRect方法在被调用前，这个Graphics Context被创建和配置好，你只管使用便是。如果你细心，通过CGContextGetCTM(CGContextRef c)可以看到其返回的值并不是CGAffineTransformIdentity，通过打印出来看到值为
     
     这是非retina分辨率下的结果，如果是如果是retina上面的a,d,ty的值将会乘2，如果是iPhone 5，ty的值会再大些。 但是作用都是一样的就是将上下文空间坐标系进行了flip，使得原本左下角原点变到左上角，y轴正方向也变换成向下。
     
     Printing description of contextCTM:
     (CGAffineTransform) contextCTM = {
     a = 1
     b = 0
     c = 0
     d = -1
     tx = 0
     ty = 460
     }
     */
    
    UIFont *font =[UIFont systemFontOfSize:18];
    /*(lldb) po font.familyName
     .SF UI Text
     
     (lldb) po font.fontName
     .SFUIText-Regular
     
     (lldb) po font.pointSize
     18
     
     (lldb) po font.ascender
     17.138671875
     
     (lldb) po font.descender
     -4.341796875
     
     (lldb) po font.capHeight
     12.6826171875
     
     (lldb) po font.xHeight
     9.474609375
     
     (lldb) po font.lineHeight
     21.48046875
     
     (lldb) po font.leading(linegap)
     0
     
     (lldb)
     
     bounding box（边界框 bbox），这是一个假想的框子，它尽可能紧密的装入字形。
     baseline（基线），一条假想的线,一行上的字形都以此线作为上下位置的参考，在这条线的左侧存在一个点叫做基线的原点，
     ascent（上行高度）从原点到字体中最高（这里的高深都是以基线为参照线的）的字形的顶部的距离，ascent是一个正值
     descent（下行高度）从原点到字体中最深的字形底部的距离，descent是一个负值（比如一个字体原点到最深的字形的底部的距离为2，那么descent就为-2）
     linegap（行距），linegap也可以称作leading（其实准确点讲应该叫做External leading）,行高lineHeight则可以通过 ascent + |descent| + linegap 来计算。*/
    
    CGAffineTransform form=   CGContextGetCTM(UIGraphicsGetCurrentContext());
    NSLog(@" %@------%@",NSStringFromCGAffineTransform(CGAffineTransformIdentity),NSStringFromCGAffineTransform(form));
    //2016-01-07 17:37:51.398 coreTextDemo[18751:348868]  [1, 0, 0, 1, 0, 0]------[3, 0, 0, -3, 0, 2208]
    // 1.获取上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    /*上面说了一大堆，下面进入正题，Core Text一开始便是定位于桌面的排版系统，使用了传统的原点在左下角的坐标系，所以它在绘制文本的时候都是参照左下角的原点进行绘制的。 但是iOS的UIView的drawRect方法的context被做了次flip，如果你啥也不做处理，直接在这个context上进行Core Text绘制，你会发现文字是镜像且上下颠倒。 */
    // [a,b,c,d,tx,ty]
    NSLog(@"转换前的坐标：%@",NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));
    
    // 2.转换坐标系,CoreText的原点在左下角，UIKit原点在左上角 它可以用来为每一个显示的字形单独设置变形矩阵
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    
    // 这两种转换坐标的方式效果一样 上面的方法更直观
    // 2.1
    // CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    // CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    // 2.2
    CGContextConcatCTM(contextRef, CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height));
    
    NSLog(@"转换后的坐标：%@",NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));
    
    
    // 3.创建绘制区域，可以对path进行个性化裁剪以改变显示区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // CGPathAddEllipseInRect(path, NULL, self.bounds);
    
    // 4.创建需要绘制的文字
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:@"这是我的第一个coreText demo，我是要给兵来自老白干I型那个饿哦个呢给个I类回滚igkhpwfh 评估后共和国开不开vbdkaphphohghg 的分工额好几个辽宁省更怕hi维护你不看hi好人佛【井柏然把饿哦个"];
    
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 5)];
    
    // 两种方式皆可
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, 10)];
    [attributed addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 2)];
    
    // 设置行距等样式
    CGFloat lineSpace = 10; // 行距一般取决于这个值
    CGFloat lineSpaceMax = 20;
    CGFloat lineSpaceMin = 2;
    const CFIndex kNumberOfSettings = 3;
    
    // 结构体数组
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpaceMax},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpaceMin}
        
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    // 单个元素的形式
    // CTParagraphStyleSetting theSettings = {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace};
    // CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(&theSettings, kNumberOfSettings);
    
    // 两种方式皆可
    // [attributed addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:NSMakeRange(0, attributed.length)];
    
    // 将设置的行距应用于整段文字
    [attributed addAttribute:NSParagraphStyleAttributeName value:(__bridge id)(theParagraphRef) range:NSMakeRange(0, attributed.length)];
    
    CFRelease(theParagraphRef);
    
    
    // 5.根据NSAttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, NULL);
    
    // 6.绘制除图片以外的部分
    CTFrameDraw(ctFrame, contextRef);
    CGPathRef path1 = CTFrameGetPath(ctFrame);
    
    CGRect rect1 = CGPathGetBoundingBox(path1);
    CGRect rect12 = CGPathGetPathBoundingBox(path1);
    // 7.内存管理，ARC不能管理CF开头的对象，需要我们自己手动释放内存
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(ctFrame);
    
    
}

@end
