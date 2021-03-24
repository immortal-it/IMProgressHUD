//
//  IMProgressHUD.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/3/16.
//

import UIKit

public class IMProgressHUD: UIView {
    
    /// 活动指示器类型枚举
    public typealias ActivityIndicatorType = IMBaseActivityIndicator.IndicatorType
     
    /// 进度指示器类型枚举
    public typealias ProgressIndicatorType = IMProgressIndicator.IndicatorType
    
    /// 状态类型枚举
    public typealias State = IMStateAnimation.State

    /// 位置枚举
    public enum Location {
        case top(offset: CGFloat)
        case center(offset: CGFloat)
        case bottom(offset: CGFloat)
        
        public static let top = Self.top(offset: 0.0)
        public static let center = Self.center(offset: 0.0)
        public static let bottom = Self.bottom(offset: 0.0)
        public static let `default` = Self.center(offset: 0.0)
    }

    /// 样式配置
    public struct Configuration {
        
        /// 圆角大小，默认 `14.0`
        public var cornerRadius: CGFloat = 14.0
        
        /// 内容边距，默认 `UIEdgeInsets(top: 18.0, left: 24.0, bottom: 18.0, right: 24.0)`
        public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 18.0, left: 24.0, bottom: 18.0, right: 24.0)
        
        /// 文本和图标间距，默认 `12.0`
        public var spacing: CGFloat = 12.0

        /// 颜色，默认 `#484B55`
        public var color: UIColor = #colorLiteral(red: 0.2823529412, green: 0.2941176471, blue: 0.3333333333, alpha: 1)
        
        /// 指示器颜色，默认 `UIColor.lightGray`
        public var indicatorColor: UIColor = UIColor.lightGray
        
        /// 暗度颜色，默认 `UIColor.clear`
        public var dimmingColor: UIColor = .clear
        
        /// fade动画时间，默认 `0.15s`
        public var fadeDuration: TimeInterval = 0.15
        
        /// 最小大小，默认`CGSize.zero`
        public var minimumSize: CGSize = .zero
      
        /// 最大宽度比例，默认`0.8`
        public var maxWidthPercentage: CGFloat = 0.8 {
            didSet { maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0) }
        }
        
        /// 最大高度比例，默认`0.8`
        public var maxHeightPercentage: CGFloat = 0.8 {
            didSet { maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0) }
        }
        
        /// 文本颜色，默认 `UIColor.white`
        public var messageColor: UIColor = .white
        
        /// 文本字体，默认 `UIFont.systemFont(ofSize: 16.0, weight: .medium)`
        public var messageFont: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        
        /// 文本行数，默认 `0`
        public var numberOfMessageLines: Int = 0
        
        /// 指示器大小，默认 `CGSize(width: 35.0, height: 35.0)`
        public var indicatorSize: CGSize = CGSize(width: 35.0, height: 35.0)
        
        /// 延时隐藏时间，默认 `1.5s`
        public var delayTime: TimeInterval = 1.5
        
        /// 用户是否可以交互处理，默认 `true`
        public var isUserInteractionEnabled: Bool = true
    }

    // MARK: - 配置
    
    /// 全局配置
    public static var configuration: Configuration = Configuration()
    
    private static let shared = IMProgressHUD()
    
    // MARK: - 属性
    
    private lazy var dimmingView: UIView = makeDimmingView()
    
    private lazy var controlView: UIControl = makeControlView()
    
    private lazy var contentView: UIStackView = makeContentView()
    
    private lazy var indicatorView: UIView = makeIndicatorView()
    
    private lazy var iconView: UIImageView = makeIconView()

    private lazy var messageLabel: UILabel = makeMessageLabel()

    private var internalConstraints: [NSLayoutConstraint] = []

    private var indicatorInternalConstraints: [NSLayoutConstraint] = []

    public var configuration: Configuration = IMProgressHUD.configuration {
        didSet {
            configure()
        }
    }
    
    public var location: Location = .default {
        didSet {
            updateLocationLayout()
        }
    }

    public init() {
        super.init(frame: UIScreen.main.bounds)
        initView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
 
    private func initView() {
        alpha = 0.0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        accessibilityIdentifier = "IMProgressHUD"
        isAccessibilityElement = true
        loadSubviews()
        configure()
    }
    
    /// 加载子视图控件
    private func loadSubviews() {
        addSubview(dimmingView)
        addSubview(controlView)
        controlView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: controlView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: controlView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: controlView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: controlView.bottomAnchor)
        ])
        updateLocationLayout()
        contentView.addArrangedSubview(indicatorView)
        contentView.addArrangedSubview(iconView)
        contentView.addArrangedSubview(messageLabel)
    }
    
    /// 更新位置布局
    private func updateLocationLayout() {
        removeConstraints(internalConstraints)
        internalConstraints = [
            controlView.widthAnchor.constraint(greaterThanOrEqualToConstant: configuration.minimumSize.width),
            controlView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: configuration.maxWidthPercentage),
            controlView.heightAnchor.constraint(greaterThanOrEqualToConstant: configuration.minimumSize.height),
            controlView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: configuration.maxHeightPercentage),
            controlView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]
        switch location {
            case .top(offset: let offset):
                internalConstraints.append(controlView.topAnchor.constraint(equalTo: topAnchor, constant: offset))
            case .center(offset: let offset):
                internalConstraints.append(controlView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset))
            case .bottom(offset: let offset):
                internalConstraints.append(controlView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset))
        }
        NSLayoutConstraint.activate(internalConstraints)
        layoutIfNeeded()
    }
    
    /// 应用样式
    private func configure() {
        isUserInteractionEnabled = !configuration.isUserInteractionEnabled
        dimmingView.backgroundColor = configuration.dimmingColor
        
        controlView.backgroundColor = configuration.color
        controlView.layer.cornerRadius = configuration.cornerRadius
        contentView.layoutMargins = configuration.contentInsets
        contentView.spacing = configuration.spacing
        
        messageLabel.font = configuration.messageFont
        messageLabel.textColor = configuration.messageColor
        messageLabel.numberOfLines = configuration.numberOfMessageLines

        indicatorView.removeConstraints(indicatorInternalConstraints)
        indicatorInternalConstraints = [
            indicatorView.widthAnchor.constraint(equalToConstant: configuration.indicatorSize.width),
            indicatorView.heightAnchor.constraint(equalToConstant: configuration.indicatorSize.width)
        ]
        NSLayoutConstraint.activate(indicatorInternalConstraints)
        indicatorView.layoutIfNeeded()
    }
    
    /// 图片
    public var icon: UIImage? {
        didSet {
            if icon != nil {
                activityIndicator = nil
            }
            iconView.image = icon
            iconView.isHidden = icon == nil
            updateDelayHiding()
        }
    }
    
    /// 文案
    public var message: String? {
        didSet {
            messageLabel.text = message
            messageLabel.isHidden = message == nil
            updateDelayHiding()
        }
    }
    
    /// 活动指示器
    public var activityIndicator: IMActivityIndicating? {
        didSet {
            indicatorView.isHidden = activityIndicator == nil
            oldValue?.remove()
            if let activityIndicator = activityIndicator {
                icon = nil
                UIView.performWithoutAnimation {
                    activityIndicator.apply(in: self.indicatorView)
                }
            }
            updateDelayHiding()
        }
    }
    
    /// 进度值
    public var progress: CGFloat = .zero {
        didSet {
            guard let progressIndicator = activityIndicator as? IMProgressIndicating else {
                return
            }
            progressIndicator.progress = progress
        }
    }
    
    /// 设置活动指示器
    public func setActivity(_ indicatorType: ActivityIndicatorType) {
        let activityIndicator = indicatorType.getIndicator()
        if let oldValue = self.activityIndicator,
           let newValue = activityIndicator,
           type(of: oldValue.self) == type(of: newValue.self) {
            return
        }
        self.activityIndicator = activityIndicator
    }
    
    /// 设置HUD状态
    public func setState(_ state: State) {
        if let oldValue = activityIndicator as? IMStateAnimation, oldValue.state == state {
            return
        }
        activityIndicator = IMStateAnimation(state: state)
    }
    
    /// 设置进度和进度指示器
    public func setProgress(_ progress: CGFloat, indicatorType: ProgressIndicatorType = .default) {
        defer {
            self.progress = progress
        }
        let progressIndicator = indicatorType.getIndicator()
        if let oldValue = self.activityIndicator,
           let newValue = progressIndicator,
           type(of: oldValue.self) == type(of: newValue.self) {
            return
        }
        self.activityIndicator = progressIndicator
    }
    
    /// 通过动画方式更新内容
    public func updateInAnimation(_ handler: @escaping (IMProgressHUD) -> Void) {
        let lasIconViewIsHidden: Bool = iconView.isHidden
        let lastMessageLabelIsHidden: Bool = messageLabel.isHidden
        let lastIndicatorViewIsHidden: Bool = indicatorView.isHidden
        handler(self)
        if !iconView.isHidden && lasIconViewIsHidden {
            iconView.alpha = 0.0
        }
        if !messageLabel.isHidden && lastMessageLabelIsHidden {
            messageLabel.alpha = 0.0
        }
        if !indicatorView.isHidden && lastIndicatorViewIsHidden {
            indicatorView.alpha = 0.0
        }
        UIView.animate(withDuration: configuration.fadeDuration, animations: {
            self.iconView.alpha = 1.0
            self.messageLabel.alpha = 1.0
            self.indicatorView.alpha = 1.0
        })
    }

    /// 获取指定容器视图上显示的HUD
    /// - parameter containerView: ProgressHUD 显示的容器视图
    /// - returns : IMProgressHUD对象
    @discardableResult
    public static func hud(from containerView: UIView) -> IMProgressHUD? {
        containerView.subviews.first(where: { $0 is IMProgressHUD }) as? IMProgressHUD
    }
   
    // MARK: - Dismiss

    private var willHiding: Bool = false
    
    /// 更新延时隐藏处理
    private func updateDelayHiding() {
        if activityIndicator != nil && !(activityIndicator is IMStateAnimation) {
            cancelDelayDismissRequest()
        } else {
            dismissAfter(delay: configuration.delayTime)
        }
    }
    
    /// 隐藏HUD
    @objc public func dismiss() {
        cancelDelayDismissRequest()
        UIView.animate(withDuration: configuration.fadeDuration,
                       delay: 0.0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
                            self.alpha = 0.0
                       }, completion: { _ in
                            self.removeFromSuperview()
                       })
    }
    
    /// 延时隐藏HUD
    /// - parameter duration: 延时时间
    public func dismissAfter(delay duration: TimeInterval) {
        cancelDelayDismissRequest()
        willHiding = true
        perform(#selector(dismiss), with: self, afterDelay: duration)
    }
    
    /// 取消延时隐藏HUD
    private func cancelDelayDismissRequest() {
        Self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismiss), object: self)
        willHiding = false
    }
    
    public static var isVisible: Bool {
        shared.superview != nil
    }
    
    /// 隐藏HUD
    public static func dismiss() {
        guard isVisible else {
            return
        }
        shared.dismiss()
    }
    
    // MARK: - Show
    
    /// 显示HUD
    /// - parameter containerView: ProgressHUD 显示的容器视图
    public func show(in containerView: UIView) {
        guard !containerView.subviews.contains(self) else {
            return
        }
        frame = containerView.frame
        containerView.addSubview(self)
        UIView.animate(withDuration: configuration.fadeDuration,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState],
                       animations: {
                            self.alpha = 1.0
                       })
    }
  
    /// 显示HUD
    /// - parameter containerView: ProgressHUD 显示的容器视图，默认`nil`, 自动使用 `KeyWindow`
    /// - parameter configuration: ProgressHUD 配置闭包
    public static func show(in containerView: UIView? = nil,
                            configuration: @escaping (IMProgressHUD) -> Void) {
        let hud = shared
        hud.configuration = Self.configuration
        configuration(hud)
        if let containerView = containerView {
            hud.show(in: containerView)
        } else if let keyWindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow }) ?? UIApplication.shared.windows.first {
            hud.show(in: keyWindow)
        }
    }
    
    /// 显示Toast
    /// - parameter message: 显示的文本内容
    /// - parameter location: 文本位置
    /// - returns : IMProgressHUD对象
    @discardableResult
    public static func showToast(message: String,
                                 location: Location) -> IMProgressHUD {
        let hud = IMProgressHUD()
        hud.location = location
        if let keyWindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow }) ?? UIApplication.shared.windows.first {
            hud.show(in: keyWindow)
        }
        return hud
    }
    
    /// 显示Toast
    /// - parameter message: 显示的文本内容
    public static func showToast(_ message: String) {
        show {
            $0.message = message
            $0.icon = nil
            $0.activityIndicator = nil
        }
    }
    
    /// 显示HUD
    /// - parameter message: 显示的文本内容，默认`nil`
    /// - parameter image: 显示的图标内容，默认`nil`
    public static func show(message: String? = nil,
                            image: UIImage? = nil) {
        show {
            $0.message = message
            $0.icon = image
        }
    }
    
    /// 显示成功HUD
    /// - parameter message: 显示的文本内容，默认`nil`
    public static func showSuccess(_ message: String? = nil) {
        show {
            $0.message = message
            $0.setState(.success)
        }
    }
    
    /// 显示失败HUD
    /// - parameter message: 显示的文本内容，默认`nil`
    public static func showFail(_ message: String? = nil) {
        show {
            $0.message = message
            $0.setState(.fail)
        }
    }
    
    /// 显示HUD
    /// - parameter activityIndicator: 显示的活动指示器
    /// - parameter message: 显示的文本内容，默认`nil`
    public static func showIndicator(_ activityIndicator: IMActivityIndicating,
                                     message: String? = nil) {
        show {
            $0.message = message
            if let oldValue = $0.activityIndicator,
               type(of: oldValue.self) == type(of: activityIndicator.self) {
                return
            }
            $0.activityIndicator = activityIndicator
        }
    }
    
    /// 显示HUD
    /// - parameter animationType: 活动指示器动画类型, 默认`AnimationType.default`
    /// - parameter message: 显示的文本内容，默认`nil`
    public static func showIndicator(_ animationType: ActivityIndicatorType = .default,
                                     message: String? = nil) {
        show {
            $0.message = message
            $0.setActivity(animationType)
        }
    }
    
    /// 显示HUD
    /// - parameter progress: 显示的进度值，范围`[0.0, 1.0]`
    /// - parameter indicatorType: 指示器类型, 默认`ProgressIndicatorType.default`
    /// - parameter message: 显示的文本内容，默认`nil`
    public static func showProgress(_ progress: CGFloat,
                                    indicatorType: ProgressIndicatorType = .default,
                                    message: String? = nil) {
        show {
            $0.message = message
            $0.setProgress(progress, indicatorType: indicatorType)
        }
    }
}

// MARK: - 控件创建私有方法
private extension IMProgressHUD {
    /// 创建控件
    func makeDimmingView() -> UIView {
        let dimmingView = UIView(frame: frame)
        dimmingView.isUserInteractionEnabled = true
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return dimmingView
    }
   
    func makeControlView() -> UIControl {
        let controlView = UIControl()
        controlView.isUserInteractionEnabled = true
        controlView.translatesAutoresizingMaskIntoConstraints = false
        return controlView
    }
    
    /// 创建控件
    func makeContentView() -> UIStackView {
        let contentView = UIStackView()
        contentView.isUserInteractionEnabled = true
        contentView.alignment = .center
        contentView.distribution = .equalCentering
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.axis = .vertical
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }
    
    /// 创建控件
    func makeIconView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    /// 创建控件
    func makeMessageLabel() -> UILabel {
        let label = UILabel()
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }
    
    /// 创建控件
    func makeIndicatorView() -> UIView {
        let indicatorView = UIView()
        indicatorView.isHidden = true
        indicatorView.isUserInteractionEnabled = true
        return indicatorView
    }
}
