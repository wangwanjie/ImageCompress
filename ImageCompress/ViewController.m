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
#import "NSString+URL.h"
#import <Masonry/Masonry.h>

@interface ViewController () <NSTableViewDataSource, NSTabViewDelegate>
/// 所有图片路径
@property (nonatomic, strong) NSMutableArray<NSURL *> *dataSource;
/// selecteButton
@property (nonatomic, strong) NSButton *selectButton;
/// 转换
@property (nonatomic, strong) NSButton *exportButton;
/// 清空
@property (nonatomic, strong) NSButton *clearButton;
/// 删除选择项目
@property (nonatomic, strong) NSButton *deleteButton;
/// 大小限制
@property (nonatomic, strong) NSTextField *textField;
/// 限制提示
@property (nonatomic, strong) NSTextField *limitTitle;
/// 说明
@property (nonatomic, strong) NSTextField *introduceLabel;
/// 单位
@property (nonatomic, strong) NSTextField *unitTip;
/// 列表
@property (nonatomic, strong) NSTableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.selectButton];
    [self.view addSubview:self.exportButton];
    [self.view addSubview:self.limitTitle];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.unitTip];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.introduceLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.deleteButton];

    // 监听数据源变化
    [self addObserver:self forKeyPath:@"dataSource" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc {
    [self.dataSource removeObserver:self forKeyPath:@"count"];
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

    [self.limitTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.exportButton.mas_right).offset(30);
        make.centerY.equalTo(self.exportButton);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(180);
    }];

    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.limitTitle.mas_right).offset(5);
        make.centerY.equalTo(self.selectButton);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];

    [self.unitTip mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textField.mas_right).offset(5);
        make.centerY.equalTo(self.textField);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(35);
    }];

    [self.clearButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.unitTip.mas_right).offset(30);
        make.top.equalTo(self.selectButton);
        make.size.mas_equalTo(self.selectButton);
    }];

    [self.introduceLabel sizeToFit];
    [self.introduceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectButton);
        make.right.equalTo(self.clearButton);
        make.top.equalTo(self.selectButton.mas_bottom).offset(10);
    }];

    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.introduceLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(500);
        make.width.mas_equalTo(1200);
        make.centerX.width.equalTo(self.view);
    }];

    [self.deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(400);
        make.height.mas_equalTo(30);
        make.bottom.equalTo(self.view).offset(-10);
        make.top.equalTo(self.tableView.mas_bottom).offset(10);
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"dataSource"]) {

        NSArray *newValue = change[NSKeyValueChangeNewKey];
        if (newValue && [newValue isKindOfClass:NSArray.class]) {
            if (newValue.count > 0) {
                self.selectButton.title = @"继续添加";
            } else {
                self.selectButton.title = @"选择图片(支持多选)";
            }
        }
    }
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSource.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    NSString *columnID = tableColumn.identifier;
    if ([columnID isEqualToString:@"columnFrist"]) {
        NSURL *info = [self.dataSource objectAtIndex:rowIndex];
        return info.path.hd_URLDecodedString;
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
    NSArray<NSString *> *types = @[@"jpg", @"png", @"jpeg"];
    [panel setAllowedFileTypes:types];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    [panel beginSheetModalForWindow:self.view.window
                  completionHandler:^(NSModalResponse result) {
                      if (result == NSModalResponseOK) {
                          NSArray<NSURL *> *dataSource = [panel URLs];
                          NSMutableArray<NSURL *> *finalList = [NSMutableArray array];
                          for (NSURL *url in dataSource) {
                              BOOL isDir = [HDFileUtil isDirFilePath:url.path];
                              if (isDir) {
                                  NSArray *allFileInDirAndSubDir = [HDFileUtil getFileListRecursively:url.path];

                                  for (NSString *subFilePath in allFileInDirAndSubDir) {
                                      NSURL *subFileURL = [NSURL URLWithString:subFilePath.hd_URLEncodedString];
                                      NSString *pathExtension = subFileURL.pathExtension;
                                      if ([types containsObject:pathExtension]) {
                                          [finalList addObject:subFileURL];
                                      }
                                  }
                              } else {
                                  NSString *pathExtension = url.pathExtension;
                                  if ([types containsObject:pathExtension]) {
                                      [finalList addObject:[NSURL URLWithString:url.path.hd_URLEncodedString]];
                                  }
                              }
                          }
                          [self.dataSource addObjectsFromArray:finalList];
                          // 去重
                          NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
                          for (NSURL *url in self.dataSource) {
                              [dictM setObject:url forKey:url];
                          }
                          self.dataSource = dictM.allValues.mutableCopy;
                          [self.tableView reloadData];
                      }
                  }];
}

- (void)exportButtonClickedHandler {
    if (!self.dataSource || self.dataSource.count <= 0) {
        [self showAlertWithStyle:NSWarningAlertStyle title:@"还未选择图片" subtitle:@"请选择图片"];
        return;
    }

    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0]]];
    [panel setNameFieldStringValue:[NSString stringWithFormat:@"图片名.%@", self.dataSource.firstObject.pathExtension]];
    [panel setMessage:@"请选择保存的路径"];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.view.window
                  completionHandler:^(NSModalResponse result) {
                      if (result == NSFileHandlingPanelOKButton) {
                          [panel close];

                          dispatch_async(dispatch_get_main_queue(), ^{
                              [MBProgressHUD showHUDAddedTo:self.view animated:true];
                          });

                          __block NSInteger index = 0;
                          CGFloat limitedSize = self.textField.stringValue.floatValue;

                          void (^compressImage)(void) = ^() {
                              for (NSURL *url in self.dataSource) {
                                  HDCompressedImageBlock block = ^(NSData *imageData) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          NSString *fileName = [url lastPathComponent];
                                          NSString *path = [NSString stringWithFormat:@"%@/%@", [panel.URL.path stringByDeletingLastPathComponent], fileName];
                                          NSError *error;
                                          NSLog(@"path:%@", path);
                                          [imageData writeToFile:path options:0 error:&error];
                                          if (error) {
                                              NSLog(@"写入失败: %@", error.localizedFailureReason);
                                          } else {
                                              NSLog(@"写入成功");
                                          }
                                          index++;
                                          if (index >= self.dataSource.count) {
                                              [MBProgressHUD hideHUDForView:self.view animated:true];
                                              [[NSWorkspace sharedWorkspace] openFile:[panel.URL.path stringByDeletingLastPathComponent] withApplication:@"Finder"];
                                          }
                                      });
                                  };

                                  static NSImage *image;
                                  image = [[NSImage alloc] initByReferencingURL:[NSURL fileURLWithPath:url.path]];
                                  [HDImageCompressTool compressedImage:image
                                                               imageKB:limitedSize
                                                            imageBlock:block];
                              }
                          };

                          dispatch_async(dispatch_get_global_queue(0, 0), compressImage);
                      }
                  }];
}

- (void)clearButtonClickedHandler {
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
}

- (void)deleteButtonClickedHandler {
    if (self.tableView.numberOfSelectedRows > 0) {
        NSArray *results = [self.dataSource copy];
        NSIndexSet *selectedIndexSet = self.tableView.selectedRowIndexes;
        NSUInteger index = [selectedIndexSet firstIndex];
        while (index != NSNotFound) {
            if (index < results.count) {
                NSURL *url = [results objectAtIndex:index];
                NSLog(@"删除 %@", url.path);
            }
            index = [selectedIndexSet indexGreaterThanIndex:index];
        }
        [self.dataSource removeObjectsAtIndexes:selectedIndexSet];
        [self.tableView reloadData];
    } else {
        [self showAlertWithStyle:NSAlertStyleWarning title:@"无选中项" subtitle:@"请先选择图片"];
    }
}

#pragma mark - private methods
- (void)showAlertWithStyle:(NSAlertStyle)style title:(NSString *)title subtitle:(NSString *)subtitle {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = style;
    [alert setMessageText:title];
    [alert setInformativeText:subtitle];
    [alert runModal];
}

#pragma mark - lazy load
- (NSTableView *)tableView {
    if (!_tableView) {
        _tableView = [[NSTableView alloc] init];
        _tableView.dataSource = self;
        _tableView.backgroundColor = NSColor.redColor;
        _tableView.allowsMultipleSelection = true;
        // tableview获得焦点时的风格
        _tableView.focusRingType = NSFocusRingTypeNone;
        // 行高亮的风格
        _tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
        // 背景颜色的交替，一行白色，一行灰色。设置后，原来设置的 backgroundColor 就无效了。
        _tableView.usesAlternatingRowBackgroundColors = YES;

        _tableView.gridColor = [NSColor magentaColor];

        NSScrollView *tableContainerView = [[NSScrollView alloc] init];
        [tableContainerView setDocumentView:self.tableView];
        // 不画背景（背景默认画成白色）
        [tableContainerView setDrawsBackground:NO];
        // 有水平滚动条
        [tableContainerView setHasVerticalRuler:YES];
        tableContainerView.autohidesScrollers = NO;

        NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@"columnFrist"];
        column1.title = @"图片路径";
        [column1 setWidth:self.view.frame.size.width];
        [self.tableView addTableColumn:column1];
    }
    return _tableView;
}

- (NSButton *)selectButton {
    if (!_selectButton) {
        NSButton *button = [[NSButton alloc] init];
        [self.view addSubview:button];
        button.title = @"选择图片(支持多选)";
        button.font = [NSFont systemFontOfSize:20];
        button.target = self;
        [button setAction:@selector(selectButtonClickedHandler)];
        _selectButton = button;
    }
    return _selectButton;
}

- (NSButton *)exportButton {
    if (!_exportButton) {
        NSButton *button = [[NSButton alloc] init];
        [self.view addSubview:button];
        button.title = @"开始转换";
        button.font = [NSFont systemFontOfSize:20];
        button.target = self;
        [button setAction:@selector(exportButtonClickedHandler)];
        _exportButton = button;
    }
    return _exportButton;
}

- (NSButton *)clearButton {
    if (!_clearButton) {
        NSButton *button = [[NSButton alloc] init];
        [self.view addSubview:button];
        button.title = @"清空已选";
        button.font = [NSFont systemFontOfSize:20];
        button.target = self;
        [button setAction:@selector(clearButtonClickedHandler)];
        _clearButton = button;
    }
    return _clearButton;
}

- (NSButton *)deleteButton {
    if (!_deleteButton) {
        NSButton *button = [[NSButton alloc] init];
        [self.view addSubview:button];
        button.title = @"删除选中项";
        button.font = [NSFont systemFontOfSize:20];
        button.target = self;
        [button setAction:@selector(deleteButtonClickedHandler)];
        _deleteButton = button;
    }
    return _deleteButton;
}

- (NSTextField *)textField {
    if (!_textField) {
        _textField = [[NSTextField alloc] init];
        _textField.stringValue = @"500";
        [_textField setFont:[NSFont systemFontOfSize:20]];
    }
    return _textField;
}

- (NSTextField *)limitTitle {
    if (!_limitTitle) {
        _limitTitle = [[NSTextField alloc] init];
        _limitTitle.editable = false;
        _limitTitle.bezeled = false;
        _limitTitle.stringValue = @"单张图片大小限制:";
        _limitTitle.backgroundColor = NSColor.clearColor;
        _limitTitle.font = [NSFont systemFontOfSize:20];
    }
    return _limitTitle;
}

- (NSTextField *)unitTip {
    if (!_unitTip) {
        _unitTip = [[NSTextField alloc] init];
        _unitTip.editable = false;
        _unitTip.bezeled = false;
        _unitTip.stringValue = @"KB";
        _unitTip.backgroundColor = NSColor.clearColor;
        _unitTip.font = [NSFont systemFontOfSize:20];
    }
    return _unitTip;
}

- (NSTextField *)introduceLabel {
    if (!_introduceLabel) {
        _introduceLabel = [[NSTextField alloc] init];
        _introduceLabel.editable = false;
        _introduceLabel.bezeled = false;
        _introduceLabel.stringValue = @"注意：右上角输入框输入单张图片限制大小，默认为不超过 500KB，图片支持 jpg、jpeg、png，支持文件和文件夹混合选择，如果选择的是文件夹，将递归获取该文件夹下所有的图片（支持格式范围内），会自动去重，如果目标保存目录有同名文件也会覆盖";
        _introduceLabel.backgroundColor = NSColor.clearColor;
        _introduceLabel.font = [NSFont systemFontOfSize:18];
    }
    return _introduceLabel;
}

- (NSMutableArray<NSURL *> *)dataSource {
    return _dataSource ?: ({ _dataSource = NSMutableArray.array; });
}
@end
