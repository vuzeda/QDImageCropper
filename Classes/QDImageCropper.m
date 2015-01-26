//
//  QDImageCropper.m
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "QDImageCropper.h"
#import "QDImageCropperView.h"

@interface QDImageCropper () <QDImageCropperViewDelegate> {
    void(^_completion)(UIImage *image, CGRect rect, UIImage *croppedImage);
}

@property (strong, nonatomic) QDImageCropperView *imageCropperView;

@property (strong, nonatomic) UIButton *bButton;
@property (strong, nonatomic) UIButton *cButton;

@end

@implementation QDImageCropper

@dynamic frameXOffset;
@dynamic overlayColor;

- (instancetype)initWithImage:(UIImage *)image resultImageSize:(CGSize)imageSize completion:(void (^)(UIImage *, CGRect, UIImage *))completion{
    NSParameterAssert(completion && image);
    NSAssert(!CGSizeEqualToSize(imageSize, CGSizeZero), @"Set image size!");

    self = [super init];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        _imageCropperView = [[QDImageCropperView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        _imageCropperView.image = image;
        _imageCropperView.imageSize = imageSize;
        _imageCropperView.delegate = self;

        _completion = completion;

        _bButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 10.0, 50.0, 20.0)];
        [_bButton setTitle:@"Back" forState:UIControlStateNormal];

        _cButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 10.0, 50.0, 20.0)];
        [_cButton setTitle:@"Crop" forState:UIControlStateNormal];

    }
    return self;
}

-(CGFloat)frameXOffset
{
    return _imageCropperView.frameXOffset;
}

-(void)setFrameXOffset:(CGFloat)frameXOffset
{
    _imageCropperView.frameXOffset = frameXOffset;
}

-(UIColor *)overlayColor
{
    return _imageCropperView.overlayColor;
}

-(void)setOverlayColor:(UIColor *)overlayColor
{
    _imageCropperView.overlayColor = overlayColor;
}

- (void)setBackButton:(UIButton *)button {
    [_bButton removeFromSuperview];
    _bButton = button;
    [_bButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bButton];
    [_bButton setFrame:CGRectMake(10.0, 15.0, _bButton.frame.size.width, _bButton.frame.size.height)];
}

- (void)setCropButton:(UIButton *)button {
    [_cButton removeFromSuperview];
    _cButton = button;
    [_cButton addTarget:self action:@selector(crop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cButton];
    [_cButton setFrame:CGRectMake(self.view.frame.size.width - 10.0 - _cButton.frame.size.width, 15.0, _cButton.frame.size.width, _cButton.frame.size.height)];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //NSAssert(self.navigationController, @"Cropper needs navigation controller");

    [self.view addSubview:_imageCropperView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(crop)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(back)];

    [self setBackButton:_bButton];
    [self setCropButton:_cButton];
}

- (void)crop
{
    [_imageCropperView crop];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark QDImageCropperViewDelegate

-(void)imageCropperView:(QDImageCropperView *)imageCropperView didScaleImage:(UIImage *)image scaledRect:(CGRect)scaledRect
{
    // NSLog(@"QDImageCropperView: did scale image to [(%f, %f), (%f, %f)]", scaledRect.origin.x, scaledRect.origin.y, scaledRect.size.width, scaledRect.size.height);
}

-(void)imageCropperView:(QDImageCropperView *)imageCropperView didCropImage:(UIImage *)image croppedRect:(CGRect)croppedRect croppedImage:(UIImage *)croppedImage
{
    _completion(image, croppedRect, croppedImage);

    [self back];
}

@end
