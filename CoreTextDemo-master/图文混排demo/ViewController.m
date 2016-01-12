//
//  ViewController.m
//  图文混排demo
//
//  Created by 敬洁 on 15/2/11.
//  Copyright (c) 2015年 JingJ. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextView.h"
#import "CTBaseUsed.h"
#import "view111.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

//    CoreTextView *textView = [[CoreTextView alloc] initWithFrame:self.view.bounds];
//    textView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:textView];
//    CTBaseUsed *textView1 = [[CTBaseUsed alloc] initWithFrame:self.view.bounds];
//    textView1.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:textView1];
    view111 *textView1 = [[view111 alloc] initWithFrame:self.view.bounds];
    textView1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView1];
}

@end