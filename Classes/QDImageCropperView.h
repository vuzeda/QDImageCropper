//
//  QDImageCropperView.h
//  QDImageCropperExample
//
//  Created by Vinicius Uzeda on 1/22/15.
//
//

#import <UIKit/UIKit.h>

@interface QDImageCropperView : UIView

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGSize imageSize;

@property (nonatomic, assign) CGFloat frameXOffset;
@property (nonatomic, strong) UIColor *overlayColor;

- (void)crop:(void(^)(UIImage *image, CGRect rect, UIImage *croppedImage))completion;

@end
