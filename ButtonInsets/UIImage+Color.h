//
//  UIImage+Color.h
//  Venti
//
//  Created by Kevin Xue on 13-9-7.
//  Copyright (c) 2013年 Beijing Zhixun Innovation Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
