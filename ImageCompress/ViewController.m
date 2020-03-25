//
//  ViewController.m
//  ImageCompress
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 VanJay. All rights reserved.
//

#import "ViewController.h"
#import "HDFileUtil.h"
#import "HDImageCompressTool.h"
#import "MBProgressHUD.h"
#import <Masonry/Masonry.h>

static NSString *const kTableColumnImageIcon = @"ImageIcon";

@interface ViewController () <NSTableViewDataSource, NSTabViewDelegate>
/// 所有图片路径
@property (nonatomic, copy) NSArray<NSURL *> *urls;
/// 路径
@property (nonatomic, copy) NSString *savePath;
/// selecteButton
@property (nonatomic, strong) NSButton *selectButton;
/// 转换
@property (nonatomic, strong) NSButton *exportButton;
/// 大小限制
@property (nonatomic, strong) NSTextField *textField;
/// 限制提示
@property (nonatomic, strong) NSTextField *tipLeft;
/// 单位
@property (nonatomic, strong) NSTextField *tips;
/// 列表
@property (nonatomic, strong) NSTableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self initializePath];
    [self.view addSubview:self.selectButton];
    [self.view addSubview:self.exportButton];
    [self.view addSubview:self.tipLeft];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.tips];
    [self.view addSubview:self.tableView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(NSSizeFromCGSize(CGSizeMake(200, 40)));
    }];

    [self.exportButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectButton.mas_right).offset(30);
        make.top.equalTo(self.selectButton);
        make.size.mas_equalTo(self.selectButton);
    }];

    [self.tipLeft sizeToFit];
    [self.tipLeft mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.exportButton.mas_right).offset(30);
        make.centerY.equalTo(self.exportButton);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(self.selectButton);
    }];

    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipLeft.mas_right).offset(10);
        make.centerY.equalTo(self.selectButton);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];

    [self.tips sizeToFit];
    [self.tips mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textField.mas_right).offset(10);
        make.centerY.equalTo(self.textField);
    }];

    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectButton.mas_bottom).offset(20);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(500);
        make.width.mas_equalTo(1000);
        make.centerX.width.equalTo(self.view);
    }];
}

- (void)initializePath {
    self.savePath =  [NSString stringWithFormat:@"%@/output", [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0]];
    BOOL exist = [HDFileUtil isFileExistedFilePath:self.savePath];
    if (exist) {
        BOOL isDir = [HDFileUtil isDirFilePath:self.savePath];
        if (!isDir) {
            [HDFileUtil removeFileOrDirectory:self.savePath];
        }
    } else {
        [HDFileUtil createDirectoryAtPath:self.savePath];
    }
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.urls.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    NSString *columnID = tableColumn.identifier;
    if ([columnID isEqualToString:@"columnFrist"]) {
        NSURL *info = [self.urls objectAtIndex:rowIndex];
        return info.absoluteString;
    }

    return nil;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    // 获取表格列的标识符
    NSString *columnID = tableColumn.identifier;
    if ([columnID isEqualToString:@"columnFrist"]) {
        NSString *strIdt = @"identifier";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:strIdt owner:self];
        if (!cell) {
            cell = [[NSTableCellView alloc] init];
            cell.identifier = strIdt;
        }

        cell.wantsLayer = YES;
        cell.layer.backgroundColor = [NSColor yellowColor].CGColor;

        NSURL *info = [self.urls objectAtIndex:row];
        cell.textField.stringValue = info.absoluteString;
        return cell;
    }
    return nil;
}

#pragma mark - 行高
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 50;
}

#pragma mark - event response
- (void)selectButtonClickedHandler {

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", @"png", @"jpeg", nil]];
    [panel setCanChooseFiles:YES];           // 是否能选择文件file
    [panel setCanChooseDirectories:YES];     // 是否能打开文件夹
    [panel setAllowsMultipleSelection:YES];  // 是否允许多选file

    BOOL okButtonPressed = ([panel runModal] == NSModalResponseOK);
    if (okButtonPressed) {
        NSArray<NSURL *> *urls = [panel URLs];
        self.urls = [urls filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURL *_Nullable url, NSDictionary<NSString *, id> *_Nullable bindings) {
                              NSString *absoluteString = url.absoluteString;
                              return [absoluteString hasSuffix:@"jpg"] || [absoluteString hasSuffix:@"png"] || [absoluteString hasSuffix:@"jpeg"];
                          }]];
        [self.tableView reloadData];
    }
}

- (void)exportButtonClickedHandler {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
    [panel setNameFieldStringValue:self.urls.firstObject.lastPathComponent];
    [panel setMessage:@"请选择保存的路径"];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"png",@"jpg"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [panel close];
            if (!self.urls || self.urls.count <= 0) {
                [self showAlertWithStyle:NSWarningAlertStyle title:@"还未选择图片" subtitle:@"请选择图片"];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showHUDAddedTo:self.view animated:true];
            });
            
            __block NSInteger index = 0;
            CGFloat limitedSize = self.textField.stringValue.floatValue;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (NSURL *url in self.urls) {
                static NSImage *image;
                image = [[NSImage alloc] initByReferencingURL:url];
                HDCompressedImageBlock block = ^(NSData *imageData) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *fileName = [url lastPathComponent];
                        NSString *path = [NSString stringWithFormat:@"%@/%@", [panel.URL.path stringByDeletingLastPathComponent], fileName];
                        NSError *error;
                        [imageData writeToFile:path options:0 error:&error];
                        if (error) {
                            NSLog(@"写入失败:%@", error.localizedFailureReason);
                        } else {
                            NSLog(@"写入成功");
                        }
                        index++;
                        if (index >= self.urls.count) {
                            [MBProgressHUD hideHUDForView:self.view animated:true];
    //                            [self showAlertWithStyle:NSInformationalAlertStyle title:@"转换成功" subtitle:@"请在桌面 output 目录查看"];
                            [[NSWorkspace sharedWorkspace] openFile:[panel.URL.path stringByDeletingLastPathComponent] withApplication:@"Finder"];
                        }
                    });
                };
                [HDImageCompressTool compressedImage:image
                                             imageKB:limitedSize
                                          imageBlock:block];
                }
            });
        }
    }];
}

#pragma mark - private methods
- (void)showAlertWithStyle:(NSAlertStyle)style title:(NSString *)title subtitle:(NSString *)subtitle {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = style;
    [alert setMessageText:title];
    [alert setInformativeText:subtitle];
    [alert runModal];
}

#pragma mark - getters and setters
- (NSTableView *)tableView {
    if (!_tableView) {
        _tableView = [[NSTableView alloc] init];
        _tableView.dataSource = self;
        _tableView.backgroundColor = NSColor.redColor;
        // tableview获得焦点时的风格
        _tableView.focusRingType = NSFocusRingTypeNone;
        // 行高亮的风格
        _tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
        _tableView.backgroundColor = [NSColor orangeColor];
        // 背景颜色的交替，一行白色，一行灰色。设置后，原来设置的 backgroundColor 就无效了。
        _tableView.usesAlternatingRowBackgroundColors = YES;

        _tableView.gridColor = [NSColor magentaColor];

        NSScrollView *tableContainerView = [[NSScrollView alloc] initWithFrame:CGRectMake(5, 5, 300, 300)];
        tableContainerView.backgroundColor = [NSColor redColor];

        [tableContainerView setDocumentView:self.tableView];
        // 不画背景（背景默认画成白色）
        [tableContainerView setDrawsBackground:NO];
        // 有水平滚动条
        [tableContainerView setHasHorizontalScroller:YES];

        NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@"columnFrist"];
        column1.title = @"路径";
        [column1 setWidth:self.view.frame.size.width];
        [self.tableView addTableColumn:column1];
    }
    return _tableView;
}

- (NSButton *)selectButton {
    if (!_selectButton) {
        NSButton *selectButton = [[NSButton alloc] init];
        [self.view addSubview:selectButton];
        selectButton.title = @"选择图片(支持多选)";
        selectButton.target = self;
        [selectButton setAction:@selector(selectButtonClickedHandler)];
        _selectButton = selectButton;
    }
    return _selectButton;
}

- (NSButton *)exportButton {
    if (!_exportButton) {
        NSButton *exportButton = [[NSButton alloc] init];
        [self.view addSubview:exportButton];
        exportButton.title = @"开始转换";
        exportButton.target = self;
        [exportButton setAction:@selector(exportButtonClickedHandler)];
        _exportButton = exportButton;
    }
    return _exportButton;
}

- (NSTextField *)textField {
    if (!_textField) {
        _textField = [[NSTextField alloc] init];
        _textField.stringValue = @"500";
        [_textField setFont:[NSFont systemFontOfSize:20]];
    }
    return _textField;
}

- (NSTextField *)tipLeft {
    if (!_tipLeft) {
        _tipLeft = [[NSTextField alloc] init];
        _tipLeft.enabled = false;
        _tipLeft.stringValue = @"单张图片大小限制";
        [_tipLeft setFont:[NSFont systemFontOfSize:20]];
    }
    return _tipLeft;
}

- (NSTextField *)tips {
    if (!_tips) {
        _tips = [[NSTextField alloc] init];
        _tips.enabled = false;
        _tips.stringValue = @"KB";
        [_tips setFont:[NSFont systemFontOfSize:20]];
    }
    return _tips;
}
@end
