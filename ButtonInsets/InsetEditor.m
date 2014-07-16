//
//  InsetEditor.m
//  buttonInsets
//
//  Created by Richard Turton on 08/03/2013.
//  Copyright (c) 2013 Richard Turton. All rights reserved.
//

#import "InsetEditor.h"

#ifdef USE_RAC

#import <ReactiveCocoa/ReactiveCocoa.h>

#else

@interface InsetEditor()

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *topLabel;
@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UILabel *bottomLabel;
@property (nonatomic,strong) UILabel *rightLabel;

@property (nonatomic,strong) UIStepper *topStepper;
@property (nonatomic,strong) UIStepper *leftStepper;
@property (nonatomic,strong) UIStepper *bottomStepper;
@property (nonatomic,strong) UIStepper *rightStepper;

@end

#endif

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
#ifndef USE_RAC
                [stepper addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
#endif
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

#ifdef USE_RAC
        // Reactive cocoa bindings
        
        // This binds the text and colour of the title label to the title and colour properties, meaning we don't have to override the setters and don't need to keep the title label as a property.
        [RACObserve(self, title) subscribeNext:^(NSString *newTitle) {
            titleLabel.text = newTitle;
        }];
        
        [RACObserve(self, color) subscribeNext:^(UIColor *newColor) {
            titleLabel.textColor = newColor;
        }];
        
        // This binds the values of each stepper and label to the appropriate part of the insets property.
        [RACObserve(self, insets) subscribeNext:^(id x) {
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
        
        // This updates the insets when any of the steppers are changed. We have to use startWith: because until a signal has been received from each component, combineLatest will not fire. 
        __weak typeof(self) weakSelf = self;
        RAC(self, insets) = [RACSignal combineLatest:@[
          [[topStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:nil],
          [[leftStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:nil],
          [[bottomStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:nil],
          [[rightStepper rac_signalForControlEvents:UIControlEventValueChanged] startWith:nil]
          ] reduce:^(UIStepper *top, UIStepper *left, UIStepper *bottom, UIStepper *right) {
              [weakSelf sendActionsForControlEvents:UIControlEventValueChanged];
              return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(top.value, left.value, bottom.value, right.value)];
          }];
#else
        
        // We need to set all the properties up
        _titleLabel = titleLabel;
        _topLabel = topLabel;
        _leftLabel = leftLabel;
        _bottomLabel = bottomLabel;
        _rightLabel = rightLabel;
        
        _topStepper = topStepper;
        _leftStepper = leftStepper;
        _bottomStepper = bottomStepper;
        _rightStepper = rightStepper;
        
#endif
        
    }
    return self;
}

#ifndef USE_RAC

// These are all the bindings and methods that using RAC replaces

-(void)setColor:(UIColor *)color
{
    _color = color;
    self.titleLabel.textColor = color;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

-(void)stepperChanged:(UIStepper*)sender
{
    self.insets = UIEdgeInsetsMake(self.topStepper.value, self.leftStepper.value, self.bottomStepper.value, self.rightStepper.value);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    self.topLabel.text = [NSString stringWithFormat:@"Top: %.0f",insets.top];
    self.leftLabel.text = [NSString stringWithFormat:@"Left: %.0f",insets.left];
    self.bottomLabel.text = [NSString stringWithFormat:@"Bottom: %.0f",insets.bottom];
    self.rightLabel.text = [NSString stringWithFormat:@"Right: %.0f",insets.right];
    
    self.topStepper.value = insets.top;
    self.leftStepper.value = insets.left;
    self.bottomStepper.value = insets.bottom;
    self.rightStepper.value = insets.right;
}

#endif

@end
