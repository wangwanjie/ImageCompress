//
//  ViewController.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Cocoa
import SnapKit

class ViewController: NSViewController {
    var dragDropView: WJDragDropView!

    lazy var supportTypes = ["jpg", "png", "jpeg"]
    static let tableColumn1ItemIdentifier = "tableColumn1ItemIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selectButton)
        view.addSubview(exportButton)
        view.addSubview(limitTitle)
        view.addSubview(textField)
        view.addSubview(unitTip)
        view.addSubview(clearButton)
        view.addSubview(introduceLabel)
        view.addSubview(tableView)
        view.addSubview(deleteButton)

        dragDropView = WJDragDropView()
        view.addSubview(dragDropView)

        dragDropView.acceptedFileExtensions = supportTypes
        dragDropView.delegate = self

        addObserver(self, forKeyPath: "dataSource", options: [.old, .new], context: nil)
    }

    deinit {
        self.removeObserver(self, forKeyPath: "dataSource")
    }

    // MARK: - 懒加载

    @objc lazy var dataSource: [URL] = {
        Array()
    }()

    @objc lazy var tableViewContainer: NSScrollView = {
        let tableViewContainer = NSScrollView()
        tableViewContainer.drawsBackground = true
        tableViewContainer.hasVerticalScroller = true
        tableViewContainer.hasHorizontalRuler = true
        tableViewContainer.documentView = self.tableView
        return tableViewContainer
    }()

    lazy var tableView: NSTableView = {
        let tableView = NSTableView()
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        // tableview获得焦点时的风格
        tableView.focusRingType = .none
        // 行高亮的风格
        tableView.selectionHighlightStyle = .regular
        // 背景颜色的交替，一行白色，一行灰色。设置后，原来设置的 backgroundColor 就无效了。
        tableView.usesAlternatingRowBackgroundColors = true

        tableView.gridColor = .magenta
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: ViewController.tableColumn1ItemIdentifier))
        column1.title = "图片路径"
        column1.width = self.view.frame.size.width
        tableView.addTableColumn(column1)

        return tableView
    }()

    lazy var selectButton: NSButton = {
        let button = NSButton()
        button.title = "选择图片(支持多选)"
        button.font = NSFont.systemFont(ofSize: 20)
        button.target = self
        button.action = #selector(selectButtonClickedHandler)
        return button
    }()

    lazy var exportButton: NSButton = {
        let button = NSButton()
        button.title = "开始转换"
        button.font = NSFont.systemFont(ofSize: 20)
        button.target = self
        button.action = #selector(exportButtonClickedHandler)
        return button
    }()

    lazy var clearButton: NSButton = {
        let button = NSButton()
        button.title = "清空已选"
        button.font = NSFont.systemFont(ofSize: 20)
        button.target = self
        button.action = #selector(clearButtonClickedHandler)
        return button
    }()

    lazy var deleteButton: NSButton = {
        let button = NSButton()
        button.title = "删除选中项"
        button.font = NSFont.systemFont(ofSize: 20)
        button.target = self
        button.action = #selector(deleteButtonClickedHandler)
        return button
    }()

    lazy var textField: NSTextField = {
        let textField = NSTextField()
        textField.font = NSFont.systemFont(ofSize: 20)
        textField.stringValue = "500"
        return textField
    }()

    lazy var limitTitle: NSTextField = {
        let textField = NSTextField()
        textField.isEditable = false
        textField.isBezeled = false
        textField.font = NSFont.systemFont(ofSize: 20)
        textField.stringValue = "单张图片大小限制:"
        textField.backgroundColor = .clear
        return textField
    }()

    lazy var unitTip: NSTextField = {
        let textField = NSTextField()
        textField.isEditable = false
        textField.isBezeled = false
        textField.font = NSFont.systemFont(ofSize: 20)
        textField.stringValue = "KB"
        textField.backgroundColor = .clear
        return textField
    }()

    lazy var introduceLabel: NSTextField = {
        let textField = NSTextField()
        textField.isEditable = false
        textField.isBezeled = false
        textField.font = NSFont.systemFont(ofSize: 18)
        textField.stringValue = "注意：右上角输入框输入单张图片限制大小，默认为不超过 500KB，图片支持 jpg、jpeg、png，支持文件和文件夹混合选择或者混合拖拽，如果选择或者拖拽的文件包含文件夹，将递归获取该文件夹下所有的图片（支持格式范围内），会自动去重，如果目标保存目录有同名文件也会覆盖"
        textField.backgroundColor = .clear
        return textField
    }()
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return dataSource.count
    }

    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let columnID = tableColumn?.identifier
        if columnID != nil, columnID?.rawValue == ViewController.tableColumn1ItemIdentifier {
            let url = dataSource[row]
            return (url.path as NSString).hd_URLDecoded()
        }

        return nil
    }

    func tableView(_: NSTableView, heightOfRow _: Int) -> CGFloat {
        return 50
    }
}

// MARK: - layout

extension ViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()

        selectButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(20)
            make.size.equalTo(NSSize(width: 200, height: 40))
        }

        exportButton.snp.makeConstraints { make in
            make.left.equalTo(selectButton.snp_right).offset(30)
            make.size.centerY.equalTo(selectButton)
        }

        limitTitle.snp.makeConstraints { make in
            make.left.equalTo(self.exportButton.snp_right).offset(30)
            make.centerY.equalTo(self.exportButton)
            make.height.equalTo(30)
            make.width.equalTo(180)
        }

        textField.snp.makeConstraints { make in
            make.left.equalTo(self.limitTitle.snp_right).offset(5)
            make.centerY.equalTo(self.selectButton)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }

        unitTip.snp.makeConstraints { make in
            make.left.equalTo(self.textField.snp_right).offset(5)
            make.centerY.equalTo(self.textField)
            make.height.equalTo(30)
            make.width.equalTo(35)
        }

        clearButton.snp.makeConstraints { make in
            make.left.equalTo(self.unitTip.snp_right).offset(30)
            make.top.equalTo(self.selectButton)
            make.size.equalTo(self.selectButton)
        }

        introduceLabel.sizeToFit()
        introduceLabel.snp.makeConstraints { make in
            make.left.equalTo(self.selectButton)
            make.right.equalTo(self.clearButton)
            make.top.equalTo(self.selectButton.snp_bottom).offset(10)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.introduceLabel.snp_bottom).offset(20)
            make.height.equalTo(500)
            make.width.equalTo(1200)
            make.centerX.width.equalTo(self.view)
        }

        deleteButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(30)
            make.bottom.equalTo(self.view).offset(-10)
            make.top.equalTo(self.tableView.snp_bottom).offset(10)
        }

        dragDropView.snp.makeConstraints { make in
            make.center.equalTo(self.tableView)
            make.size.equalTo(NSSize(width: 400, height: 400))
        }
    }
}
