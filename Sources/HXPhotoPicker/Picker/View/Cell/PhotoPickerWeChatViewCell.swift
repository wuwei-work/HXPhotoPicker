//
//  PhotoPickerWeChatViewCell.swift
//  HXPhotoPicker
//
//  Created by Slience on 2021/10/25.
//

import UIKit

open class PhotoPickerWeChatViewCell: PhotoPickerSelectableViewCell {
    
    public var titleLb: UILabel!
    
    open override func initView() {
        super.initView()
        titleLb = UILabel()
        titleLb.hxpicker_alignment = .center
        titleLb.textColor = .white
        titleLb.font = .semiboldPingFang(ofSize: 15)
        titleLb.isHidden = true
        contentView.insertSubview(titleLb, belowSubview: selectControl)
    }
    
    open override func updateSelectedState(isSelected: Bool, animated: Bool) {
        super.updateSelectedState(isSelected: isSelected, animated: animated)
        // Given: 即近项目不保留微信风格左侧序号标签
        // When: 选中态发生变化
        // Then: 始终隐藏 titleLb 并清空布局痕迹
        titleLb.isHidden = true
        titleLb.text = nil
        titleLb.frame = .zero
    }
    
    open override func layoutView() {
        super.layoutView()
        // Given: 上游 layout 过程中可能重新布置 titleLb
        // When: cell 重新布局
        // Then: 再次收起 titleLb，避免序号标签回流显示
        titleLb.isHidden = true
        titleLb.frame = .zero
    }
}
