//
//  IMProgressHUD.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/3/16.
//

import UIKit

/// Displays a simple HUD window containing a progress indicator and one optional label for short message.
public class IMProgressHUD: UIView {
    
    private let dimmingView = UIView()
    
    private let container = UIControl()
    
    
    private let indicatorView: UIView = createIndicatorView()
    
    private let iconView: UIImageView = createIconView()

    private let messageLabel: UILabel = createMessageLabel()

    private lazy var contentView: UIStackView = createContentView(indicatorView, iconView, messageLabel)
    
    
    private var internalConstraints: [NSLayoutConstraint] = []

    private var indicatorInternalConstraints: [NSLayoutConstraint] = []

    public var configuration: Configuration = IMProgressHUD.configuration {
        didSet {
            configure()
        }
    }
    
    public var location: Location = .default {
        didSet {
            updateContainerLayoutConstraints()
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
        accessibilityIdentifier = "com.immortal.IMProgressHUD"
        isAccessibilityElement = true
        setupSubviews()
        configure()
    }
    
    private func setupSubviews() {
        addSubviewLayoutEqualToEdges(dimmingView)
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        container.addSubviewLayoutEqualToEdges(contentView)
        updateContainerLayoutConstraints()
    }
    
    private func updateContainerLayoutConstraints() {
        removeConstraints(internalConstraints)
        internalConstraints = [
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: configuration.minimumSize.width).priority(.defaultLow),
            container.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: configuration.maxWidthPercentage).priority(.defaultHigh),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: configuration.minimumSize.height).priority(.defaultLow),
            container.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: configuration.maxHeightPercentage).priority(.defaultHigh),
            container.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]
        switch location {
            case .top(offset: let offset):
                internalConstraints.append(container.topAnchor.constraint(equalTo: compatibleSafeTopAnchor, constant: offset))
            case .center(offset: let offset):
                internalConstraints.append(container.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset))
            case .bottom(offset: let offset):
                internalConstraints.append(container.bottomAnchor.constraint(equalTo: compatibleSafeBottomAnchor, constant: -offset))
        }
        NSLayoutConstraint.activate(internalConstraints)
        if let superview = superview, superview.frame.width * superview.frame.height != .zero {
            layoutIfNeeded()
        }
    }
    
    private func configure() {
        isUserInteractionEnabled = !configuration.isUserInteractionEnabled
        dimmingView.backgroundColor = configuration.dimmingColor
        
        container.backgroundColor = configuration.color
        container.layer.cornerRadius = configuration.cornerRadius
        contentView.layoutMargins = configuration.contentInsets
        contentView.spacing = configuration.spacing
        
        messageLabel.font = configuration.messageFont
        messageLabel.textColor = configuration.messageColor
        messageLabel.numberOfLines = configuration.numberOfMessageLines

        indicatorView.removeConstraints(indicatorInternalConstraints)
        indicatorInternalConstraints = [
            indicatorView.widthAnchor.constraint(equalToConstant: configuration.indicatorSize.width),
            indicatorView.heightAnchor.constraint(equalToConstant: configuration.indicatorSize.height)
        ]
        NSLayoutConstraint.activate(indicatorInternalConstraints)
        indicatorView.setNeedsLayout()
    }
    
    
    
    // MARK: - 内容配置
    
    /// `HUD`提示图标
    public var icon: UIImage? {
        get {
            iconView.image
        }
        set {
            if iconView.image != nil {
                activityIndicator = nil
            }
            iconView.image = newValue
            iconView.isHidden = newValue == nil
            updateDelayHiding()
        }
    }
    
    /// `HUD`提示文字
    public var message: String? {
        get {
            messageLabel.text
        }
        set {
            messageLabel.text = newValue
            messageLabel.isHidden = newValue == nil
            updateDelayHiding()
        }
    }
    
    /// `HUD`加载活动指示器
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
    
    /// `HUD`加载进度值
    public var progress: CGFloat = .zero {
        didSet {
            guard let progressIndicator = activityIndicator as? IMProgressIndicating else {
                return
            }
            progressIndicator.progress = progress
        }
    }
    
    /// 设置`HUD`活动指示器
    public func setActivity(_ indicatorType: ActivityIndicatorType) {
        let activityIndicator = indicatorType.getIndicator()
        if let oldValue = self.activityIndicator,
           let newValue = activityIndicator,
           type(of: oldValue.self) == type(of: newValue.self) {
            return
        }
        self.activityIndicator = activityIndicator
    }
    
    /// 设置`HUD`显示状态
    public func setState(_ state: State) {
        if let oldValue = activityIndicator as? IMStateAnimation, oldValue.state == state {
            return
        }
        activityIndicator = IMStateAnimation(state: state)
    }
    
    /// 设置`HUD`进度和进度指示器
    public func setProgress(
        _ progressValue: CGFloat,
        indicatorType: ProgressIndicatorType = .default
    ) {
        defer {
            progress = progressValue
        }
        let progressIndicator = indicatorType.getIndicator()
        if let oldValue = activityIndicator,
           let newValue = progressIndicator,
           type(of: oldValue.self) == type(of: newValue.self) {
            return
        }
        activityIndicator = progressIndicator
    }
    
    /// 通过动画方式更新内容
    public func updateInAnimation(_ block: @escaping (IMProgressHUD) -> Void) {
        let lasIconViewIsHidden = iconView.isHidden
        let lastMessageLabelIsHidden = messageLabel.isHidden
        let lastIndicatorViewIsHidden = indicatorView.isHidden
        block(self)
        if !iconView.isHidden && lasIconViewIsHidden {
            iconView.alpha = 0.0
        }
        if !messageLabel.isHidden && lastMessageLabelIsHidden {
            messageLabel.alpha = 0.0
        }
        if !indicatorView.isHidden && lastIndicatorViewIsHidden {
            indicatorView.alpha = 0.0
        }
        UIView.animate(
            withDuration: configuration.fadeDuration,
            animations: {
                self.iconView.alpha = 1.0
                self.messageLabel.alpha = 1.0
                self.indicatorView.alpha = 1.0
            }
        )
    }

   
    
    
    // MARK: - Presentation

    /// 显示`HUD`
    /// - parameter containerView: ProgressHUD 显示的容器视图
    public func show(in containerView: UIView) {
        guard !containerView.subviews.contains(self) else {
            return
        }
        alpha = 0.0
        containerView.addSubviewLayoutEqualToEdges(self)
        UIView.animate(
            withDuration: configuration.fadeDuration,
            delay: 0.0,
            options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState],
            animations: {
                self.alpha = 1.0
            }
        )
    }
    
    /// 取消延时隐藏`HUD`
    private func cancelDelayDismissRequest() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(dismiss),
            object: self
        )
    }
    
    /// 隐藏`HUD`
    @objc public func dismiss() {
        cancelDelayDismissRequest()
        UIView.animate(
            withDuration: configuration.fadeDuration,
            delay: 0.0,
            options: [.curveEaseIn, .beginFromCurrentState],
            animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            }
        )
    }
    
    /// 延时隐藏`HUD`
    /// - parameter duration: 延时时间, 默认`200ms`
    public func dismissAfter(delay duration: TimeInterval = 0.2) {
        cancelDelayDismissRequest()
        perform(#selector(dismiss), with: self, afterDelay: duration)
    }
    
    /// 更新延时隐藏处理
    private func updateDelayHiding() {
        if activityIndicator != nil && !(activityIndicator is IMStateAnimation) {
            cancelDelayDismissRequest()
        } else {
            dismissAfter(delay: configuration.delayTime)
        }
    }
}



// MARK: - Configuration

public extension IMProgressHUD {
    
    /// 活动指示器类型枚举
    typealias ActivityIndicatorType = IMBaseActivityIndicator.IndicatorType
     
    /// 进度指示器类型枚举
    typealias ProgressIndicatorType = IMProgressIndicator.IndicatorType
    
    /// 状态类型枚举
    typealias State = IMStateAnimation.State

    /// `HUD`弹框位置枚举
    enum Location {
        
        case top(offset: CGFloat)
        
        case center(offset: CGFloat)
        
        case bottom(offset: CGFloat)
        
        public static var top: Self {
            .top(offset: 0.0)
        }
        
        public static var center: Self {
            .center(offset: 0.0)
        }
        
        public static var bottom: Self {
            .bottom(offset: 0.0)
        }
        
        public static var `default`: Self {
            .center
        }
    }

    /// 样式配置
    struct Configuration {
        
        /// 暗度颜色，默认 `UIColor.clear`
        public var dimmingColor: UIColor = .clear
        
        
        
        /// 颜色，默认 `#484B55`
        public var color: UIColor = #colorLiteral(red: 0.2823529412, green: 0.2941176471, blue: 0.3333333333, alpha: 1)
        
        /// 圆角大小，默认 `14.0`
        public var cornerRadius: CGFloat = 14.0
        
        /// 内容边距，默认 `UIEdgeInsets(top: 18.0, left: 24.0, bottom: 18.0, right: 24.0)`
        public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 18.0, left: 24.0, bottom: 18.0, right: 24.0)
                
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
        
        /// 文本和图标间距，默认 `12.0`
        public var spacing: CGFloat = 12.0
        
        

        /// 指示器颜色，默认 `UIColor.lightGray`
        public var indicatorColor: UIColor = UIColor.lightGray
        
        /// 指示器大小，默认 `CGSize(width: 35.0, height: 35.0)`
        public var indicatorSize: CGSize = CGSize(width: 35.0, height: 35.0)
        
        
        
        
        /// 文本颜色，默认 `UIColor.white`
        public var messageColor: UIColor = .white
        
        /// 文本字体，默认 `UIFont.systemFont(ofSize: 16.0, weight: .medium)`
        public var messageFont: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        
        /// 文本行数，默认 `0`
        public var numberOfMessageLines: Int = 0
        
        
        
        /// fade动画时间，默认 `0.15s`
        public var fadeDuration: TimeInterval = 0.15
                
        /// 延时隐藏时间，默认 `1.5s`
        public var delayTime: TimeInterval = 1.5
        
        /// 用户是否可以交互处理，默认 `true`
        public var isUserInteractionEnabled: Bool = true
    }
}



// MARK: - Static

public extension IMProgressHUD {
    
    private static let shared = IMProgressHUD()

    /// 全局配置
    static var configuration = Configuration()
    
    /// `HUD`是否可见
    static var isVisible: Bool {
        shared.superview != nil
    }
    
    /// 获取指定容器视图上显示的`HUD`
    /// - parameter containerView: `IMProgressHUD` 显示的容器视图
    /// - returns : `IMProgressHUD`对象
    @discardableResult
    static func hud(from containerView: UIView) -> IMProgressHUD? {
        containerView.subviews.first(where: { $0 is IMProgressHUD }) as? IMProgressHUD
    }
    
    
    
    // MARK: - Dismissal
    
    /// 隐藏`HUD`
    static func dismiss() {
        guard isVisible else {
            return
        }
        shared.dismiss()
    }
    
    /// 延时隐藏`HUD`
    /// - parameter duration: 延时时间
    static func dismissAfter(delay duration: TimeInterval) {
        guard isVisible else {
            return
        }
        shared.dismissAfter(delay: duration)
    }
    
    
    
    // MARK: - Presentation

    /// 显示`HUD`
    /// - parameter containerView: `IMProgressHUD` 显示的容器视图，默认`nil`, 自动使用 `KeyWindow`
    /// - parameter configuration: `IMProgressHUD` 配置闭包
    static func show(
        in containerView: UIView? = nil,
        configureBlock: @escaping (IMProgressHUD) -> Void
    ) {
        let hud = shared
        shared.configuration = Self.configuration
        configureBlock(hud)
        if let containerView = containerView {
            hud.show(in: containerView)
        } else if let keyWindow = UIApplication.shared.compatibleKeyWindow {
            hud.show(in: keyWindow)
        }
    }
    
    /// 显示`Toast`
    /// - parameter message: 显示的文本内容
    /// - parameter location: 文本位置
    /// - returns : `IMProgressHUD`对象
    @discardableResult
    static func showToast(
        message: String,
        location: Location
    ) -> IMProgressHUD {
        let hud = IMProgressHUD()
        hud.location = location
        if let keyWindow = UIApplication.shared.compatibleKeyWindow {
            hud.show(in: keyWindow)
        }
        return hud
    }
    
    /// 显示`Toast`
    /// - parameter message: 显示的文本内容
    static func showToast(_ message: String) {
        show {
            $0.message = message
            $0.icon = nil
            $0.activityIndicator = nil
        }
    }
    
    /// 显示`HUD`
    /// - parameter message: 显示的文本内容，默认`nil`
    /// - parameter image: 显示的图标内容，默认`nil`
    static func show(
        message: String? = nil,
        image: UIImage? = nil
    ) {
        show {
            $0.message = message
            $0.icon = image
        }
    }
    
    /// 显示成功HUD
    /// - parameter message: 显示的文本内容，默认`nil`
    static func showSuccess(_ message: String? = nil) {
        show {
            $0.message = message
            $0.setState(.success)
        }
    }
    
    /// 显示失败HUD
    /// - parameter message: 显示的文本内容，默认`nil`
    static func showFail(_ message: String? = nil) {
        show {
            $0.message = message
            $0.setState(.fail)
        }
    }
    
    /// 显示HUD
    /// - parameter activityIndicator: 显示的活动指示器
    /// - parameter message: 显示的文本内容，默认`nil`
    static func showIndicator(
        _ activityIndicator: IMActivityIndicating,
        message: String? = nil
    ) {
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
    /// - parameter indicatorType: 活动指示器动画类型, 默认`ActivityIndicatorType.default`
    /// - parameter message: 显示的文本内容，默认`nil`
    static func showIndicator(
        _ indicatorType: ActivityIndicatorType = .default,
        message: String? = nil
    ) {
        show {
            $0.message = message
            $0.setActivity(indicatorType)
        }
    }
    
    /// 显示HUD
    /// - parameter progress: 显示的进度值，范围`[0.0, 1.0]`
    /// - parameter indicatorType: 指示器类型, 默认`ProgressIndicatorType.default`
    /// - parameter message: 显示的文本内容，默认`nil`
    static func showProgress(
        _ progress: CGFloat,
        indicatorType: ProgressIndicatorType = .default,
        message: String? = nil
    ) {
        show {
            $0.message = message
            $0.setProgress(progress, indicatorType: indicatorType)
        }
    }
}



// MARK: - Private creator

private extension IMProgressHUD {
    
    func createContentView(_ arrangedSubviews: UIView...) -> UIStackView {
        let contentView = UIStackView(arrangedSubviews: arrangedSubviews)
        contentView.alignment = .center
        contentView.distribution = .equalCentering
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.axis = .vertical
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }
    
    static func createIconView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    static func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }
    
    static func createIndicatorView() -> UIView {
        let view = UIView()
        view.isHidden = true
        return view
    }
}
