//
//  ViewController.m
//  runtime
//
//  Created by 时群 on 2017/4/12.
//  Copyright © 2017年 杨崇健. All rights reserved.
//

#import "ViewController.h"

#import <objc/Runtime.h>

@interface ViewController ()
{
    
    int num;
    
    float nums;
    
}



@end

@implementation ViewController

- (void)eat {
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];


    unsigned int count;
    //获取属性列表
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    
    for (NSInteger i = 0; i <count; i++) {
        
        const char *propertyName = property_getName(propertyList[i]);
        
        NSLog(@"property------->%@",[NSString stringWithUTF8String:propertyName]);
    }
    
    //获取方法列表
    Method *methodList = class_copyMethodList([self class], &count);
    
    for (NSUInteger i = 0; i<count; i++) {
        
        Method method = methodList[i];
        
        NSLog(@"method--------->%@",NSStringFromSelector(method_getName(method)));
    }
    
    //获取成员变量列表
    Ivar *ivarList = class_copyIvarList([self class], &count);
    
    for (NSUInteger i = 0; i < count; i++) {
        
        Ivar myIvar = ivarList[i];
        
        const char *ivarName = ivar_getName(myIvar);
        
        NSLog(@"ivar---------->%@",[NSString stringWithUTF8String:ivarName]);
    }
    
    //获取协议列表
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    
    for (NSUInteger i = 0; i<count; i++) {
        
        Protocol *myProtocol = protocolList[i];
        
        const char *protocoName = protocol_getName(myProtocol);
        
        NSLog(@"Protocol-------------->%@",[NSString stringWithUTF8String:protocoName]);
    }

    //动态添加方法
    [self performSelector:@selector(studyEngilsh)];
    
    //关联对象
    [self associatedObject];
    
    [self swiz_viewWillAppear];
}

//--------------------------------------------------动态添加方法-----------------------------------------------
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == NSSelectorFromString(@"studyEngilsh")) {
        // 注意:这里需要强转成IMP类型
        class_addMethod(self, sel, (IMP)studyEngilsh, "v@:");
        return YES;
    }
    // 先恢复, 不然会覆盖系统的方法
    return [super resolveInstanceMethod:sel];}

void studyEngilsh(id self, SEL _cmd) {
    
    NSLog(@"动态添加了一个学习英语的方法");
}
//--------------------------------------------------动态添加方法-----------------------------------------------

//--------------------------------------------------关联对象----------------------------------------------------
- (void)associatedObject {
    
    static char associatedObjectKey;
    
    objc_setAssociatedObject(self, &associatedObjectKey, @{@"hehe":@"hehe"}, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSString *string = objc_getAssociatedObject(self, &associatedObjectKey);
    
    NSLog(@"AssociatedObject = %@",string);
    
}
//--------------------------------------------------关联对象----------------------------------------------------

//--------------------------------------------------方法交换----------------------------------------------------
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //获得UIViewCOntroller生命周期的selector
        SEL systemSel = @selector(viewWillAppear:);
        
        //自己实现即将被交换的方法selector
        SEL swizzSel = @selector(swiz_viewWillAppear);
        
        //两个方法的Method
        Method systemMethod = class_getInstanceMethod([self class], systemSel);
        
        Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
        
        //首先动态添方法，实现是被交换的方法，返回值表示成功还是失败
        BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(systemMethod));
        
        if (isAdd) {
            //如果成功，说明类中不存在这个方法的实现
            //将被交换这个方法的实现替换到这个不存在的实现
            class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
        }else {
            
            method_exchangeImplementations(systemMethod, swizzMethod);
        }
    });
    
}

- (void)swiz_viewWillAppear {
    
    //看起来是死循环,但是实际上自己的实现已经被替换了
    [self swiz_viewWillAppear];
    
    NSLog(@"方法交换");
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
}
//--------------------------------------------------方法交换----------------------------------------------------
@end
