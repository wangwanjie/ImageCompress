//
//  WJDragDropView.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Cocoa

public final class WJDragDropView: NSView {
    // 鼠标进入区域是否高亮显示
    fileprivate var highlight: Bool = false

    // 文件类型是否允许
    fileprivate var fileTypeIsOk = false

    /// 可接受的文件类型，如: ["png", "jpg", "jpeg"]，为空将接受所有类型
    public var acceptedFileExtensions: [String] = []

    public weak var delegate: WJDragDropViewDelegate?

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        registerForDraggedTypes()
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        registerForDraggedTypes()
    }

    func registerForDraggedTypes() {
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        } else {
            // Fallback on earlier versions
            registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
        }
    }

    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        if NSAppKitVersion.current.rawValue < NSAppKitVersion.macOS10_10.rawValue {
            NSColor.windowBackgroundColor.setFill()
        } else {
            NSColor.clear.set()
        }

        let normalWidth: CGFloat = 300.0

        var rect: NSRect = dirtyRect
        if dirtyRect.size.width > normalWidth, dirtyRect.size.height > normalWidth {
            rect = NSRect(x: (dirtyRect.size.width - normalWidth) * 0.5, y: (dirtyRect.size.height - normalWidth) * 0.5, width: normalWidth, height: normalWidth)
        }

        __NSRectFillUsingOperation(rect, NSCompositingOperation.sourceOver)

        let grayColor = NSColor(deviceWhite: 0, alpha: highlight ? 1.0 / 4.0 : 1.0 / 8.0)
        grayColor.set()
        grayColor.setFill()

        let bounds = (dirtyRect.size.width > normalWidth && dirtyRect.size.height > normalWidth) ? rect : self.bounds
        let size = min(bounds.size.width - 8.0, bounds.size.height - 8.0)
        let width = max(2.0, size / 32.0)
        let frame = NSMakeRect((bounds.size.width - size) / 2.0 + bounds.origin.x, (bounds.size.height - size) / 2.0 + bounds.origin.y, size, size)

        NSBezierPath.defaultLineWidth = width

        // 圆角和虚线
        let squarePath = NSBezierPath(roundedRect: frame, xRadius: size / 14.0, yRadius: size / 14.0)
        let dash: [CGFloat] = [size / 10.0, size / 16.0]
        squarePath.setLineDash(dash, count: 2, phase: 2)
        squarePath.stroke()

        // 箭头
        let arrowPath = NSBezierPath()
        let baseWidth = size / 8.0
        let baseHeight = size / 8.0
        let arrowWidth = baseWidth * 2.0
        let pointHeight = baseHeight * 3.0
        let offset = -size / 8.0 - bounds.origin.y

        arrowPath.move(to: NSMakePoint(bounds.size.width / 2.0 - baseWidth + bounds.origin.x, bounds.size.height / 2.0 + baseHeight - offset))

        arrowPath.line(to: NSMakePoint(bounds.size.width / 2.0 + baseWidth + bounds.origin.x, bounds.size.height / 2.0 + baseHeight - offset))
        arrowPath.line(to: NSMakePoint(bounds.size.width / 2.0 + baseWidth + bounds.origin.x, bounds.size.height / 2.0 - baseHeight - offset))
        arrowPath.line(to: NSMakePoint(bounds.size.width / 2.0 + arrowWidth + bounds.origin.x, bounds.size.height / 2.0 - baseHeight - offset))
        arrowPath.line(to: NSMakePoint(bounds.size.width / 2.0 + bounds.origin.x, bounds.size.height / 2.0 - pointHeight - offset))
        arrowPath.line(to: NSMakePoint(bounds.size.width / 2.0 - arrowWidth + bounds.origin.x, bounds.size.height / 2.0 - baseHeight - offset))
        arrowPath.line(to: NSMakePoint(bounds.size.width / 2.0 - baseWidth + bounds.origin.x, bounds.size.height / 2.0 - baseHeight - offset))

        arrowPath.fill()
    }

    // MARK: - NSDraggingDestination

    override public func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        highlight = true
        fileTypeIsOk = isExtensionAcceptable(draggingInfo: sender)

        setNeedsDisplay(bounds)
        return []
    }

    override public func draggingExited(_: NSDraggingInfo?) {
        highlight = false
        setNeedsDisplay(bounds)
    }

    override public func draggingUpdated(_: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }

    override public func prepareForDragOperation(_: NSDraggingInfo) -> Bool {
        // finished with dragging so remove any highlighting
        highlight = false
        setNeedsDisplay(bounds)

        return true
    }

    override public func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.filePathURLs.count == 0 {
            return false
        }

        if fileTypeIsOk {
            if sender.filePathURLs.count == 1 {
                delegate?.dragDropView(self, droppedFileWithURL: sender.filePathURLs.first!)
            } else {
                delegate?.dragDropView(self, droppedFilesWithURLs: sender.filePathURLs)
            }
        } else {}

        return true
    }

    fileprivate func isExtensionAcceptable(draggingInfo: NSDraggingInfo) -> Bool {
        if draggingInfo.filePathURLs.count == 0 {
            return false
        }

        if acceptedFileExtensions.count <= 0 {
            return true
        }

        var totalPath = [URL]()
        for filePathURL in draggingInfo.filePathURLs {
            let isDir = HDFileUtil.isDirFilePath(filePathURL.path)
            if isDir {
                let filePathList = HDFileUtil.getFileListRecursively(filePathURL.path)
                let fileList = filePathList.map { (str) -> URL in
                    URL(string: (str as NSString).hd_URLEncoded())!
                }

                for case let url in fileList as [URL?] {
                    if let url = url {
                        totalPath.append(url)
                    }
                }
            } else {
                totalPath.append(filePathURL)
            }
        }

        guard totalPath.count > 0 else {
            return false
        }

        for filePathURL in totalPath {
            let fileExtension = filePathURL.pathExtension.lowercased()
            // 只要有一个支持的文件就接受
            if acceptedFileExtensions.contains(fileExtension) {
                return true
            }
        }
        return false
    }

    override public func acceptsFirstMouse(for _: NSEvent?) -> Bool {
        return true
    }
}

public protocol WJDragDropViewDelegate: AnyObject {
    func dragDropView(_ dragDropView: WJDragDropView, droppedFileWithURL URL: URL)
    func dragDropView(_ dragDropView: WJDragDropView, droppedFilesWithURLs URLs: [URL])
}

extension WJDragDropViewDelegate {
    func dragDropView(_: WJDragDropView, droppedFileWithURL _: URL) {}

    func dragDropView(_: WJDragDropView, droppedFilesWithURLs _: [URL]) {}
}
