//
//  ViewController.m
//  coreText
//
//  Created by Luke on 3/18/13.
//  Copyright (c) 2013 Lu Ke. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
typedef int (*function)();//声明一个函数指针 即可以指向函数的指针（函数名称相当于函数的收地址）
void fun1(int a, int b){
    
    //char *name[4] = {"zzzzz","hhhhh","wwwww","ddddd"};
    function hehe;
    hehe = fun2;
   int c =  hehe();
    NSLog(@"%d",c);
    int s1;
    function3(&s1);
    
    
    
}
int fun2(){
    
    NSLog(@"11111111111");
    return 3;
}
void function3(int *a){
    
    *a = 5;
    
    
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //空字符串的长度
    
    fun1(0, 0);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
