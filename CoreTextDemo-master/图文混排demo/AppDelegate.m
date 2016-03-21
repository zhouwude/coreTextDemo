//
//  AppDelegate.m
//  图文混排demo
//
//  Created by 敬洁 on 15/2/11.
//  Copyright (c) 2015年 JingJ. All rights reserved.
//

#import "AppDelegate.h"
struct zwdStruct{
    char a;//偏移量0 是char大小的整数倍
    int b;// 偏移量 1 + 3 才能被4整除(地址偏移量必须被改位置元素的大小整除)
    
    double c;// 5+3
    int d; //16
    
    
    /**
     * 总大小为 1 +3 +4 + 8 +4 = 20 
     20不是8的倍数 古还要再后面最佳  4个字节
     20+4 = 24
     */
    
    
    
}zwd;
@interface AppDelegate ()

@end

@implementation AppDelegate

//iOS系统版本条件编译宏


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //也就是说tintColor属性在iOS6.1中根本就没有，在编译时候就会出错。这时候如下加上判断语句也是没有用的，照样报错（预处理，编译，运行的问题这里不再废话）
    //如果只用了 该系统版本 没有的API则会报错必须使用条件编译才行
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.window.tintColor = [UIColor redColor];
    }
    
    
    // Override point for customization after application launch.
    return YES;
}
/**
 *  Description
 *
 *  @param application <#application description#>
 */


#pragma mark -改api在ios7以上被废弃 如果在代码中写会有警告 必须 使用预编译的形式 
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
- (BOOL)isConcurrent {
    return YES;
}

#else

- (BOOL)isAsynchronous {
    return YES;
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
