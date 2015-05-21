//
//  UIImage+QDColor.m
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "UIImage+QDColor.h"

@implementation UIImage (QDColor)

+ (UIImage *)imageWithColor:(UIColor *)color width:(double)width height:(double)height{
    UIImage *image;

    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, width, height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);

        image = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
    }
    
    return image;
}

@end
