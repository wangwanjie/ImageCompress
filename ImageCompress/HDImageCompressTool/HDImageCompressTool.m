//
//  HDImageCompressTool.m
//  HDServiceKit
//
//  Created by VanJay on 2020/2/25.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDImageCompressTool.h"

@implementation HDImageCompressTool

+ (NSData *)compressedImageWithImage:(NSImage *)image compression:(CGFloat)compression {
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compression] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    return imageData;
}

+ (void)compressedImage:(NSImage *)image imageKB:(CGFloat)imageKB imageBlock:(HDCompressedImageBlock)block {
    // 二分法压缩图片
    CGFloat compression = 1;

    NSData *imageData = [self compressedImageWithImage:image compression:compression];

    // 需要压缩的字节Byte，iOS系统内部的进制1000
    NSUInteger fImageBytes = imageKB * 1000;
    if (imageData.length <= fImageBytes) {
        block(imageData);
        return;
    }
    CGFloat max = 1;
    CGFloat min = 0;
    // 指数二分处理，首先计算最小值
    compression = pow(2, -6);
    imageData = [self compressedImageWithImage:image compression:compression];
    if (imageData.length < fImageBytes) {
        // 二分最大10次，区间范围精度最大可达0.00097657；最大6次，精度可达0.015625
        for (int i = 0; i < 6; ++i) {
            compression = (max + min) / 2;
            imageData = [self compressedImageWithImage:image compression:compression];
            // 容错区间范围0.9～1.0
            if (imageData.length < fImageBytes * 0.9) {
                min = compression;
            } else if (imageData.length > fImageBytes) {
                max = compression;
            } else {
                break;
            }
        }

        !block ?: block(imageData);
        return;
    }

    // 对于图片太大上面的压缩比即使很小压缩出来的图片也是很大，不满足使用。
    // 然后再一步绘制压缩处理
    NSImage *resultImage = [[NSImage alloc] initWithData:imageData];
    while (imageData.length > fImageBytes) {
        @autoreleasepool {
            CGFloat ratio = (CGFloat)fImageBytes / imageData.length;
            CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                     (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
            resultImage = [self createImageForData:imageData maxPixelSize:MAX(size.width, size.height)];
            imageData = [self compressedImageWithImage:resultImage compression:compression];
        }
    }

    // 整理后的图片尽量不要用NSImageJPEGRepresentation方法转换，后面参数1.0并不表示的是原质量转换。
    !block ?: block(imageData);
}

+ (void)resetSizeOfImage:(NSImage *)orignalImage imageKB:(CGFloat)imageKB imageBlock:(HDCompressedImageBlock)block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 二分法压缩图片
        CGFloat compression = 1;
        __block NSData *imageData = [self compressedImageWithImage:orignalImage compression:compression];
        NSUInteger fImageBytes = imageKB * 1000;
        if (imageData.length <= fImageBytes) {
            !block ?: block(imageData);
            return;
        }
        // 这里二分之前重绘一下，就能解决掉内存的不足导致的问题。
        NSImage *newImage = [self createImageForData:imageData maxPixelSize:MAX((NSUInteger)orignalImage.size.width, (NSUInteger)orignalImage.size.height)];
        [self halfFuntionImage:newImage
                   maxSizeByte:fImageBytes
                          back:^(NSData *halfImageData, CGFloat compress) {
                              // 再一步绘制压缩处理
                              NSImage *resultImage = [[NSImage alloc] initWithData:halfImageData];
                              imageData = halfImageData;
                              while (imageData.length > fImageBytes) {
                                  CGFloat ratio = (CGFloat)fImageBytes / imageData.length;
                                  // 使用NSUInteger不然由于精度问题，某些图片会有白边
                                  CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                                           (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
                                  resultImage = [self createImageForData:imageData maxPixelSize:MAX(size.width, size.height)];
                                  imageData = [self compressedImageWithImage:resultImage compression:compress];
                              }
                              // 整理后的图片尽量不要用NSImageJPEGRepresentation方法转换，后面参数1.0并不表示的是原质量转换。
                              block(imageData);
                          }];
    });
}

#pragma mark - 二分法
+ (void)halfFuntionImage:(NSImage *)image maxSizeByte:(NSInteger)maxSizeByte back:(void (^)(NSData *halfImageData, CGFloat compress))block {
    // 二分法压缩图片
    CGFloat compression = 1;
    NSData *imageData = [self compressedImageWithImage:image compression:compression];
    CGFloat max = 1;
    CGFloat min = 0;
    // 指数二分处理，s首先计算最小值
    compression = pow(2, -6);
    imageData = [self compressedImageWithImage:image compression:compression];
    if (imageData.length < maxSizeByte) {
        // 二分最大10次，区间范围精度最大可达0.00097657；最大6次，精度可达0.015625
        for (int i = 0; i < 6; i++) {
            compression = (max + min) / 2;
            imageData = [self compressedImageWithImage:image compression:compression];
            //容错区间范围0.9～1.0
            if (imageData.length < maxSizeByte * 0.9) {
                min = compression;
            } else if (imageData.length > maxSizeByte) {
                max = compression;
            } else {
                break;
            }
        }
    }
    if (block) {
        block(imageData, compression);
    }
}

+ (NSImage *)createImageForData:(NSData *)data maxPixelSize:(NSUInteger)size {
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
        (NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
        (NSString *)kCGImageSourceThumbnailMaxPixelSize: @(size),
        (NSString *)kCGImageSourceCreateThumbnailWithTransform: @YES,
    });
    CFRelease(source);
    CFRelease(provider);
    if (!imageRef) {
        return nil;
    }
    NSImage *toReturn = [[NSImage alloc] initWithCGImage:imageRef size:NSMakeSize(size, size)];
    CFRelease(imageRef);
    return toReturn;
}
@end
