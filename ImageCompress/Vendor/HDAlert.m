//
//  HDAlert.m
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

#import "HDAlert.h"
@implementation HDAlertItem
@end

@interface HDAlert ()
@property (nonatomic, strong) NSMutableArray *items;
@end
@implementation HDAlert

#pragma mark-- init
- (id)initWithTitle:(NSString *)title message:(NSString *)message style:(NSAlertStyle)style {
    self = [super init];
    if (self != nil) {
        _items = [NSMutableArray array];
        self.alertStyle = style;
        self.messageText = [title description];
        self.informativeText = [message description];
    }
    return self;
}
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message style:(NSAlertStyle)style {
    return [[self alloc] initWithTitle:title message:message style:style];
}

#pragma mark-- add button and handle
- (NSInteger)addButtonWithTitle:(NSString *)title {
    NSAssert(title != nil, @"all title must be non-nil");
    HDAlertItem *item = [self addCommonButtonWithTitle:title
                                               handler:^(HDAlertItem *item) {
                                                   NSLog(@"no action");
                                               }];
    return [_items indexOfObject:item];
}

- (HDAlertItem *)addCommonButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler {
    return [self addButtonWithTitle:title handler:handler];
}
- (HDAlertItem *)addButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler {
    NSAssert(title != nil, @"all title must be non-nil");
    HDAlertItem *item = [[HDAlertItem alloc] init];
    item.title = [title description];
    item.action = handler;
    [super addButtonWithTitle:[title description]];
    [_items addObject:item];
    item.tag = [_items indexOfObject:item];
    return item;
}
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex {
    HDAlertItem *item = _items[buttonIndex];
    return item.title;
}

- (NSArray *)actions {
    return [_items copy];
}

#pragma-- mark show
- (void)show:(NSWindow *)window {
    [self beginSheetModalForWindow:window
                 completionHandler:^(NSModalResponse returnCode) {
                     HDAlertItem *item = self.items[returnCode - 1000];
                     item.action(item);
                 }];
    [window becomeKeyWindow];
}

- (void)show {
    NSRect frame = NSMakeRect(0, 0, 200, 100);
    NSUInteger styleMask = NSWindowStyleMaskBorderless;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:false];
    [window setBackgroundColor:[NSColor clearColor]];
    [window makeKeyAndOrderFront:window];
    [window orderFrontRegardless];
    [window center];
    [self beginSheetModalForWindow:window
                 completionHandler:^(NSModalResponse returnCode) {
                     HDAlertItem *item = self.items[returnCode - 1000];
                     item.action(item);
                 }];
    [window becomeKeyWindow];
}

#pragma mark--alert
+ (void)showMessage:(NSString *)message window:(NSWindow *)window completionHandler:(void (^)(NSModalResponse returnCode))handler {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert beginSheetModalForWindow:window
                  completionHandler:^(NSModalResponse returnCode) {
                      handler(returnCode);
                  }];
}

+ (void)showAlert:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:style];
    [alert runModal];
}
@end
