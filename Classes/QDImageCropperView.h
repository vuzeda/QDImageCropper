//
//  QDImageCropperView.h
//  QDImageCropperExample
//
//  Created by Vinicius Uzeda on 1/22/15.
//
//

#import <UIKit/UIKit.h>

@protocol QDImageCropperViewDelegate;



@interface QDImageCropperView : UIView

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGSize imageSize;

@property (assign, nonatomic) CGFloat topBleedRatio;
@property (assign, nonatomic) CGFloat leftBleedRatio;
@property (assign, nonatomic) CGFloat bottomBleedRatio;
@property (assign, nonatomic) CGFloat rightBleedRatio;

@property (nonatomic, assign) CGFloat frameXOffset;
@property (nonatomic, assign) CGFloat frameYOffset;

@property (nonatomic, strong) UIColor *overlayColor;
@property (nonatomic, strong) UIColor *bleedColor;

@property (nonatomic, strong) id<QDImageCropperViewDelegate> delegate;

- (void)crop;

@end



@protocol QDImageCropperViewDelegate <NSObject>

@optional
- (void)imageCropperView:(QDImageCropperView *)imageCropperView didScaleImage:(UIImage *)image scaledRect:(CGRect)scaledRect;

@required
- (void)imageCropperView:(QDImageCropperView *)imageCropperView didCropImage:(UIImage *)image croppedRect:(CGRect)croppedRect croppedImage:(UIImage *)croppedImage bledImage:(UIImage*)bledImage;

@end