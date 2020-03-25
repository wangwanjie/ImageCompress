//
//  NSString+URL.h
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (URL)
- (NSString *)hd_URLEncodedString;
- (NSString *)hd_URLDecodedString;
@end

NS_ASSUME_NONNULL_END
