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
    CGRect bleedFrame;
    CGRect sightFrame;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat scale;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *imageContainer;
@property (strong, nonatomic) QDImageCropperOverlay *overlayView;
@property (strong, nonatomic) QDImageCropperOverlay *bleedView;

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
    _frameYOffset = 20.0;
    _overlayColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8];
    _bleedColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
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

    [self setupFrameXOffset];

    sightFrame = CGRectMake(_frameXOffset, _frameYOffset, _overlayView.frame.size.width - 2 * _frameXOffset, _overlayView.frame.size.height - 2 * _frameYOffset);

    [_overlayView setSightFrame:sightFrame];

    _bleedView = [[QDImageCropperOverlay alloc] initWithFrame:sightFrame];
    [_bleedView setColor:_bleedColor];
    [self addSubview:_bleedView];

    bleedFrame = CGRectMake(_leftBleedRatio * sightFrame.size.width, _topBleedRatio * sightFrame.size.height, (1 - _leftBleedRatio - _rightBleedRatio) * sightFrame.size.width, (1 - _topBleedRatio - _bottomBleedRatio) * sightFrame.size.height);

    [_bleedView setSightFrame:bleedFrame];

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

- (void)setupFrameXOffset
{
    float sightViewW = _overlayView.frame.size.width - 2 * _frameXOffset;
    float sightViewH = _overlayView.frame.size.height - 2 * _frameYOffset;
    float imageSizeW = _imageSize.width;
    float imageSizeH = _imageSize.height;

    float scaledW;
    float scaledH;

    if (sightViewW / imageSizeW < sightViewH / imageSizeH) {
        scaledW = sightViewW;
        scaledH = sightViewW * imageSizeH / imageSizeW;
    } else {
        scaledW = sightViewH * imageSizeW / imageSizeH;
        scaledH = sightViewH;
    }

    _frameXOffset = (_overlayView.frame.size.width - scaledW) / 2;
    _frameYOffset = (_overlayView.frame.size.height - scaledH) / 2;
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

    UIImage *croppedImage;
    @autoreleasepool {
        UIGraphicsBeginImageContext(result.size);
        [_image drawInRect:CGRectMake(-result.origin.x, -result.origin.y, _image.size.width, _image.size.height)];
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    CGRect bleed = [self visibleRect];

    UIImage *bledImage;
    @autoreleasepool {
        UIGraphicsBeginImageContext(bleed.size);
        [_image drawInRect:CGRectMake(-bleed.origin.x, -bleed.origin.y, _image.size.width, _image.size.height)];
        bledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    if (self.delegate != nil) {
        [self.delegate imageCropperView:self didCropImage:_image croppedRect:result croppedImage:croppedImage bledImage:bledImage];
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

- (CGRect)visibleRect
{
    CGRect croppingRect = [self croppingRect];
    return CGRectMake(croppingRect.origin.x + _leftBleedRatio * croppingRect.size.width, croppingRect.origin.y + _topBleedRatio * croppingRect.size.height, (1 - _leftBleedRatio - _rightBleedRatio) * croppingRect.size.width, (1 - _topBleedRatio - _bottomBleedRatio) * croppingRect.size.height);
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
