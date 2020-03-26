//
//  HDAlert.h
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HDAlertItem;
typedef void (^JKAlertHandler)(HDAlertItem *item);

@interface HDAlert : NSAlert
@property (nonatomic, readonly) NSArray *actions;

- (HDAlert *)initWithTitle:(NSString *)title message:(NSString *)message style:(NSAlertStyle)style;
+ (HDAlert *)alertWithTitle:(NSString *)title message:(NSString *)message style:(NSAlertStyle)style;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (HDAlertItem *)addCommonButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

- (void)show:(NSWindow *)window;
- (void)show;

#pragma mark--alert
+ (void)showMessage:(NSString *)message window:(NSWindow *)window completionHandler:(void (^)(NSModalResponse returnCode))handler;
+ (void)showAlert:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message;
@end

@interface HDAlertItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSUInteger tag;
@property (nonatomic, copy) JKAlertHandler action;
@end
