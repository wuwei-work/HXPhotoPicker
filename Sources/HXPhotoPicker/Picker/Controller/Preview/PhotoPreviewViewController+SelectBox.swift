//
//  PhotoPreviewViewController+SelectBox.swift
//  HXPhotoPicker
//
//  Created by Slience on 2021/8/27.
//

import UIKit

extension PhotoPreviewViewController {
    @objc func didSelectBoxControlClick() {
        guard let photoAsset = photoAsset(for: currentPreviewIndex) else {
            return
        }
        let isSelected = !selectBoxControl.isSelected
        var canUpdate = false
        var bottomNeedAnimated = false
        var pickerUpdateCell = false
        let beforeIsEmpty = pickerController.selectedAssetArray.isEmpty
        if isSelected {
            // 选中
            #if HXPICKER_ENABLE_EDITOR
            if photoAsset.mediaType == .video &&
                pickerController.pickerData.videoDurationExceedsTheLimit(photoAsset) &&
                pickerConfig.editorOptions.isVideo {
                if pickerController.pickerData.canSelect(photoAsset, isShowHUD: true) {
                    openEditor(photoAsset)
                }
                return
            }
            #endif
            func addAsset() {
                if pickerController.pickerData.append(photoAsset) {
                    canUpdate = true
                    if isShowToolbar {
                        photoToolbar.insertSelectedAsset(photoAsset)
                        photoToolbar.previewListReload([photoAsset])
                    }
                    if beforeIsEmpty {
                        bottomNeedAnimated = true
                    }
                }
            }
            let inICloud = photoAsset.checkICloundStatus(
                allowSyncPhoto: pickerConfig.allowSyncICloudWhenSelectPhoto
            ) { _, isSuccess in
                if isSuccess {
                    addAsset()
                    if canUpdate {
                        self.updateSelectBox(
                            photoAsset: photoAsset,
                            isSelected: isSelected,
                            pickerUpdateCell: pickerUpdateCell,
                            bottomNeedAnimated: bottomNeedAnimated)
                    }
                }
            }
            if !inICloud {
                addAsset()
            }
        }else {
            // 取消选中
            pickerController.pickerData.remove(photoAsset)
            if !beforeIsEmpty && pickerController.selectedAssetArray.isEmpty {
                bottomNeedAnimated = true
            }
            if isShowToolbar {
                photoToolbar.removeSelectedAssets([photoAsset])
                photoToolbar.previewListReload([photoAsset])
            }
            #if HXPICKER_ENABLE_EDITOR
            if photoAsset.videoEditedResult != nil, pickerConfig.isDeselectVideoRemoveEdited {
                photoAsset.editedResult = nil
                let cell = getCell(for: currentPreviewIndex)
                cell?.photoAsset = photoAsset
                cell?.cancelRequest()
                cell?.requestPreviewAsset()
                pickerUpdateCell = true
            }else  if photoAsset.photoEditedResult != nil, pickerConfig.isDeselectPhotoRemoveEdited {
                photoAsset.editedResult = nil
                let cell = getCell(for: currentPreviewIndex)
                cell?.photoAsset = photoAsset
                cell?.cancelRequest()
                cell?.requestPreviewAsset()
                pickerUpdateCell = true
            }
            #endif
            canUpdate = true
        }
        if canUpdate {
            updateSelectBox(
                photoAsset: photoAsset,
                isSelected: isSelected,
                pickerUpdateCell: pickerUpdateCell,
                bottomNeedAnimated: bottomNeedAnimated
            )
        }
    }
    
    func updateSelectBox(
        photoAsset: PhotoAsset,
        isSelected: Bool,
        pickerUpdateCell: Bool,
        bottomNeedAnimated: Bool
    ) {
        if isShowToolbar {
            if bottomNeedAnimated {
                UIView.animate(withDuration: 0.25) {
                    self.configBottomViewFrame()
                    self.photoToolbar.layoutSubviews()
                }
            }else {
                configBottomViewFrame()
            }
        }
        updateSelectBox(
            isSelected,
            photoAsset: photoAsset
        )
        selectBoxControl.isSelected = isSelected
        delegate?.previewViewController(
            self,
            didSelectBox: photoAsset,
            isSelected: isSelected,
            updateCell: pickerUpdateCell
        )
        if isShowToolbar {
            photoToolbar.requestOriginalAssetBtyes()
            photoToolbar.selectedAssetDidChanged(pickerController.selectedAssetArray)
        }
        selectBoxControl.layer.removeAnimation(
            forKey: "SelectControlAnimation"
        )
        let keyAnimation = CAKeyframeAnimation(
            keyPath: "transform.scale"
        )
        keyAnimation.duration = 0.3
        keyAnimation.values = [1.2, 0.8, 1.1, 0.9, 1.0]
        selectBoxControl.layer.add(
            keyAnimation,
            forKey: "SelectControlAnimation"
        )
    }
    
    func updateSelectBox(_ isSelected: Bool, photoAsset: PhotoAsset) {
        let boxWidth = config.selectBox.size.width
        let boxHeight = config.selectBox.size.height
        if isSelected {
            // Given: 即近项目预览页的勾选框不再承载选中序号
            // When: 资源进入选中状态
            // Then: 清空文本并保持固定勾选框尺寸
            selectBoxControl.text = ""
            selectBoxControl.textSize = .zero
            selectBoxControl.size = CGSize(
                width: boxWidth,
                height: boxHeight
            )
        }else {
            // Given: 未选中态也复用同一套图片化勾选框资源
            // When: 资源取消选中
            // Then: 同样清空文本并恢复固定尺寸，避免序号宽度残留
            selectBoxControl.text = ""
            selectBoxControl.textSize = .zero
            selectBoxControl.size = CGSize(
                width: boxWidth,
                height: boxHeight
            )
        }
    }
}
