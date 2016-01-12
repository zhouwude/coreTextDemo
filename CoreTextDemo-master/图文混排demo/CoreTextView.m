//
//  CoreTextView.m
//  图文混排demo
//
//  Created by 敬洁 on 15/2/11.
//  Copyright (c) 2015年 JingJ. All rights reserved.
//
/*CoreText是基于IOS3.2及OSX10.5的用于文字精细排版的文本框架。它直接与Core Graphics（又称：Quartz）交互，将需要显示的文本内容，位置，字体，字形直接传递给Quartz，与其他UI组件相比，能更高效的进行渲染。
 二、CoreText与UIWebView在排版方面的优劣比较
 
 UIWebView也常用于处理复杂的排版，对应排版他们之间的优劣如下（摘自 《iOS开发进阶》—— 唐巧）:
 CoreText占用的内容更少，渲染速度更快。UIWebView占用的内存多，渲染速度慢。
 CoreText在渲染界面的前就可以精确地获得显示内容的高度（只要有了CTFrame即可），而WebView只有渲染出内容后，才能获得内容的高度（而且还需要用JavaScript代码来获取）。
 CoreText的CTFrame可以在后台线程渲染，UIWebView的内容只能在主线程（UI线程）渲染。
 基于CoreText可以做更好的原生交互效果，交互效果可以更加细腻。而UIWebView的交互效果都是用JavaScript来实现的，在交互效果上会有一些卡顿的情况存在。例如，在UIWebView下，一个简单的按钮按下的操作，都无法做出原生按钮的即时和细腻的按下效果。
 CoreText排版的劣势：
 CoreText渲染出来的内容不能像UIWebView那样方便地支持内容的复制。
 基于CoreText来排版需要自己处理很多复制的逻辑，例如需要自己处理图片与文字混排相关的逻辑，也需要自己实现连接点击操作的支持。
 在业界有很多应用都采用CoreText技术进行排版，例如新浪微博客户端，多看阅读客户端，猿题库等等。
 
 上诉代码的步骤2对绘图的坐标系进行了处理，因为在iOS UIKit中，UIView是以左上角为原点，而Core Text一开始的定位是使用与桌面应用的排版系统，桌面应用的坐标系是以左下角为原点，即Core Text在绘制的时候也是参照左下角为原点进行绘制的，所以需要对当前的坐标系进行处理。
 实际上，Core Graphic 中的context也是以左下角为原点的， 但是为什么我们用Core Graphic 绘制一些简单的图形的时候不需要对坐标系进行处理喃，是因为通过这个方法UIGraphicsGetCurrentContext()来获得的当前context是已经被处理过的了，用下面方法可以查看指定的上下文的当前图形状态变换矩阵。
 
 NSLog(@"当前context的变换矩阵 %@", NSStringFromCGAffineTransform(CGContextGetCTM(context)));
 打印结果为[2, 0, 0, -2, 0, 654]，可以发现变换矩阵与CGAffineTransformIdentity的值[1, 0, 0, 1, 0, 0]是不相同的，并且与设备是否为Retina屏和设备尺寸相关。他的作用是将上下文空间坐标系进行翻转，并使原来的左下角原点变成右上角是原点，并将向上为正y轴变为向下为正y轴。 所以在使用drawRect的时候，当前的context已经被做了一次翻转，如果不对当前的坐标系进行处理，会发现，绘制出来的文字是镜像上下颠倒的
 
 
 
 
 
 
 我们来解释一下这些类：
 CFAttributedStringRef ：属性字符串，用于存储需要绘制的文字字符和字符属性
 CTFramesetterRef：通过CFAttributedStringRef进行初始化，作为CTFrame对象的生产工厂，负责根据path创建对应的CTFrame
 CTFrame：用于绘制文字的类，可以通过CTFrameDraw函数，直接将文字绘制到context上
 CTLine：在CTFrame内部是由多个CTLine来组成的，每个CTLine代表一行
 CTRun：每个CTLine又是由多个CTRun组成的，每个CTRun代表一组显示风格一致的文本
 实际上CoreText是不直接支持绘制图片的，但是我们可以先在需要显示图片的地方用一个特殊的空白占位符代替，同时设置该字体的CTRunDelegate信息为要显示的图片的宽度和高度，这样绘制文字的时候就会先把图片的位置留出来，再在drawRect方法里面用CGContextDrawImage绘制图片。
 
 */

#import "CoreTextView.h"
#import <CoreText/CoreText.h>

@implementation CoreTextView

#pragma - 简单的绘制一些文字
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    // 步骤1：得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上
    // 因为Core Text要配合Core Graphic 配合使用的，如Core Graphic一样，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    // 步骤2：翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕坐下角为（0，0））
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 步骤3：创建绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, self.bounds);
    
    
    // 步骤4：创建需要绘制的文字与计算需要绘制的区域
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"iOS程序在启动时会创建一个主线程，而在一个线程只能执行一件事情，如果在主线程执行某些耗时操作，例如加载网络图片，下载资源文件等会阻塞主线程（导致界面卡死，无法交互），所以就需要使用多线程技术来避免这类情况。iOS中有三种多线程技术 NSThread，NSOperation，GCD，这三种技术是随着IOS发展引入的，抽象层次由低到高，使用也越来越简单。"];
    
    // 步骤8：设置部分文字颜色
    [attrString addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10, 10)];
    
    // 设置部分文字字体
    CGFloat fontSize = 20;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    [attrString addAttribute:(id)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(15, 10)];
    CFRelease(fontRef);
    
    // 设置行间距
    /*kCTParagraphStyleSpecifierAlignment = 0,                 //对齐属性
     kCTParagraphStyleSpecifierFirstLineHeadIndent = 1,       //首行缩进
     kCTParagraphStyleSpecifierHeadIndent = 2,                //段头缩进
     kCTParagraphStyleSpecifierTailIndent = 3,                //段尾缩进
     kCTParagraphStyleSpecifierTabStops = 4,                  //制表符模式
     kCTParagraphStyleSpecifierDefaultTabInterval = 5,        //默认tab间隔
     kCTParagraphStyleSpecifierLineBreakMode = 6,             //换行模式
     kCTParagraphStyleSpecifierLineHeightMultiple = 7,        //多行高
     kCTParagraphStyleSpecifierMaximumLineHeight = 8,         //最大行高
     kCTParagraphStyleSpecifierMinimumLineHeight = 9,         //最小行高
     kCTParagraphStyleSpecifierLineSpacing = 10,              //行距
     kCTParagraphStyleSpecifierParagraphSpacing = 11,         //段落间距  在段的未尾（Bottom）加上间隔，这个值为负数。
     kCTParagraphStyleSpecifierParagraphSpacingBefore = 12,   //段落前间距 在一个段落的前面加上间隔。TOP
     kCTParagraphStyleSpecifierBaseWritingDirection = 13,     //基本书写方向
     kCTParagraphStyleSpecifierMaximumLineSpacing = 14,       //最大行距
     kCTParagraphStyleSpecifierMinimumLineSpacing = 15,       //最小行距
     kCTParagraphStyleSpecifierLineSpacingAdjustment = 16,    //行距调整
     kCTParagraphStyleSpecifierCount = 17,        // 
     
     
     对齐属性：
     kCTLeftTextAlignment = 0,                //左对齐
     kCTRightTextAlignment = 1,               //右对齐
     kCTCenterTextAlignment = 2,              //居中对齐
     kCTJustifiedTextAlignment = 3,           //文本对齐
     kCTNaturalTextAlignment = 4              //自然文本对齐
     段落默认样式为
     kCTNaturalTextAlignment
     
     
     换行模式：
     kCTLineBreakByWordWrapping = 0,        //出现在单词边界时起作用，如果该单词不在能在一行里显示时，整体换行。此为段的默认值。
     kCTLineBreakByCharWrapping = 1,        //当一行中最后一个位置的大小不能容纳一个字符时，才进行换行。
     kCTLineBreakByClipping = 2,            //超出画布边缘部份将被截除。
     kCTLineBreakByTruncatingHead = 3,      //截除前面部份，只保留后面一行的数据。前部份以...代替。
     kCTLineBreakByTruncatingTail = 4,      //截除后面部份，只保留前面一行的数据，后部份以...代替。
     kCTLineBreakByTruncatingMiddle = 5     //在一行中显示段文字的前面和后面文字，中间文字使用...代替。
     
     
     */
    CGFloat lineSpacing = 10;
    
    
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    [attrString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:NSMakeRange(0, attrString.length)];
    CFRelease(theParagraphRef);
    
    
    // 步骤9：图文混排部分
    // CTRunDelegateCallbacks：一个用于保存指针的结构体，由CTRun delegate进行回调
    CTRunDelegateCallbacks callbacks;
    //对结构体数据清零
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;

    // 图片信息字典
    NSDictionary *imgInfoDic = @{@"width":@100,@"height":@30};

    // 设置CTRun的代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)imgInfoDic);

    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);

    // 将创建的空白AttributedString插入进当前的attrString中，位置可以随便指定，不能越界
    [attrString insertAttributedString:space atIndex:50];

    
    // 步骤5：根据AttributedString生成CTFramesetterRef
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [attrString length]), path, NULL);
    
    
    // 步骤6：进行绘制
    CTFrameDraw(frame, context);
    
    // 步骤10：绘制图片
    UIImage *image = [UIImage imageNamed:@"coretext-img-1.png"];
    CGContextDrawImage(context, [self calculateImagePositionInCTFrame:frame], image.CGImage);
    
    
    // 步骤7.内存管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
    
}

#pragma mark - CTRun delegate 回调方法
static CGFloat ascentCallback(void *ref) {
    
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    
    return 0;
}

static CGFloat widthCallback(void *ref) {
    
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}

/**
 *  根据CTFrameRef获得绘制图片的区域
 *
 *  @param ctFrame CTFrameRef对象
 *
 *  @return 绘制图片的区域
 */
- (CGRect)calculateImagePositionInCTFrame:(CTFrameRef)ctFrame {
    
    // 获得CTLine数组
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    // 遍历每个CTLine
    for (NSInteger i = 0 ; i < lineCount; i++) {
        
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        
        // 遍历每个CTLine中的CTRun
        for (id runObj in runObjArray) {
            
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            return delegateBounds;
        }
    }
    return CGRectZero;
}

@end

