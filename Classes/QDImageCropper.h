//
//  QDImageCropper.h
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import <UIKit/UIKit.h>

@interface QDImageCropper : UINavigationController

@property (nonatomic, assign) CGFloat frameXOffset;
@property (nonatomic, assign) CGFloat frameYOffset;
@property (nonatomic, assign) CGFloat topBleedRatio;
@property (nonatomic, assign) CGFloat leftBleedRatio;
@property (nonatomic, assign) CGFloat bottomBleedRatio;
@property (nonatomic, assign) CGFloat rightBleedRatio;
@property (nonatomic, strong) UIColor *overlayColor;

- (instancetype)initWithImage:(UIImage*)image resultImageSize:(CGSize)imageSize completion:(void(^)(UIImage *image, CGRect rect, UIImage *croppedImage, UIImage *bledImage))completion;
- (void)setBackButton:(UIButton *)button;
- (void)setCropButton:(UIButton *)button;

@end
