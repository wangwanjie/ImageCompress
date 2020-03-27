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

        setupSubViews()
        addDataSourceObserver()
    }

    fileprivate func setupSubViews() {
        view.addSubview(selectButton)
        view.addSubview(exportButton)
        view.addSubview(limitTitle)
        view.addSubview(textField)
        view.addSubview(unitTip)
        view.addSubview(clearButton)
        view.addSubview(introduceLabel)
        view.addSubview(tableViewContainer)
        view.addSubview(deleteButton)

        dragDropView = WJDragDropView()
        view.addSubview(dragDropView)

        dragDropView.acceptedFileExtensions = supportTypes
        dragDropView.delegate = self
    }

    deinit {
        removeDataSourceObserver()
    }

    // MARK: - 懒加载

    @objc dynamic lazy var dataSource: [URL] = {
        Array()
    }()

    lazy var tableViewContainer: NSScrollView = {
        let tableViewContainer = NSScrollView()
        tableViewContainer.drawsBackground = true
        tableViewContainer.hasVerticalScroller = true
        tableViewContainer.autohidesScrollers = false
        tableViewContainer.documentView = tableView
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
        column1.minWidth = 1000
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

        let sideMargin = 20

        selectButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(sideMargin)
            make.top.equalTo(view).offset(sideMargin)
            make.size.equalTo(NSSize(width: 200, height: 40))
        }

        exportButton.snp.makeConstraints { make in
            make.left.equalTo(selectButton.snp_right).offset(30)
            make.size.centerY.equalTo(selectButton)
        }

        limitTitle.snp.makeConstraints { make in
            make.left.equalTo(exportButton.snp_right).offset(30)
            make.centerY.equalTo(exportButton)
            make.height.equalTo(30)
            make.width.equalTo(180)
        }

        textField.snp.makeConstraints { make in
            make.left.equalTo(limitTitle.snp_right).offset(5)
            make.centerY.equalTo(selectButton)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }

        unitTip.snp.makeConstraints { make in
            make.left.equalTo(textField.snp_right).offset(5)
            make.centerY.equalTo(textField)
            make.height.equalTo(30)
            make.width.equalTo(35)
        }

        clearButton.snp.makeConstraints { make in
            make.left.equalTo(unitTip.snp_right).offset(30)
            make.top.equalTo(selectButton)
            make.size.equalTo(selectButton)
            make.right.lessThanOrEqualTo(view.snp_right).offset(-sideMargin)
        }

        introduceLabel.sizeToFit()
        introduceLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(selectButton.snp_bottom).offset(10)
        }

        tableViewContainer.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel.snp_bottom).offset(20)
            make.left.right.equalTo(view)
            make.height.greaterThanOrEqualTo(500)
            make.bottom.equalTo(deleteButton.snp_top).offset(-10)
        }

        deleteButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(400)
            make.height.equalTo(30)
            make.bottom.equalTo(view).offset(-10)
        }

        dragDropView.snp.makeConstraints { make in
            make.centerX.equalTo(tableViewContainer)
            make.centerY.equalTo(tableViewContainer).offset(30)
            make.size.equalTo(NSSize(width: 400, height: 400))
        }
    }
}
