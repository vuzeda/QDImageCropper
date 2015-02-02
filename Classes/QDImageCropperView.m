//
//  QDImageCropperView.m
//  QDImageCropperExample
//
//  Created by Vinicius Uzeda on 1/22/15.
//
//

#import "QDImageCropperView.h"
#import "QDImageCropperOverlay.h"
#import "UIImage+QDResize.h"

@interface QDImageCropperView () <UIScrollViewDelegate> {
    CGRect sightFrame;
}

@property (nonatomic, assign) CGFloat frameYOffset;

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat scale;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *imageContainer;
@property (strong, nonatomic) QDImageCropperOverlay *overlayView;

@end

@implementation QDImageCropperView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self postInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self postInit];
    }
    return self;
}

-(void)postInit
{
    _frameXOffset = 20.0;
    _overlayColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8];
}

-(void)setImage:(UIImage *)image
{
    NSParameterAssert(image);

    if (_image == nil || ![_image isEqual:image]) {
        _image = image;
        _imageView = [[UIImageView alloc] initWithImage:_image];
    }
}

-(void)setImageSize:(CGSize)imageSize
{
    NSAssert(!CGSizeEqualToSize(imageSize, CGSizeZero), @"Set image size!");

    if (CGSizeEqualToSize(_imageSize, CGSizeZero) || !CGSizeEqualToSize(_imageSize, imageSize)) {
        _imageSize = imageSize;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [_scrollView setBackgroundColor:[UIColor blackColor]];
    [_scrollView setDelegate:self];
    [self addSubview:_scrollView];

    _imageContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [_scrollView addSubview:_imageContainer];

    _overlayView = [[QDImageCropperOverlay alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [_overlayView setColor:_overlayColor];
    [self addSubview:_overlayView];

    float height = (_overlayView.frame.size.width - 2 * _frameXOffset) * _imageSize.height / _imageSize.width;

    _frameYOffset = (_overlayView.frame.size.height - height) / 2.0;

    sightFrame = CGRectMake(_frameXOffset, _frameYOffset, _overlayView.frame.size.width - 2 * _frameXOffset, height);

    [_overlayView setSightFrame:sightFrame];

    double coef;
    if (_image.size.width / _image.size.height > sightFrame.size.width / sightFrame.size.height) {
        coef = _image.size.height / sightFrame.size.height;
    } else {
        coef = _image.size.width / sightFrame.size.width;
    }

    CGRect frame = sightFrame;
    frame.size.height = _image.size.height/coef;
    frame.size.width = _image.size.width/coef;
    [_imageView setFrame:frame];

    [_imageContainer addSubview:_imageView];

    _scale = MIN(_image.size.width / _imageSize.width, _image.size.height / _imageSize.height);

    [_scrollView setMinimumZoomScale:1.0];
    [_scrollView setMaximumZoomScale:_scale];

    [_imageContainer setFrame:CGRectMake(0.0, 0.0, _imageView.frame.size.width + sightFrame.origin.x * 2, _imageView.frame.size.height + sightFrame.origin.y * 2)];

    [self setupContent];
}

- (void)setupContent
{
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(imageCropperView:didScaleImage:scaledRect:)]) {
        [self.delegate imageCropperView:self didScaleImage:_image scaledRect:[self croppingRect]];
    }

    [_scrollView setContentSize:CGSizeMake(_imageContainer.frame.size.width - sightFrame.origin.x * 2 * (_scrollView.zoomScale - 1.0), _imageContainer.frame.size.height - (sightFrame.origin.y * 2) * (_scrollView.zoomScale - 1.0))];

    CGRect frame = _imageContainer.frame;

    frame.origin.x = (_scrollView.contentSize.width - _imageContainer.frame.size.width) / 2.0;
    frame.origin.y = (_scrollView.contentSize.height - _imageContainer.frame.size.height) / 2.0;

    _imageContainer.frame = frame;
}

- (void)crop
{
    CGRect result = [self croppingRect];

    UIGraphicsBeginImageContext(result.size);
    [_image drawInRect:CGRectMake(-result.origin.x, -result.origin.y, _image.size.width, _image.size.height)];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (self.delegate != nil) {
        [self.delegate imageCropperView:self didCropImage:_image croppedRect:result croppedImage:croppedImage];
    }
}

- (CGRect)croppingRect
{
    float coef = (float) (_scrollView.zoomScale / _scale);

    CGRect croppingRect;
    croppingRect.origin.x = roundf((float) (_scrollView.contentOffset.x / (_scrollView.contentSize.width - _frameXOffset * 2.0) * _image.size.width));
    croppingRect.origin.y = roundf(_scrollView.contentOffset.y / (_scrollView.contentSize.height - _frameYOffset * 2.0) * _image.size.height);
    croppingRect.size.width = roundf(_imageSize.width / coef);
    croppingRect.size.height = roundf(_imageSize.height / coef);

    return croppingRect;
}

#pragma mark - ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainer;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self setupContent];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
