//
//  PhotoPreviewSelectedViewCell.swift
//  HXPhotoPicker
//
//  Created by Slience on 2020/12/29.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import Photos

public protocol PhotoPreviewSelectedViewCellDelegate: AnyObject {
    func selectedViewCell(didDelete cell: PhotoPreviewSelectedViewCell)
}

open class PhotoPreviewSelectedViewCell: UICollectionViewCell {
    public weak var delegate: PhotoPreviewSelectedViewCellDelegate?
    public var deleteBtn: UIButton!
    public var photoView: PhotoThumbnailView!
    public var selectedView: UIView!
    public var isPhotoList: Bool = false {
        didSet {
            if isPhotoList {
                selectedView.isHidden = true
                tickView.isHidden = true
                deleteBtn.isHidden = false
            }else {
                deleteBtn.isHidden = true
            }
        }
    }
    var tickView: TickView!
    
    open var tickColor: UIColor? {
        didSet {
            if !isPhotoList {
                // Given: 即近项目预览选中态只保留绿色描边
                // When: 上游尝试根据 tickColor 展示中心勾号
                // Then: 持续隐藏 tickView，只保留加载指示器颜色同步
                tickView.isHidden = true
            }
            photoView.kf_indicatorColor = tickColor
        }
    }
    
    
    open var photoAsset: PhotoAsset! {
        didSet {
            photoView.photoAsset = photoAsset
            reqeustAssetImage()
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isPhotoList {
                return
            }
            selectedView.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        photoView = PhotoThumbnailView()
        photoView.imageView.size = size
        contentView.addSubview(photoView)
        
        deleteBtn = UIButton(type: .custom)
        deleteBtn.setImage(.imageResource.picker.photoList.bottomView.delete.image, for: .normal)
        deleteBtn.addTarget(self, action: #selector(didDeleteButtonClick), for: .touchUpInside)
        contentView.addSubview(deleteBtn)
        
        selectedView = UIView()
        selectedView.isHidden = true
        // Given: 即近项目预览底部缩略图高亮改成透明蒙层 + 绿色描边
        // When: 选中态视图初始化
        // Then: 不再使用上游黑色半透明遮罩
        selectedView.backgroundColor = .clear
        selectedView.layer.borderWidth = 2
        selectedView.layer.borderColor = UIColor(
            red: 201.0 / 255.0,
            green: 243.0 / 255.0,
            blue: 0,
            alpha: 1
        ).cgColor
        contentView.addSubview(selectedView)
        
        tickView = TickView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        // Given: 即近项目不在预览缩略图中展示勾号
        // When: 选中态附带 tickView 被创建
        // Then: 立即隐藏 tickView
        tickView.isHidden = true
        selectedView.addSubview(tickView)
    }
    
    @objc
    func didDeleteButtonClick() {
        delegate?.selectedViewCell(didDelete: self)
    }
    
    /// 获取图片，重写此方法可以修改图片
    open func reqeustAssetImage() {
        photoView.requestThumbnailImage(targetWidth: width * 2)
    }
    
    public func cancelRequest() {
        photoView.cancelRequest()
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        photoView.frame = bounds
        selectedView.frame = bounds
        tickView.center = CGPoint(x: width * 0.5, y: height * 0.5)
         
        deleteBtn.size = .init(width: 18, height: 18)
        deleteBtn.y = 0
        deleteBtn.x = width - deleteBtn.width
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
