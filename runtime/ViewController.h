//
//  ViewController.h
//  runtime
//
//  Created by 时群 on 2017/4/12.
//  Copyright © 2017年 杨崇健. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIViewControllerDelegate <NSObject>

- (void)delegateMethod;

@end

@interface ViewController : UIViewController

@property (nonatomic,strong) UIButton *ycjButton;

@property (nonatomic,weak) id<UIViewControllerDelegate>delegate;

- (void)eat;




@end

