//
//  ViewController.m
//  QDImageCropperExample
//
//  Created by Nikolay on 13/04/14.
//
//

#import "ViewController.h"
#import "QDImageCropper.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;
@property (weak, nonatomic) IBOutlet UIImageView *croppedImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *newPicker = [[UIImagePickerController alloc] init];
        newPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        newPicker.delegate = self;
        [self presentViewController:newPicker animated:YES completion:nil];
    }else
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Source type UIImagePickerControllerSourceTypeSavedPhotosAlbum is not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        QDImageCropper *cropper = [[QDImageCropper alloc] initWithImage:img
                                                        resultImageSize:CGSizeMake(180.0, 100.0)
                                                             completion:^(UIImage *image, CGRect rect, UIImage *croppedImage, UIImage *bledImage) {
                                                                 self.originalImageView.image = image;
                                                                 self.croppedImageView.image = bledImage;
                                                             }];
        cropper.frameXOffset = 20;
        cropper.frameYOffset = 20;
        cropper.topBleedRatio = 0.1;
        cropper.leftBleedRatio = 0.2;
        cropper.bottomBleedRatio = 0.3;
        cropper.rightBleedRatio = 0.4;
        [self presentViewController:cropper animated:YES completion:nil];
    }];
}

@end
