//
//  SVIndefiniteAnimatedView.m
//  SVProgressHUD
//
//  Created by Guillaume Campagna on 2014-12-05.
//
//

#import "SVIndefiniteAnimatedView.h"

#pragma mark SVIndefiniteAnimatedView

@interface SVIndefiniteAnimatedView ()

@property (nonatomic, strong) CAShapeLayer *indefiniteAnimatedLayer;

@end

@implementation SVIndefiniteAnimatedView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_indefiniteAnimatedLayer removeFromSuperlayer];
        _indefiniteAnimatedLayer = nil;
    }
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.indefiniteAnimatedLayer;

    [self.layer addSublayer:layer];
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2);
}

- (CAShapeLayer*)indefiniteAnimatedLayer {
    if(!_indefiniteAnimatedLayer) {
        NSTimeInterval animationDuration = 1;
        
        if (SVProgressHUDRotatingImage) {
            _indefiniteAnimatedLayer = [CALayer layer];
            _indefiniteAnimatedLayer.contents = (id) SVProgressHUDRotatingImage.CGImage;
            _indefiniteAnimatedLayer.frame = CGRectMake(0, 0, SVProgressHUDRotatingImage.size.width, SVProgressHUDRotatingImage.size.height);
            
            NSNumber *rotationFromValue = [_indefiniteAnimatedLayer valueForKeyPath:@"transform.rotation"];
            NSNumber *rotationToValue;
            
            if (SVProgressHUDRotateImageSpringy) {
                rotationToValue = [NSNumber numberWithFloat:([rotationFromValue floatValue] + M_PI*2)];
                
                RBBSpringAnimation *spring = [RBBSpringAnimation animationWithKeyPath:@"transform.rotation"];
                
                spring.fromValue = rotationFromValue;
                spring.toValue = rotationToValue;
                spring.velocity = 0;
                spring.mass = 0.25;
                spring.damping = 5;
                spring.stiffness = 50;
                spring.repeatCount = INFINITY;
                spring.additive = YES;
                spring.duration = [spring durationForEpsilon:0.001];
                [_indefiniteAnimatedLayer addAnimation:spring forKey:@"transform.rotation"];
            }
            else {
                rotationToValue = [NSNumber numberWithFloat:([rotationFromValue floatValue] + M_PI*2)];
                
                CATransform3D myRotationTransform = CATransform3DRotate(_indefiniteAnimatedLayer.transform, M_PI*2, 0.0, 0.0, 1.0);
                _indefiniteAnimatedLayer.transform = myRotationTransform;
                CABasicAnimation *myAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                myAnimation.duration = animationDuration;
                myAnimation.fromValue = rotationFromValue;
                myAnimation.repeatCount = INFINITY;
                myAnimation.toValue = rotationToValue;
                [_indefiniteAnimatedLayer addAnimation:myAnimation forKey:@"transform.rotation"];
            }
        }
        else {
            CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
            CGRect rect = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);

            UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                        radius:self.radius
                                                                    startAngle:M_PI*3/2
                                                                      endAngle:M_PI/2+M_PI*5
                                                                     clockwise:YES];

            _indefiniteAnimatedLayer = [CAShapeLayer layer];
            _indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
            _indefiniteAnimatedLayer.frame = rect;
            _indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
            _indefiniteAnimatedLayer.strokeColor = self.strokeColor.CGColor;
            _indefiniteAnimatedLayer.lineWidth = self.strokeThickness;
            _indefiniteAnimatedLayer.lineCap = kCALineCapRound;
            _indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel;
            _indefiniteAnimatedLayer.path = smoothedPath.CGPath;

            CALayer *maskLayer = [CALayer layer];
            maskLayer.contents = (id)[[UIImage imageNamed:@"SVProgressHUD.bundle/angle-mask"] CGImage];
            maskLayer.frame = _indefiniteAnimatedLayer.bounds;
            _indefiniteAnimatedLayer.mask = maskLayer;

            NSTimeInterval animationDuration = 1;
            CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            animation.fromValue = 0;
            animation.toValue = [NSNumber numberWithFloat:M_PI*2];
            animation.duration = animationDuration;
            animation.timingFunction = linearCurve;
            animation.removedOnCompletion = NO;
            animation.repeatCount = INFINITY;
            animation.fillMode = kCAFillModeForwards;
            animation.autoreverses = NO;
            [_indefiniteAnimatedLayer.mask addAnimation:animation forKey:@"rotate"];

            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.duration = animationDuration;
            animationGroup.repeatCount = INFINITY;
            animationGroup.removedOnCompletion = NO;
            animationGroup.timingFunction = linearCurve;

            CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            strokeStartAnimation.fromValue = @0.015;
            strokeStartAnimation.toValue = @0.515;

            CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            strokeEndAnimation.fromValue = @0.485;
            strokeEndAnimation.toValue = @0.985;
            
            animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
            [_indefiniteAnimatedLayer addAnimation:animationGroup forKey:@"progress"];
        }
    }
    return _indefiniteAnimatedLayer;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;

    [_indefiniteAnimatedLayer removeFromSuperlayer];
    _indefiniteAnimatedLayer = nil;

    if (self.superview) {
        [self layoutAnimatedLayer];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _indefiniteAnimatedLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _indefiniteAnimatedLayer.lineWidth = _strokeThickness;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

@end
