//
//  SelectBoxView.swift
//  HXPhotoPicker
//
//  Created by Slience on 2020/12/29.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

public final class SelectBoxView: UIControl {
    
    public enum Style: Int {
        /// 数字
        case number
        /// 勾勾
        case tick
    }
    
    public var text: String = "0" {
        didSet {
            textLayer.string = text
            updateTextLayerFrame()
        }
    }
    public override var isSelected: Bool {
        didSet {
            if !isSelected {
                text = "0"
            }
            updateLayers()
        }
    }
    public override var isHighlighted: Bool {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            updateLayers()
            CATransaction.commit()
        }
    }
    
    var textSize: CGSize = CGSize.zero {
        didSet {
            guard oldValue != self.textSize else {
                return
            }
            updateTextLayerFrame()
        }
    }
    
    private var backgroundLayer: CAShapeLayer!
    private var textLayer: CATextLayer!
    private var tickLayer: CAShapeLayer!
    // Given: 即近项目需要和 Android 保持一致的勾选框资源表现
    // When: 选择框处于 tick 业务样式时
    // Then: 使用 bundle 里的自定义图片渲染，而不是上游默认的图层绘制
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    public var config: SelectBoxConfiguration
    public init(_ config: SelectBoxConfiguration, frame: CGRect = .zero) {
        self.config = config
        super.init(frame: frame)
        initViews()
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(textLayer)
        layer.addSublayer(tickLayer)
        addSubview(imageView)
    }
    
    private func initViews() {
        backgroundLayer = CAShapeLayer()
        backgroundLayer.contentsScale = UIScreen._scale
        
        textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen._scale
        textLayer.alignmentMode = .center
        textLayer.isWrapped = true
        
        tickLayer = CAShapeLayer()
        tickLayer.lineJoin = .round
        tickLayer.contentsScale = UIScreen._scale
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateBackgroundLayerFrame()
        updateTickLayerFrame()
        updateTextLayerFrame()
        updateImageViewFrame()
    }
    
    private func backgroundPath() -> CGPath {
        let rect: CGRect
        if #available(iOS 26.0, *), !PhotoManager.isIos26Compatibility {
            rect = CGRect(
                x: 1,
                y: 1,
                width: config.size.width - 2,
                height: config.size.height - 2
            )
        }else {
            rect = CGRect(
                x: 0,
                y: 0,
                width: config.size.width,
                height: config.size.height
            )
        }
        let strokePath: UIBezierPath = .init(
            roundedRect: rect,
            cornerRadius: rect.height / 2
        )
        return strokePath.cgPath
    }
    private func drawBackgroundLayer() {
        // Given: 即近项目已经接管选中框视觉资源
        // When: 当前样式是 tick
        // Then: 隐藏上游默认背景层，避免和自定义图片叠加
        if config.style == .tick {
            backgroundLayer.isHidden = true
            return
        }
        backgroundLayer.isHidden = false
        backgroundLayer.path = backgroundPath()
        if isSelected {
            let selectedBackgroundColor = config.selectedBackgroundColor
            let selectedBackgroudDarkColor = config.selectedBackgroudDarkColor
            if isHighlighted {
                backgroundLayer.fillColor = PhotoManager.isDark ?
                selectedBackgroudDarkColor.withAlphaComponent(0.4).cgColor :
                selectedBackgroundColor.withAlphaComponent(0.4).cgColor
            }else {
                backgroundLayer.fillColor = PhotoManager.isDark ?
                selectedBackgroudDarkColor.cgColor :
                selectedBackgroundColor.cgColor
            }
            backgroundLayer.lineWidth = 0
        }else {
            backgroundLayer.lineWidth = config.borderWidth
            let backgroundColor = config.backgroundColor
            let darkBackgroundColor = config.darkBackgroundColor
            let borderColor = config.borderColor
            let borderDarkColor = config.borderDarkColor
            if isHighlighted {
                backgroundLayer.fillColor = PhotoManager.isDark ?
                darkBackgroundColor.withAlphaComponent(0.4).cgColor :
                backgroundColor.withAlphaComponent(0.4).cgColor
                backgroundLayer.strokeColor = PhotoManager.isDark ?
                borderDarkColor.withAlphaComponent(0.4).cgColor :
                borderColor.withAlphaComponent(0.4).cgColor
            }else {
                backgroundLayer.fillColor = PhotoManager.isDark ? darkBackgroundColor.cgColor : backgroundColor.cgColor
                backgroundLayer.strokeColor = PhotoManager.isDark ? borderDarkColor.cgColor : borderColor.cgColor
            }
        }
    }
    private func drawTextLayer() {
        // Given: 即近项目不再展示数字序号文本
        // When: 选择框刷新文本层
        // Then: 始终隐藏文本层
        textLayer.isHidden = true
        return
    }
    
    private func tickPath() -> CGPath {
        let tickPath: UIBezierPath = .init()
        tickPath.move(to: CGPoint(x: scale(8), y: config.size.height * 0.5 + scale(1)))
        tickPath.addLine(to: CGPoint(x: config.size.width * 0.5 - scale(2), y: config.size.height - scale(8)))
        tickPath.addLine(to: CGPoint(x: config.size.width - scale(7), y: scale(9)))
        return tickPath.cgPath
    }
    private func drawTickLayer() {
        if config.style != .tick {
            tickLayer.isHidden = true
            return
        }
        // Given: 即近项目使用图片资源表达选中状态
        // When: 上游 tick 样式仍然触发 tickLayer 绘制流程
        // Then: 保持 tickLayer 隐藏，避免和图片样式重复
        tickLayer.isHidden = true
        tickLayer.path = tickPath()
        tickLayer.lineWidth = config.tickWidth
        let color = PhotoManager.isDark ? config.tickDarkColor : config.tickColor
        tickLayer.strokeColor = isHighlighted ? color.withAlphaComponent(0.4).cgColor : color.cgColor
        tickLayer.fillColor = UIColor.clear.cgColor
    }
    
    public func updateLayers() {
        updateBackgroundLayerFrame()
        updateTickLayerFrame()
        updateTextLayerFrame()
        updateImageViewFrame()
        
        drawBackgroundLayer()
        drawTextLayer()
        drawTickLayer()
        drawImageView()
    }
    
    private func updateBackgroundLayerFrame() {
        backgroundLayer.frame = CGRect(
            x: (width - config.size.width) / 2,
            y: (height - config.size.height) / 2,
            width: config.size.width,
            height: config.size.height
        )
    }
    
    private func updateTickLayerFrame() {
        guard config.style == .tick else {
            return
        }
        tickLayer.frame = CGRect(
            x: (width - config.size.width) / 2,
            y: (height - config.size.height) / 2,
            width: config.size.width,
            height: config.size.height
        )
    }
    
    private func updateTextLayerFrame() {
        let font: UIFont = .mediumPingFang(ofSize: config.titleFontSize)
        var textHeight: CGFloat
        var textWidth: CGFloat
        if textSize.equalTo(CGSize.zero) {
            textHeight = text.height(ofFont: font, maxWidth: CGFloat(MAXFLOAT))
            textWidth = text.width(ofFont: font, maxHeight: textHeight)
        }else {
            textHeight = textSize.height
            textWidth = textSize.width
        }
        textLayer.frame = CGRect(
            x: (width - textWidth) * 0.5,
            y: (height - textHeight) * 0.5,
            width: textWidth,
            height: textHeight
        )
    }

    private func drawImageView() {
        if config.style != .tick {
            imageView.isHidden = true
            imageView.image = nil
            return
        }
        // Given: 即近项目统一使用 tick 勾选图
        // When: 根据选中态刷新选择框视觉
        // Then: 在 normal / selected 两张资源之间切换
        imageView.isHidden = false
        imageView.alpha = isHighlighted ? 0.4 : 1
        imageView.image = isSelected ? UIImage.image(for: "hx_picker_select_box_selected") : UIImage.image(for: "hx_picker_select_box_normal")
    }

    private func updateImageViewFrame() {
        imageView.frame = CGRect(
            x: (width - config.size.width) / 2,
            y: (height - config.size.height) / 2,
            width: config.size.width,
            height: config.size.height
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func scale(_ numerator: CGFloat) -> CGFloat {
        return numerator / 30 * height
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isUserInteractionEnabled && CGRect(x: -15, y: -15, width: width + 30, height: height + 30).contains(point) {
            return self
        }
        return super.hitTest(point, with: event)
    }
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                drawBackgroundLayer()
                drawTextLayer()
                drawTickLayer()
                drawImageView()
            }
        }
    }
}
