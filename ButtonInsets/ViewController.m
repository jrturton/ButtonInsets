//
//  ViewController.m
//  buttonInsets
//
//  Created by Richard Turton on 08/03/2013.
//  Copyright (c) 2013 Richard Turton. All rights reserved.
//

#import "ViewController.h"
#import "InsetEditor.h"
#import <QuartzCore/QuartzCore.h>

#ifdef USE_RAC
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif

@interface ViewController ()

@property (nonatomic,strong) InsetEditor *contentInsetEditor;
@property (nonatomic,strong) InsetEditor *imageInsetEditor;
@property (nonatomic,strong) InsetEditor *titleInsetEditor;

@property (nonatomic,strong) UIButton *demoButton;

@property (nonatomic,strong) UILabel *buttonFrameLabel;
@property (nonatomic,strong) UILabel *imageFrameLabel;
@property (nonatomic,strong) UILabel *titleFrameLabel;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Put some crosshairs in to show us the center
    UIView *horizontal = [UIView new];
    UIView *vertical = [UIView new];
    horizontal.translatesAutoresizingMaskIntoConstraints = NO;
    vertical.translatesAutoresizingMaskIntoConstraints = NO;
    horizontal.backgroundColor = [UIColor lightGrayColor];
    vertical.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:horizontal];
    [self.view addSubview:vertical];
    
    // Inset editors
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[horizontal]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(horizontal)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vertical]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vertical)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:horizontal attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:vertical attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [horizontal addConstraint:[NSLayoutConstraint constraintWithItem:horizontal attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0]];
    [vertical addConstraint:[NSLayoutConstraint constraintWithItem:vertical attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0]];
    
    InsetEditor *contentInsetEditor = [InsetEditor new];
    contentInsetEditor.title = @"Content";
    contentInsetEditor.insets = UIEdgeInsetsZero;
    
    InsetEditor *imageInsetEditor = [InsetEditor new];
    imageInsetEditor.title = @"Image";
    imageInsetEditor.insets = UIEdgeInsetsZero;
    
    InsetEditor *titleInsetEditor = [InsetEditor new];
    titleInsetEditor.title = @"Title";
    titleInsetEditor.insets = UIEdgeInsetsZero;
    
    [self.view addSubview:contentInsetEditor];
    [self.view addSubview:imageInsetEditor];
    [self.view addSubview:titleInsetEditor];
    
    for (InsetEditor *subview in @[contentInsetEditor,imageInsetEditor,titleInsetEditor])
    {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
#ifndef USE_RAC
        [subview addTarget:self action:@selector(insetsEdited:) forControlEvents:UIControlEventValueChanged];
    }
    self.contentInsetEditor = contentInsetEditor;
    self.imageInsetEditor = imageInsetEditor;
    self.titleInsetEditor = titleInsetEditor;
#else
    }
#endif

    NSDictionary *views = NSDictionaryOfVariableBindings(contentInsetEditor,imageInsetEditor,titleInsetEditor);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentInsetEditor]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[contentInsetEditor(==imageInsetEditor)]-[imageInsetEditor(==titleInsetEditor)]-[titleInsetEditor]-|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self createDemoButton];
    
    UIButton *reset = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reset setTitle:@"Reset" forState:UIControlStateNormal];
    [reset addTarget:self action:@selector(resetButton) forControlEvents:UIControlEventTouchUpInside];
    reset.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:reset];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[reset]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(reset)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reset]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(reset)]];
    
    // Labels to indicate various frames
    UILabel *buttonFrameLabel = [UILabel new];
    UILabel *titleFrameLabel = [UILabel new];
    UILabel *imageFrameLabel = [UILabel new];
    
    for (UILabel *label in @[buttonFrameLabel,titleFrameLabel,imageFrameLabel])
    {
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:label];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentInsetEditor]-[buttonFrameLabel]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:NSDictionaryOfVariableBindings(contentInsetEditor,buttonFrameLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageInsetEditor]-[imageFrameLabel]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:NSDictionaryOfVariableBindings(imageInsetEditor,imageFrameLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleInsetEditor]-[titleFrameLabel]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:NSDictionaryOfVariableBindings(titleFrameLabel,titleInsetEditor)]];
    
#ifdef USE_RAC
    
    RAC(self, demoButton.contentEdgeInsets) = [RACSignal combineLatest:@[[[contentInsetEditor rac_signalForControlEvents:UIControlEventValueChanged] startWith:nil]] reduce:^(InsetEditor *editor){
        return [NSValue valueWithUIEdgeInsets:editor.insets];
    }];
    
    RAC(self, demoButton.imageEdgeInsets) = [RACSignal combineLatest:@[[[imageInsetEditor rac_signalForControlEvents:UIControlEventValueChanged] startWith:nil]] reduce:^(InsetEditor *editor){
        return [NSValue valueWithUIEdgeInsets:editor.insets];
    }];
    
    RAC(self, demoButton.titleEdgeInsets) = [RACSignal combineLatest:@[[[titleInsetEditor rac_signalForControlEvents:UIControlEventValueChanged] startWith:nil]] reduce:^(InsetEditor *editor){
        return [NSValue valueWithUIEdgeInsets:editor.insets];
    }];
    
    
    [RACObserve(self, demoButton.contentEdgeInsets) subscribeNext:^(NSValue *contentEdgeInsetsValue) {
        buttonFrameLabel.text = descriptionOfFrame(self.demoButton.frame);
    }];
    
    [RACObserve(self, demoButton.titleEdgeInsets) subscribeNext:^(NSValue *titleEdgeInsetsValue) {
        titleFrameLabel.text = descriptionOfFrame(self.demoButton.titleLabel.frame);
    }];
    
    [RACObserve(self, demoButton.imageEdgeInsets) subscribeNext:^(NSValue *imageEdgeInsetsValue) {
        imageFrameLabel.text = descriptionOfFrame(self.demoButton.imageView.frame);
    }];
    
#else
    self.buttonFrameLabel = buttonFrameLabel;
    self.titleFrameLabel = titleFrameLabel;
    self.imageFrameLabel = imageFrameLabel;
#endif
}

#ifdef USE_RAC

// This was the only way to get the initial frame label to show correctly
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resetButton];
}
#endif


#ifndef USE_RAC
-(void)viewDidLayoutSubviews
{
    [self updateFrameLabels];
    [self.view layoutSubviews];
}
#endif

-(void)resetButton
{
    //TODO: This does not reset the editors when using RAC.
    self.demoButton.contentEdgeInsets = UIEdgeInsetsZero;
    self.demoButton.imageEdgeInsets = UIEdgeInsetsZero;
    self.demoButton.titleEdgeInsets = UIEdgeInsetsZero;
    self.contentInsetEditor.insets = UIEdgeInsetsZero;
    self.imageInsetEditor.insets = UIEdgeInsetsZero;
    self.titleInsetEditor.insets = UIEdgeInsetsZero;
}

-(UIButton*)createDemoButton
{
    [self.demoButton removeFromSuperview];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Button title" forState:UIControlStateNormal];
    
    [button setImage:[UIImage imageNamed:@"command"] forState:UIControlStateNormal];
    
    self.contentInsetEditor.insets = button.contentEdgeInsets;
    self.imageInsetEditor.insets = button.imageEdgeInsets;
    self.titleInsetEditor.insets = button.titleEdgeInsets;
    
    UIColor *contentColor = [UIColor greenColor];
    button.layer.borderColor = contentColor.CGColor;
    button.layer.borderWidth = 1.0;
    self.contentInsetEditor.color = contentColor;
    
    UIColor *titleColor = [UIColor redColor];
    button.titleLabel.layer.borderColor = titleColor.CGColor;
    button.titleLabel.layer.borderWidth = 1.0;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    self.titleInsetEditor.color = titleColor;
    
    UIColor *imageColor = [UIColor blueColor];
    button.imageView.layer.borderColor = imageColor.CGColor;
    button.imageView.layer.borderWidth = 2.0;
    self.imageInsetEditor.color = imageColor;
    
    [self.view addSubview:button];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    self.demoButton = button;
    return button;
}

#ifndef USE_RAC
-(void)insetsEdited:(InsetEditor*)sender
{
    if (sender == self.contentInsetEditor)
        self.demoButton.contentEdgeInsets = sender.insets;
    if (sender == self.imageInsetEditor)
        self.demoButton.imageEdgeInsets = sender.insets;
    if (sender == self.titleInsetEditor)
        self.demoButton.titleEdgeInsets = sender.insets;
    
    [self updateFrameLabels];
}

-(void)updateFrameLabels
{
    self.buttonFrameLabel.text = descriptionOfFrame(self.demoButton.frame);
    self.imageFrameLabel.text = descriptionOfFrame(self.demoButton.imageView.frame);
    self.titleFrameLabel.text = descriptionOfFrame(self.demoButton.titleLabel.frame);
}
#endif

NSString* descriptionOfFrame(CGRect frame)
{
    return [NSString stringWithFormat:@"Origin: %.1f,%.1f Size:%.1f x %.1f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height];
}

@end
