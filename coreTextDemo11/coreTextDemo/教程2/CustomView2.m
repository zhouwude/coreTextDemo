//
//  CustomView2.m
//  coreTextDemo
//
//  Created by zhouwude on 16/1/11.
//  Copyright © 2016年 zhouwude. All rights reserved.
//

#import "CustomView2.h"
#import <SDWebImageManager.h>
@import CoreText;
/*本篇文章为CoreText系列的第二篇，在一个UIView的子控件上实现图文混排显示，支持本地图片和网络图片的显示，暂时不支持图片的点击监听功能。
 
 CoreText从绘制纯文本到绘制图片，依然是使用NSAttributedString，只不过图片的实现方式是用一个空白字符作为在NSAttributedString中的占位符，然后设置代理，告诉CoreText给该占位字符留出一定的宽高。最后把图片绘制到预留的位置上。
 
 本文实现了同时绘制本地图片和网络图片。大体思路是，网络图片还未下载时，先使用该图片的占位图片进行绘制（为了方便，占位图直接使用了另一张本地图片），然后使用SDWebImage框架提供的下载功能去下载网络图片，等下载完成时，调用UIView的setNeedDisplay方法进行重绘即可。
 
 需要注意的一点就是，对于本地图片，是可以直接拿到其宽高数据的，对于网络的图片，在下载完成之前不知道其宽高，我们往往会采取在其URL后边拼接上宽高信息的方式来处理。
 
 绘制过程见下图
 
 网络图片还未下载完成时的效果：*/
@implementation CustomView2


#pragma mark 图片代理
//图片的代理方法里主要是区别了本地图片和网络图片的宽高返回方式。本地图片因为在内存里可以直接读取，网络图片则是在设置代理时用服务端返回的宽高字段的。
void RunDelegateDeallocCallback(void *refCon)
{
    NSLog(@"RunDelegate dealloc");
}
CGFloat RunDelegateGetAscentCallback(void *refCon)
{
    
    NSString *imageName = (__bridge NSString *)refCon;
    
    if ([imageName isKindOfClass:[NSString class]])
    {
        // 对应本地图片
        return [UIImage imageNamed:imageName].size.height/10;
    }
    
    // 对应网络图片
    return [[(__bridge NSDictionary *)refCon objectForKey:@"height"] floatValue];
}
CGFloat RunDelegateGetDescentCallback(void *refCon)
{
    return 0;
}
CGFloat RunDelegateGetWidthCallback(void *refCon)
{
    
    NSString *imageName = (__bridge NSString *)refCon;
    
    if ([imageName isKindOfClass:[NSString class]])
    {
        // 本地图片
        return [UIImage imageNamed:imageName].size.width/10;
    }
    
    
    // 对应网络图片
    return [[(__bridge NSDictionary *)refCon objectForKey:@"width"] floatValue];
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    // 1.获取上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // [a,b,c,d,tx,ty]
    NSLog(@"转换前的坐标：%@",NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));
    
    // 2.转换坐标系
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    CGContextSetTextPosition(UIGraphicsGetCurrentContext(), 50, 50);
   CGPoint point1 =  CGContextGetTextPosition(UIGraphicsGetCurrentContext());//设置CoreText绘制前的坐标。
    
    NSLog(@"转换后的坐标：%@",NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));//得到CoreText绘制前的坐标。
    
    // 3.创建绘制区域，可以对path进行个性化裁剪以改变显示区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
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
    //结构体的初始化方式
    //    CTParagraphStyleSetting theSettings = {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace};
    //    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(&theSettings, kNumberOfSettings);
    
    // 两种方式皆可
    //    [attributed addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:NSMakeRange(0, attributed.length)];
    
    // 将设置的行距应用于整段文字
    [attributed addAttribute:NSParagraphStyleAttributeName value:(__bridge id)(theParagraphRef) range:NSMakeRange(0, attributed.length)];
    
    CFRelease(theParagraphRef);
    // 创建一个 空白的站位自符来放置图片
    
    CTRunDelegateCallbacks runDelegateBack;
    
    runDelegateBack.version = kCTRunDelegateVersion1;
    runDelegateBack.getDescent = RunDelegateGetDescentCallback;
    runDelegateBack.getAscent = RunDelegateGetAscentCallback;
    runDelegateBack.getWidth = RunDelegateGetWidthCallback;
    runDelegateBack.dealloc = RunDelegateDeallocCallback;
    NSString *imageName = @"coretext-img-1";
    CTRunDelegateRef delegate = CTRunDelegateCreate(&runDelegateBack,(__bridge void *)imageName);
    
     NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];//空格用于给图片留位置
    [imageAttributedString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegate range:NSMakeRange(0, 1)];
    
    [imageAttributedString addAttribute:@"imageName" value:imageName range:NSMakeRange(0, 1)];
    // 在index处插入图片，可插入多张
    [attributed insertAttributedString:imageAttributedString atIndex:5];
    //    [attributed insertAttributedString:imageAttributedString atIndex:10];

    //  // ②若图片资源在网络上，则需要使用0xFFFC作为占位符
    // 图片信息字典
    NSString *picURL =@"http://weicai-hearsay-avatar.qiniudn.com/b4f71f05a1b7593e05e91b0175bd7c9e?imageView2/2/w/192/h/277";
    NSDictionary *imgInfoDic = @{@"width":@192,@"height":@277}; // 宽高跟具体图片有关
    // 设置CTRun的代理
    CTRunDelegateRef delegate1 = CTRunDelegateCreate(&runDelegateBack, (__bridge void *)imgInfoDic);
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate1);
    CFRelease(delegate);
    
    // 将创建的空白AttributedString插入进当前的attrString中，位置可以随便指定，不能越界
    [attributed insertAttributedString:space atIndex:10];
    
    CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    
    CTFrameRef frame =CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, UIGraphicsGetCurrentContext());
//    CFRelease(frame);
//    CFRelease(setter);
//    CFRelease(path);
    
//    NSDictionary *dic = (__bridge NSDictionary*)CTFrameGetFrameAttributes(frame);
//    CFRange range = CTFrameGetStringRange(frame);
    /*(lldb) po range
     location=0 length=112
     {
     <nil>
     
     112
     
     };;;;;;;*/

    NSArray *lineArray = (NSArray *)CTFrameGetLines(frame);
    
    NSInteger count = lineArray.count;
    CGPoint originPoint[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), originPoint);
    for (int i=0; i<count; i++) {
        CTLineRef line = (__bridge CTLineRef)lineArray[i];
        CGFloat asent;
        CGFloat desend;
        CGFloat leading;
        CTLineGetTypographicBounds(line, &asent, &desend, &leading);
        NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);
        for (int j=0;j<runArray.count;j++){
            CTRunRef run =  (__bridge CTRunRef)runArray[j];
            CGFloat ase;
            
            CGFloat dse;
            CGFloat lead;
            CGPoint point = originPoint[i];
            CGRect rect;
            rect.size.width  = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ase, &dse, &lead);
            
            rect.origin.x = point.x+CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            rect.origin.y = point.y-dse;
            rect.size.height = dse+ase;
            NSDictionary *dic = (__bridge NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegateRef = (__bridge CTRunDelegateRef)[dic objectForKey:(id)kCTRunDelegateAttributeName];
            if (!delegateRef){
                
                
                continue;
            }
            id  type = (__bridge id)CTRunDelegateGetRefCon(delegateRef);
            CGRect rectPath  =CGPathGetPathBoundingBox(path);
            
            if ([type isKindOfClass:[NSString class]]){
                //本地图片
                //CGRectOffset(rect, rectPath.origin.x, rectPath.origin.y)
                NSString *imageName = (NSString *)type;
                CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectOffset(rect, rectPath.origin.x, rectPath.origin.y),[UIImage imageNamed:imageName].CGImage);
                
            }
            if([type isKindOfClass:[NSDictionary class]]){
                //网络图片
                if (!self.image){
                    
                    [self downLoadImageWithURL:[NSURL URLWithString:picURL]];
                    UIImage *image  = [UIImage imageNamed:@"coretext-img-1"];
                    
                    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectOffset(rect, rectPath.origin.x, rectPath.origin.y),image.CGImage);
                }else{
                    UIImage *image  = self.image;
                    
                    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectOffset(rect, rectPath.origin.x, rectPath.origin.y),image.CGImage);
                    
                    
                    
                }
                
                
                
                
                
                
                
            }
            
            
            
            
            
        }
        
        
        
        
    }
    
    CFRelease(frame);
    CFRelease(setter);
    CFRelease(path);
    
    
}
//下载图片的方法：
- (void)downLoadImageWithURL:(NSURL *)url
{
    
    //__weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding  error:nil];
//        
//       id data =  [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//        
//        if ([data isKindOfClass:[NSData class]]){
//            
//            self.image = [UIImage imageWithData:data];
//            
//        }
        SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageContinueInBackground;
        options = SDWebImageRetryFailed | SDWebImageContinueInBackground;
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
            self.image = image;
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.image)
                {
                    [self setNeedsDisplay];
                }
                
            });
            
            
       }];
        
    });
    
    
}

@end
