//
//  InsetEditor.m
//  buttonInsets
//
//  Created by Richard Turton on 08/03/2013.
//  Copyright (c) 2013 Richard Turton. All rights reserved.
//

#import "InsetEditor.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation InsetEditor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // View
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        // Title label
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        [RACAble(self.title) subscribeNext:^(NSString *newTitle) {
            titleLabel.text = newTitle;
        }];
        
        [RACAble(self.color) subscribeNext:^(UIColor *newColor) {
            titleLabel.textColor = newColor;
        }];
        
        // Value labels and steppers
        
        UILabel *topLabel = [UILabel new];
        UIStepper *topStepper = [UIStepper new];
        [self addSubview:topLabel];
        [self addSubview:topStepper];
        UILabel *leftLabel = [UILabel new];
        UIStepper *leftStepper = [UIStepper new];
        [self addSubview:leftLabel];
        [self addSubview:leftStepper];
        UILabel *bottomLabel = [UILabel new];
        UIStepper *bottomStepper = [UIStepper new];
        [self addSubview:bottomLabel];
        [self addSubview:bottomStepper];
        UILabel *rightLabel = [UILabel new];
        UIStepper *rightStepper = [UIStepper new];
        [self addSubview:rightLabel];
        [self addSubview:rightStepper];
        
        for (UIView *subview in self.subviews)
        {
            subview.translatesAutoresizingMaskIntoConstraints = NO;
            subview.backgroundColor = self.backgroundColor;
            if ([subview isKindOfClass:[UIStepper class]])
            {
                UIStepper *stepper = (UIStepper*)subview;
                stepper.minimumValue = -HUGE_VAL;
                stepper.maximumValue = HUGE_VAL;
            }
        }
        
        // Layout
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel,topLabel,topStepper,leftLabel,leftStepper,bottomLabel,bottomStepper,rightLabel,rightStepper);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[titleLabel]-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[topLabel]->=0-[topStepper]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[leftLabel]->=0-[leftStepper]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[bottomLabel]->=0-[bottomStepper]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[rightLabel]->=0-[rightStepper]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-[topStepper]-[leftStepper]-[bottomStepper]-[rightStepper]-|" options:NSLayoutFormatAlignAllRight metrics:nil views:views]];
        
        // Controls
        
        [RACAble(self.insets) subscribeNext:^(id x) {
            UIEdgeInsets newInsets = [x UIEdgeInsetsValue];
            topLabel.text = [NSString stringWithFormat:@"Top: %.0f",newInsets.top];
            topStepper.value = newInsets.top;
            leftLabel.text = [NSString stringWithFormat:@"Left: %.0f",newInsets.left];
            leftStepper.value = newInsets.left;
            bottomLabel.text = [NSString stringWithFormat:@"Bottom: %.0f",newInsets.bottom];
            bottomStepper.value = newInsets.bottom;
            rightLabel.text = [NSString stringWithFormat:@"Right: %.0f",newInsets.right];
            rightStepper.value = newInsets.right;
        }];
        
        __weak typeof(self) weakSelf = self;
        RAC(self.insets) = [RACSignal combineLatest:@[
          [[topStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:topStepper],
          [[leftStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:leftStepper],
          [[bottomStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:bottomStepper],
          [[rightStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:rightStepper]
          ] reduce:^(UIStepper *top, UIStepper *left, UIStepper *bottom, UIStepper *right) {
              [weakSelf sendActionsForControlEvents:UIControlEventValueChanged];
              return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(top.value, left.value, bottom.value, right.value)];
          }];
        
//        // Need to send a control event for each stepper so that the signal becomes active.
//        for (UIControl *control in @[topStepper,leftStepper,bottomStepper,rightStepper])
//            [control sendActionsForControlEvents:UIControlEventValueChanged];
        
    }
    return self;
}


@end
