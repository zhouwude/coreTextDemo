//
//  main.m
//  coreText
//
//  Created by Luke on 3/18/13.
//  Copyright (c) 2013 Lu Ke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "ViewController.h"
int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        
        
        ViewController *vc = [ViewController new];
        //ios 默认成员变量是受保护的 只有改为public的时候 才能在外部访问到该成员变量 或者写成属性。
        vc->zhouwude;
        
        
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
