//
//  InsetEditor.h
//  buttonInsets
//
//  Created by Richard Turton on 08/03/2013.
//  Copyright (c) 2013 Richard Turton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsetEditor : UIControl

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic) UIEdgeInsets insets;

@end
