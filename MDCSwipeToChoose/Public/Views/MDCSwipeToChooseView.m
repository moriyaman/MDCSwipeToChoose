//
// MDCSwipeToChooseView.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "MDCSwipeToChooseView.h"
#import "MDCSwipeToChoose.h"
#import "MDCGeometry.h"
#import "UIView+MDCBorderedLabel.h"
#import "UIColor+MDCRGB8Bit.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const MDCSwipeToChooseViewHorizontalPadding = 10.f;
static CGFloat const MDCSwipeToChooseViewTopPadding = 20.f;
static CGFloat const MDCSwipeToChooseViewLabelWidth = 65.f;

@interface MDCSwipeToChooseView ()
@property (nonatomic, strong) MDCSwipeToChooseViewOptions *options;
@end

@implementation MDCSwipeToChooseView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame];
    if (self) {
        _options = options ? options : [MDCSwipeToChooseViewOptions new];
        [self setupView];
        [self constructImageView];
        [self constructUserNameLabel];
        [self setupSwipeToChoose];
    }
    return self;
}

#pragma mark - Internal Methods

- (void)setupView {
  self.backgroundColor = [UIColor whiteColor];
  self.layer.cornerRadius = 40.f;
  self.clipsToBounds = true;

  self.layer.borderWidth = 0.5f;
  self.layer.borderColor = [UIColor colorWith8BitRed:220.f
                                             green:220.f
                                              blue:220.f
                                             alpha:1.f].CGColor;
}

- (void)constructImageView {

  _imageView = [[UIImageView alloc] initWithFrame:self.options.leftImageViewRect];
  _rightImageView = [[UIImageView alloc] initWithFrame:self.options.rightImageViewRect];

  _leftCoverView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.options.leftImageViewRect.size.width,self.options.leftImageViewRect.size.height)];
  _leftCoverView.backgroundColor = [UIColor whiteColor];
  _leftCoverView.tag = -1;
  _leftCoverView.alpha = 0.f;

  _rightCoverView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.options.rightImageViewRect.size.width,self.options.rightImageViewRect.size.height)];
  _rightCoverView.backgroundColor = [UIColor whiteColor];
  _rightCoverView.tag = -1;
  _rightCoverView.alpha = 0.f;

  _imageView.layer.cornerRadius = _imageView.frame.size.width * 0.5; //角丸の範囲＝数が大きいほど丸く
  _imageView.clipsToBounds = true; //角丸に画像を切り抜く

  _rightImageView.layer.cornerRadius = _rightImageView.frame.size.width * 0.5; //角丸の範囲＝数が大きいほど丸く
  _rightImageView.clipsToBounds = true; //角丸に画像を切り抜く

  [_imageView addSubview:_leftCoverView];
  [_rightImageView addSubview:_rightCoverView];

  [self addSubview:_imageView];
  [self addSubview:_rightImageView];
}


- (void)constructUserNameLabel {
    _rightUserNameLabel = self.options.rightUserNameLabel;
    _leftUserNameLabel = self.options.leftUserNameLabel;

    [self addSubview:_rightUserNameLabel];
    [self addSubview:_leftUserNameLabel];
}


- (void)setupSwipeToChoose {

    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;

    //__block UIView *rightLikedImageView = self.rightLikedView;
    //__block UIView *leftNopeImageView = self.leftNopeView;
    //__block UIView *leftLikedImageView = self.leftLikedView;
    //__block UIView *rightNopeImageView = self.rightNopeView;

    __weak MDCSwipeToChooseView *weakself = self;

    NSInteger center = self.bounds.size.width/2;
    NSInteger bounds_height = self.bounds.size.height;
    NSInteger bounds_width = self.bounds.size.width;
    float width_ration = bounds_width/315.0;
    float height_ration = bounds_height/385.0;

    float width = self.options.leftImageViewRect.size.width;
    float height = self.options.leftImageViewRect.size.height;

    float max_width = width + 30.0*width_ration;
    float max_height = height + 30.0*height_ration;

    UIView *superview = self.imageView.superview;
    self.imageView.layer.zPosition = 1;
    self.rightImageView.layer.zPosition = 1;

    float rightXposition = self.options.rightImageViewRect.origin.x;
    float rightYposition = self.options.rightImageViewRect.origin.y;
    float rightCenterYposition = self.options.rightImageViewRect.origin.y + height/2;

    // leftだけ右側に合わせる
    float leftXposition = self.options.leftImageViewRect.origin.x + width;
    float leftYposition = self.options.leftImageViewRect.origin.y;
    float leftCenterYposition = self.options.leftImageViewRect.origin.y + height/2;

    float nameLabelHeight = self.leftUserNameLabel.frame.size.height;
    float nameLabelWidth = self.leftUserNameLabel.frame.size.width;

    // name label
    CGRect leftNameLabelFrame = CGRectMake(leftXposition-width/2 - nameLabelWidth/2, leftYposition+height+5, nameLabelWidth, nameLabelHeight);
    CGRect rightNameLabelFrame = CGRectMake(rightXposition+width/2 - nameLabelWidth/2, rightYposition+height+5, nameLabelWidth, nameLabelHeight);

    int leftIndex = [superview.subviews indexOfObject:self.imageView];
    int rightIndex = [superview.subviews indexOfObject:self.rightImageView];

    // coverView
    UIView *leftCoverView = [self.imageView viewWithTag: -1];
    UIView *rightCoverView = [self.rightImageView viewWithTag: -1];

    leftCoverView.clipsToBounds = true; //角丸に画像を切り抜く
    rightCoverView.clipsToBounds = true; //角丸に画像を切り抜く

    // font size
    CGFloat fontSize = self.leftUserNameLabel.font.pointSize;

    options.onPan = ^(MDCPanState *state) {
        if (state.direction == MDCSwipeDirectionNone) {

            // user photo
            self.imageView.frame = self.options.leftImageViewRect;
            self.rightImageView.frame = self.options.rightImageViewRect;
            //self.imageView.leftCoverView.frame = CGRectMake(0,0,self.imageView.frame.size.width,self.imageView.frame.size.height);

            leftCoverView.frame = CGRectMake(0,0,width,height);
            rightCoverView.frame = CGRectMake(0,0,width,height);
            leftCoverView.alpha = 0.f;
            rightCoverView.alpha = 0.f;

            // user name label
            self.leftUserNameLabel.frame = leftNameLabelFrame;
            self.rightUserNameLabel.frame = rightNameLabelFrame;

            self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5; //角丸の範囲＝数が大きいほど丸く
            self.rightImageView.layer.cornerRadius = self.rightImageView.frame.size.width * 0.5; //角丸の範囲＝数が大きいほど丸く

            leftCoverView.layer.cornerRadius = width * 0.5;
            rightCoverView.layer.cornerRadius = width * 0.5;

            // user name label font
            self.leftUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize];
            self.rightUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize];

        } else if (state.direction == MDCSwipeDirectionLeft) {
            float rightReduction = 1.0f - state.thresholdRatio;
            [superview bringSubviewToFront:self.imageView];
            if (rightReduction >= 0.80) {

              // for not choice
              float rightResizeHeight = height*(rightReduction - 0.2*state.thresholdRatio);
              float rightResizeWidth = width*(rightReduction - 0.2*state.thresholdRatio);
              float rightResizeXposition = rightXposition - 100.0*state.thresholdRatio;
              float rightResizeYposition = (rightCenterYposition - rightResizeWidth/2);
              self.rightImageView.frame = CGRectMake(rightResizeXposition, rightResizeYposition, rightResizeWidth, rightResizeHeight);
              self.rightImageView.layer.cornerRadius = rightResizeWidth * 0.5;

              rightCoverView.frame = CGRectMake(0,0,rightResizeWidth,rightResizeHeight);
              rightCoverView.alpha = 3*state.thresholdRatio;
              rightCoverView.layer.cornerRadius = rightCoverView.frame.size.width * 0.5;

              // for not choice label
              float rightNameLabelResizeHeight = nameLabelHeight*(rightReduction - 0.2*state.thresholdRatio);
              float rightNameLabelResizeWidth = nameLabelWidth*(rightReduction - 0.2*state.thresholdRatio);
              self.rightUserNameLabel.frame = CGRectMake(rightResizeXposition+rightResizeWidth/2 - rightNameLabelResizeWidth/2, rightResizeYposition+rightResizeHeight+5, rightNameLabelResizeWidth, rightNameLabelResizeHeight);
              self.rightUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*rightNameLabelResizeHeight/nameLabelHeight];

              // for choice
              float leftResizeHeight = height + 150*state.thresholdRatio;
              float leftResizeWidth = width + 150*state.thresholdRatio;
              float leftResizeXposition = leftXposition - leftResizeWidth + ((center - max_width/2) - leftXposition + leftResizeWidth)*5*state.thresholdRatio;
              float leftResizeYposition = (leftCenterYposition - leftResizeHeight/2);
              self.imageView.frame = CGRectMake(leftResizeXposition, leftResizeYposition, leftResizeWidth, leftResizeHeight);
              self.imageView.layer.cornerRadius = leftResizeWidth * 0.5;

              leftCoverView.frame = CGRectMake(0,0,leftResizeWidth,leftResizeHeight);
              leftCoverView.alpha = 0.f;
              leftCoverView.layer.cornerRadius = leftResizeWidth * 0.5;

              // for choice label
              float leftNameLabelResizeHeight = nameLabelHeight + 37.5*state.thresholdRatio;
              float leftNameLabelResizeWidth = nameLabelWidth + 37.5*state.thresholdRatio;
              self.leftUserNameLabel.frame = CGRectMake(leftResizeXposition+leftResizeWidth/2 - leftNameLabelResizeWidth/2, leftResizeYposition+leftResizeHeight+5, leftNameLabelResizeWidth, leftNameLabelResizeHeight);
              //self.leftUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*leftNameLabelResizeHeight/nameLabelHeight];
            } else {
              // for not choice
              float rightResizeHeight = height*0.76;
              float rightResizeWidth = width*0.76;
              float rightResizeXposition = rightXposition - 20.0;
              float rightResizeYposition = (rightCenterYposition - rightResizeWidth/2);
              self.rightImageView.frame = CGRectMake(rightResizeXposition, rightResizeYposition, rightResizeWidth, rightResizeHeight);
              self.rightImageView.layer.cornerRadius = rightResizeWidth * 0.5;

              rightCoverView.frame = CGRectMake(0,0,rightResizeWidth,rightResizeHeight);
              rightCoverView.alpha = 0.6f;
              rightCoverView.layer.cornerRadius = rightCoverView.frame.size.width * 0.5;

              // for not choice label
              float rightNameLabelResizeHeight = nameLabelHeight*0.76;
              float rightNameLabelResizeWidth = nameLabelWidth*0.76;
              self.rightUserNameLabel.frame = CGRectMake(rightResizeXposition+rightResizeWidth/2 - rightNameLabelResizeWidth/2, rightResizeYposition+rightResizeHeight+5, rightNameLabelResizeWidth, rightNameLabelResizeHeight);
              self.rightUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*rightNameLabelResizeHeight/nameLabelHeight];

              // for choice
              float leftResizeHeight = max_height;
              float leftResizeWidth = max_width;
              float leftResizeXposition = center - max_width/2;
              float leftResizeYposition = (leftCenterYposition - leftResizeHeight/2);
              self.imageView.frame = CGRectMake(leftResizeXposition, leftResizeYposition, leftResizeWidth, leftResizeHeight);
              self.imageView.layer.cornerRadius = leftResizeWidth * 0.5; //角丸の範囲＝数が大きいほど丸く

              leftCoverView.frame = CGRectMake(0,0,leftResizeWidth,leftResizeHeight);
              leftCoverView.alpha = 0.f;
              leftCoverView.layer.cornerRadius = leftResizeWidth * 0.5;

              // for choice label
              float leftNameLabelResizeHeight = nameLabelHeight + 7.5;
              float leftNameLabelResizeWidth = nameLabelWidth + 7.5;
              self.leftUserNameLabel.frame = CGRectMake(leftResizeXposition+leftResizeWidth/2 - leftNameLabelResizeWidth/2, leftResizeYposition+leftResizeHeight+5, leftNameLabelResizeWidth, leftNameLabelResizeHeight);
              //self.leftUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*leftNameLabelResizeHeight/nameLabelHeight];
            }
        } else if (state.direction == MDCSwipeDirectionRight) {
            float reduction = 1.0f - state.thresholdRatio;
            [superview bringSubviewToFront:self.rightImageView];
            if (reduction >= 0.80) {
              // for choice
              float rightResizeHeight = height + 150*state.thresholdRatio;
              float rightResizeWidth = width + 150*state.thresholdRatio;
              float rightResizeXposition = rightXposition - (rightXposition - (center - max_width/2))*5*state.thresholdRatio;
              float rightResizeYposition = (rightCenterYposition - rightResizeWidth/2);
              self.rightImageView.frame = CGRectMake(rightResizeXposition, rightResizeYposition, rightResizeWidth, rightResizeHeight);
              self.rightImageView.layer.cornerRadius = rightResizeWidth * 0.5;

              rightCoverView.frame = CGRectMake(0,0,rightResizeWidth,rightResizeHeight);
              rightCoverView.alpha = 0.f;
              rightCoverView.layer.cornerRadius = rightResizeWidth * 0.5;

              // for choice label
              float rightNameLabelResizeHeight = nameLabelHeight + 37.5*state.thresholdRatio;
              float rightNameLabelResizeWidth = nameLabelWidth + 37.5*state.thresholdRatio;
              self.rightUserNameLabel.frame = CGRectMake(rightResizeXposition+rightResizeWidth/2 - rightNameLabelResizeWidth/2, rightResizeYposition+rightResizeHeight+5, rightNameLabelResizeWidth, rightNameLabelResizeHeight);
              self.rightUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*rightNameLabelResizeHeight/nameLabelHeight];

              // for not choice
              float leftResizeHeight = height*(reduction - 0.2*state.thresholdRatio);
              float leftResizeWidth = width*(reduction - 0.2*state.thresholdRatio);
              float leftResizeXposition = leftXposition - leftResizeWidth + 100.0*state.thresholdRatio;
              float leftResizeYposition = (leftCenterYposition - leftResizeHeight/2);
              self.imageView.frame = CGRectMake(leftResizeXposition, leftResizeYposition, leftResizeWidth, leftResizeHeight);
              self.imageView.layer.cornerRadius = leftResizeWidth * 0.5;

              leftCoverView.frame = CGRectMake(0,0,leftResizeWidth,leftResizeHeight);
              leftCoverView.alpha = 3*state.thresholdRatio;
              leftCoverView.layer.cornerRadius = leftResizeWidth * 0.5;

              // for not choice label
              float leftNameLabelResizeHeight = nameLabelHeight*(reduction - 0.2*state.thresholdRatio);
              float leftNameLabelResizeWidth = nameLabelWidth*(reduction - 0.2*state.thresholdRatio);
              self.leftUserNameLabel.frame = CGRectMake(leftResizeXposition+leftResizeWidth/2 - leftNameLabelResizeWidth/2, leftResizeYposition+leftResizeHeight+5, leftNameLabelResizeWidth, leftNameLabelResizeHeight);
              self.leftUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*leftNameLabelResizeHeight/nameLabelHeight];

            } else {

              // for choice
              float rightResizeHeight = max_height;
              float rightResizeWidth = max_width;
              float rightResizeXposition = center - max_width/2;
              float rightResizeYposition = (rightCenterYposition - rightResizeWidth/2);
              self.rightImageView.frame = CGRectMake(rightResizeXposition, rightResizeYposition, rightResizeWidth, rightResizeHeight);
              self.rightImageView.layer.cornerRadius = rightResizeWidth * 0.5;

              rightCoverView.frame = CGRectMake(0,0,rightResizeWidth,rightResizeHeight);
              rightCoverView.alpha = 0.f;
              rightCoverView.layer.cornerRadius = rightResizeWidth * 0.5;

              // for choice label
              float rightNameLabelResizeHeight = nameLabelHeight + 7.5;
              float rightNameLabelResizeWidth = nameLabelWidth + 7.5;
              self.rightUserNameLabel.frame = CGRectMake(rightResizeXposition+rightResizeWidth/2 - rightNameLabelResizeWidth/2, rightResizeYposition+rightResizeHeight+5, rightNameLabelResizeWidth, rightNameLabelResizeHeight);
              self.rightUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*rightNameLabelResizeHeight/nameLabelHeight];

              // for not choice
              float leftResizeHeight = height*0.76;
              float leftResizeWidth = width*0.76;
              float leftResizeXposition = leftXposition - leftResizeWidth + 20.0;
              float leftResizeYposition = (leftCenterYposition - leftResizeHeight/2);
              self.imageView.frame = CGRectMake(leftResizeXposition, leftResizeYposition, leftResizeWidth, leftResizeHeight);
              self.imageView.layer.cornerRadius = leftResizeWidth * 0.5;

              // for not choice label
              float leftNameLabelResizeHeight = nameLabelHeight*0.76;
              float leftNameLabelResizeWidth = nameLabelWidth*0.76;
              self.leftUserNameLabel.frame = CGRectMake(leftResizeXposition+leftResizeWidth/2 - leftNameLabelResizeWidth/2, leftResizeYposition+leftResizeHeight+5, leftNameLabelResizeWidth, leftNameLabelResizeHeight);
              self.leftUserNameLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize*leftNameLabelResizeHeight/nameLabelHeight];

              leftCoverView.frame = CGRectMake(0,0,leftResizeWidth,leftResizeHeight);
              leftCoverView.alpha = 0.6f;
              leftCoverView.layer.cornerRadius = leftResizeWidth * 0.5;

            }

            //leftNopeImageView.alpha = state.thresholdRatio;
        }
        if (weakself.options.onPan) {
            weakself.options.onPan(state);
        }
    };

    [self mdc_swipeToChooseSetup:options];
}

@end
