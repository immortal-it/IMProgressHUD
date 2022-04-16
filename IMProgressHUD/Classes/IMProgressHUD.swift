//
//  IMProgressHUD.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/3/16.
//

import UIKit

/// Displays a simple HUD window containing a progress indicator and one optional label for short message.
open class IMProgressHUD: UIView {
    
    /// Transition styles available when presenting HUD.
    public enum TransitionStyle {
        
        /// The animation is zoom and fade style.
        case `default`
        
        /// The animation is fade style.
        case fade
        
        /// The animation is zoom style.
        case translationZoom(translation: CGPoint)

        /// No animation.
        case none
        
        /// Custom animation.
        case custom(IMAnimatorTransitioning)
    }
      
    public typealias Axis = NSLayoutConstraint.Axis
    
    /// The configuration you specify when creating the HUD.
    public var configuration = IMProgressHUD.configuration {
        didSet {
           configure()
        }
    }
    
    private let identifier = "com.immortal.IMProgressHUD"

    /// Initializes.
    public init() {
        super.init(frame: UIScreen.main.bounds)
        initView()
        setupSubviews()
        configure()
    }
        
    /// Creates a new progress HUD with the configuration you specify.
    ///
    /// - Parameters:
    ///  - configuration: The configuration with which to initialize the progress HUD.
    public convenience init(configuration: Configuration) {
        self.init()
        self.configuration = configuration
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Convenience
    
    private func configure() {
        isUserInteractionEnabled = !configuration.isUserInteractionEnabled
        dimmingView.backgroundColor = configuration.dimmingColor
        dimmingView.isHidden = configuration.dimmingColor == nil

        if let effect = configuration.backgroundEffect {
            containerView.effect = effect
            containerView.backgroundColor = nil
        } else {
            containerView.effect = nil
            containerView.backgroundColor = configuration.backgroundColor
        }
        containerView.layer.cornerRadius = configuration.cornerRadius
        containerView.layer.masksToBounds = configuration.cornerRadius > 0
        
        contentStackView.layoutMargins = configuration.contentInsets
        contentStackView.spacing = configuration.spacing
        
        if let activityIndicator = activityIndicator as? BaseActivityIndicator {
            activityIndicator.color = configuration.indicatorColor
            activityIndicator.lineWidth = configuration.lineWidth
        }
        
        updateAligningIfNeeded()
    }
    
    /// Update content animatable.
    open func updateWithAnimation(_ animations: @escaping (IMProgressHUD) -> Void) {
        UIView.animate(withDuration: 0.2) {
            animations(self)
            self.layoutIfNeeded()
        }
    }
    
    
     
    // MARK: - UIView
    
    let containerView: UIVisualEffectView = createContainerView()
    
    private let dimmingView = UIView()

    private let contentStackView = createContentStackView()
    
    private lazy var messageLabel = createMessageLabel()

    private lazy var indicatorContainerView = createIconView()

    private var indicatorInternalConstraints: [NSLayoutConstraint] = []

    private func initView() {
        accessibilityIdentifier = identifier
        isAccessibilityElement = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private var contentStackViewTrailingConstraint: NSLayoutConstraint?
    
    private func setupSubviews() {
        addSubviewLayoutEqualToEdges(dimmingView)
        contentStackViewTrailingConstraint = contentStackView.trailingAnchor.constraint(equalTo: containerView.contentView.trailingAnchor)
        containerView.contentView.addSubview(
            contentStackView,
            constraints:
                contentStackView.leadingAnchor.constraint(equalTo: containerView.contentView.leadingAnchor),
                contentStackViewTrailingConstraint!,
                contentStackView.topAnchor.constraint(equalTo: containerView.contentView.topAnchor),
                contentStackView.bottomAnchor.constraint(equalTo: containerView.contentView.bottomAnchor)
        )
        addSubview(containerView)
        updateContainerViewConstraints()
        updateAligningIfNeeded()
    }
    
    private func updateIndicatorContainerViewConstraints() {
        indicatorContainerView.removeConstraints(indicatorInternalConstraints)
        indicatorInternalConstraints = [
            indicatorContainerView.widthAnchor.constraint(equalToConstant: configuration.indicatorSize.width),
            indicatorContainerView.heightAnchor.constraint(equalToConstant: configuration.indicatorSize.height)
        ]
        NSLayoutConstraint.activate(indicatorInternalConstraints)
        indicatorContainerView.setNeedsLayout()
    }
    
    private func updateAligningIfNeeded() {
        guard let trailingConstraint = contentStackViewTrailingConstraint else {
            return
        }
        trailingConstraint.isActive = false
        containerView.contentView.removeConstraint(trailingConstraint)

        contentStackViewTrailingConstraint = (configuration.messageAlignment == .left && axis == .horizontal) ? contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.contentView.trailingAnchor) : contentStackView.trailingAnchor.constraint(equalTo: containerView.contentView.trailingAnchor)
        contentStackViewTrailingConstraint?.isActive = true
        
        if window != nil {
            containerView.contentView.layoutIfNeeded()
        }
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        message = nil
        activityIndicator = nil
        icon = nil
        animator = nil
    }
    
    
    
    // MARK: - Location
    
    open var location: Location = .default {
        didSet {
            guard oldValue != location else {
                return
            }
            updateContainerViewConstraints()
        }
    }
    
    private var locationConstraints: [NSLayoutConstraint] = []

    private func updateContainerViewConstraints() {
        if !locationConstraints.isEmpty {
            removeConstraints(locationConstraints)
        }
        locationConstraints = [
            containerView.widthAnchor
                .constraint(greaterThanOrEqualToConstant: configuration.minimumSize.width)
                .priority(.defaultLow),
            containerView.widthAnchor
                .constraint(lessThanOrEqualTo: widthAnchor, multiplier: configuration.maxWidthPercentage)
                .priority(.defaultHigh),
            containerView.heightAnchor
                .constraint(greaterThanOrEqualToConstant: configuration.minimumSize.height)
                .priority(.defaultLow),
            containerView.heightAnchor
                .constraint(lessThanOrEqualTo: heightAnchor, multiplier: configuration.maxHeightPercentage)
                .priority(.defaultHigh),
            containerView.centerXAnchor
                .constraint(equalTo: centerXAnchor)
        ]
        
        switch location {
            case .top(offset: let offset):
                locationConstraints.append(
                    containerView.topAnchor
                        .constraint(equalTo: compatibleSafeTopAnchor, constant: offset)
                )
            case .center(offset: let offset):
                locationConstraints.append(
                    containerView.centerYAnchor
                        .constraint(equalTo: centerYAnchor, constant: offset)
                )
            case .bottom(offset: let offset):
                locationConstraints.append(
                    compatibleSafeBottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: offset)
                )
        }
        NSLayoutConstraint.activate(locationConstraints)
         
        if window != nil,
           let superview = superview,
            superview.frame.width * superview.frame.height != .zero {
            layoutIfNeeded()
        }
    }
    
     
    
    // MARK: - Property
    
    /// The axis along which the arranged content views are laid out.
    open var axis: Axis {
        get {
            contentStackView.axis
        }
        set {
            contentStackView.axis = newValue
            updateAligningIfNeeded()
        }
    }

    /// The text that the message label displays.
    open var message: String? {
        get {
            messageLabel.text
        }
        set {
            messageLabel.text = newValue
            
            let isHidden = newValue == nil
            if messageLabel.isHidden != isHidden {
                messageLabel.isHidden = isHidden
            }
            if !contentStackView.arrangedSubviews.contains(messageLabel) {
                contentStackView.addArrangedSubview(messageLabel)
            }
            messageLabel.font = configuration.messageFont
            messageLabel.textColor = configuration.messageColor
            messageLabel.textAlignment = configuration.messageAlignment
            messageLabel.numberOfLines = configuration.numberOfMessageLines

            hideIfNeeded()
        }
    }
    
    /// The styled text that the message label displays.
    open var attributedMessage: NSAttributedString? {
        get {
            messageLabel.attributedText
        }
        set {
            let isHidden = newValue == nil
            if messageLabel.isHidden != isHidden {
                messageLabel.isHidden = isHidden
            }
            messageLabel.font = configuration.messageFont
            messageLabel.textColor = configuration.messageColor
            messageLabel.textAlignment = configuration.messageAlignment
            messageLabel.numberOfLines = configuration.numberOfMessageLines
            messageLabel.attributedText = newValue
            if !contentStackView.arrangedSubviews.contains(messageLabel) {
                contentStackView.addArrangedSubview(messageLabel)
            }
            hideIfNeeded()
        }
    }
    
    /// The image displayed in the progress HUD.
    open var icon: UIImage? {
        willSet {
            let isHidden = newValue == nil && activityIndicator == nil
            if indicatorContainerView.isHidden != isHidden {
                indicatorContainerView.isHidden = isHidden
            }
        }
        didSet {
            indicatorContainerView.image = icon
            if !contentStackView.arrangedSubviews.contains(indicatorContainerView) {
                contentStackView.insertArrangedSubview(indicatorContainerView, at: 0)
            }
            if indicatorContainerView.image != nil && !indicatorInternalConstraints.isEmpty {
                indicatorContainerView.removeConstraints(indicatorInternalConstraints)
            }
            hideIfNeeded()
        }
    }
    
    /// The activity indicator that shows that a task is in progress HUD.
    open var activityIndicator: IMActivityIndicating? {
        willSet {
            activityIndicator?.remove()
            
            let isHidden = newValue == nil && icon == nil
            if indicatorContainerView.isHidden != isHidden {
                indicatorContainerView.isHidden = isHidden
            }
        }
        didSet {
            if !contentStackView.arrangedSubviews.contains(indicatorContainerView) {
                contentStackView.insertArrangedSubview(indicatorContainerView, at: 0)
            }
            if let activityIndicator = activityIndicator {
                updateIndicatorContainerViewConstraints()
                if let activityIndicator = activityIndicator as? BaseActivityIndicator {
                    activityIndicator.color = configuration.indicatorColor
                    activityIndicator.lineWidth = configuration.lineWidth
                }
                activityIndicator.apply(in: indicatorContainerView)
            }
            hideIfNeeded()
        }
    }
    
    /// The progress HUD’s current progress value for a specified task..
    open var progress: CGFloat = .zero {
        didSet {
            guard let progressIndicator = activityIndicator as? IMProgressIndicating else {
                return
            }
            progressIndicator.progress = progress
        }
    }
    
    
    
    // MARK: - Presentation
    
    /// A Boolean value that determines whether the progress HUD can auto hide.
    /// Default value is `true`.
    open var autoHide: Bool = true
    
    private var animator: IMAnimatorTransitioning?

    /// Presents the progress HUD with a transition animation.
    ///
    /// - Parameters:
    ///    - windowView: The receiver’s window view.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    open func show(in windowView: UIView, transitionStyle: TransitionStyle = .default) {
        guard !windowView.subviews.contains(self) else {
            return
        }
        frame = windowView.bounds
        windowView.addSubview(self)
       
        guard animator == nil else {
            return
        }
        animator = {
            switch transitionStyle {
                case .default:
                    if axis == .horizontal {
                        switch location {
                            case .top, .bottom:
                                return PopoverAnimator()
                            case .center:
                                break
                        }
                    }
                    return ZoomAnimator()
                case .fade:
                     return FadeAnimator()
                case .translationZoom(let translation):
                    return TranslationZoomAnimator(translation: translation)
            case .custom(let animator):
                    return animator
                case .none:
                     return nil
            }
        }()
        if let animator = animator {
            animator.show(hud: self)
        }
        hideIfNeeded()
    }
    
    /// Presents the progress HUD in key window with a transition animation.
    ///
    /// - Parameters:
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    open func show(transitionStyle: TransitionStyle = .default) {
        guard let window = UIApplication.shared.compatibleKeyWindow else {
            print("The progress HUD has no window view.")
            return
        }
        show(in: window, transitionStyle: transitionStyle)
    }
     
    /// Hides the  progress HUD immediately.
    @objc
    open func hide() {
        Self.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(hide),
            object: self
        )
        if let animator = animator {
            animator.hide(hud: self)
        } else {
            removeFromSuperview()
        }
    }
    
    /// Hides the  progress HUD after a delay.
    ///
    /// - Parameters:
    ///    - delay: The minimum time before which the message is sent. The defualt value is`200ms`.
    open func hideAfterDelay(_ delay: TimeInterval = 0.2) {
        if delay <= 0 {
            hide()
        } else {
            Self.cancelPreviousPerformRequests(
                withTarget: self,
                selector: #selector(hide),
                object: self
            )
            perform(#selector(hide), with: self, afterDelay: delay, inModes: [.common])
        }
    }
    
    /// Hides if needed.
    private func hideIfNeeded() {
        if activityIndicator != nil && !(activityIndicator is StateIndicator) {
            Self.cancelPreviousPerformRequests(
                withTarget: self,
                selector: #selector(hide),
                object: self
            )
            return
        }
        if superview != nil && autoHide {
            hideAfterDelay(configuration.delayTime)
        }
    }
    
    
    
    // MARK: - Deprecated
    
    /// Hides the  progress HUD immediately.
    @available(*, deprecated, message: "Use hide() instead of dismiss(), this func will be removed")
    open func dismiss() {
        hide()
    }
    
    /// Hides the  progress HUD after a delay.
    ///
    /// - Parameter duration: delay time,  defualt is`200ms`
    @available(*, deprecated, message: "Use hideAfterDelay(:) instead of dismiss(delay:), this func will be removed")
    open func dismissAfter(delay duration: TimeInterval = 0.2) {
        hideAfterDelay(duration)
    }
    
    /// Update content animatable.
    @available(*, deprecated, message: "Use updateWithAnimation(:) instead of updateInAnimation(:), this func will be removed")
    open func updateInAnimation(_ block: @escaping (IMProgressHUD) -> Void) {
        updateWithAnimation(block)
    }
}



// MARK: - Configuration

public extension IMProgressHUD {
    
    /// An object that contains information about how to configure a progress HUD.
    struct Configuration {
        
        /// Initializes.
        public init() {
                
        }
        
        /// The dimming color.
        /// The default value is `nil`.
        public var dimmingColor: UIColor?
        
        /// Animation duration，default value is `0.15s`
        @available(*, deprecated, message: "Use IMAnimatorTransitioning instead of fadeDuration, this property will be removed")
        public var fadeDuration: TimeInterval = 0.15
                
        /// The delay time for hiding HUD.
        /// The default value is `2.5s`.
        public var delayTime: TimeInterval = 2.5
        
        /// A Boolean value that determines whether user events are ignored and removed from the event queue.
        /// The default value is `true`.
        public var isUserInteractionEnabled: Bool = true
        
        
        
        /// The blur effect to apply to the container's background.
        public var backgroundEffect: UIVisualEffect? = {
            if #available(iOS 13.0, *) {
                return UIBlurEffect(style: .systemChromeMaterialDark)
            } else {
                return UIBlurEffect(style: .dark)
            }
        }()
        
        /// The container's background color.
        /// The default value is `#484B55`.
        @available(*, deprecated, message: "Use backgroundColor instead of color, this property will be removed")
        public var color: UIColor {
            get {
                backgroundColor
            }
            set {
                backgroundColor = newValue
            }
        }

        /// The container's background color.
        /// The default value is `#484B55`.
        public var backgroundColor: UIColor = #colorLiteral(red: 0.2823529412, green: 0.2941176471, blue: 0.3333333333, alpha: 1)
        
        /// The radius to use when drawing rounded corners for the container’s background.
        /// The default value is `14.0`.
        public var cornerRadius: CGFloat = 14.0
        
        /// The distance in points between the content views.
        /// The default value is `12.0`.
        public var spacing: CGFloat = 12.0

        /// The custom distance that the content view is inset from the container's edges.
        /// The default value is `UIEdgeInsets(top: 18.0, left: 24.0, bottom: 18.0, right: 24.0)`.
        public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 18.0, left: 24.0, bottom: 18.0, right: 24.0)
                
        /// The maximum size of the container view.
        /// The default value is `CGSize.zero`.
        public var minimumSize: CGSize = .zero
      
        /// The maximum percentage of container superview's width .
        /// The default value is `0.8`.
        public var maxWidthPercentage: CGFloat = 0.8 {
            didSet { maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0) }
        }
        
        /// The maximum percentage of container superview's height .
        /// The default value is `0.8`.
        public var maxHeightPercentage: CGFloat = 0.8 {
            didSet { maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0) }
        }
        
        

        /// The indicator 's color.
        /// The default value is `UIColor.white`.
        public var indicatorColor: UIColor = UIColor.white
        
        /// The indicator 's size.
        /// The default value is `CGSize(width: 35.0, height: 35.0)`.
        public var indicatorSize: CGSize = CGSize(width: 35.0, height: 35.0)
        
        /// The indicator 's line width.
        /// The default value is `3.0`.
        public var lineWidth: CGFloat = 3.0

        
        
        /// The color of the message text.
        /// The default value is `UIColor.white`
        public var messageColor: UIColor = .white
        
        /// The technique for aligning the message text.
        /// The default value is `NSTextAlignment.natural`
        public var messageAlignment: NSTextAlignment = .natural

        
        /// The font of the message text.
        /// The default value is `UIFont.systemFont(ofSize: 16.0, weight: .regular)`
        ///
        /// If you’re using styled text, assigning a new value to this property applies the font to the entirety of the string in the attributedText property.
        public var messageFont: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        
        /// The maximum number of lines for rendering  message text.
        /// The default value is `0`.
        ///
        /// This property controls the maximum number of lines to use in order to fit the label’s text into its bounding rectangle.
        /// To remove any maximum limit, and use as many lines as needed, set the value of this property to 0.
        public var numberOfMessageLines: Int = 0
    }
    
    /// A flag used to determine how a progress HUD lays out its content when its bounds change.
    enum Location: Equatable {
        
        /// Top location.
        case top(offset: CGFloat)
        
        /// Center location.
        case center(offset: CGFloat)
        
        /// Bottom location.
        case bottom(offset: CGFloat)
        
        public static var top: Self {
            .top(offset: 34.0)
        }
        
        public static var center: Self {
            .center(offset: 0.0)
        }
        
        public static var bottom: Self {
            .bottom(offset: 34.0)
        }
        
        public static var `default`: Self {
            .center
        }
    }
}



// MARK: - Indicator

public extension IMProgressHUD {
        
    /// An activity indicator type  that shows that a task is in progress HUD
    enum ActivityIndicatorType: String {
        
        /// No style.
        case none = "-100000"
        
        /// A gradient circle style activity indicator.
        case `default` = "GradientCircle"
        
        /// A system style activity indicator.
        case system = "System"
        
        
        /// A circle style activity indicator.
        case circle = "Circle"
                
        /// An imperfect circle style activity indicator.
        case imperfectCircle = "ImperfectCircle"
        
        /// An half circle style activity indicator.
        case halfCircle = "HalfCircle"
        
        /// A asymmetric fade style activity indicator.
        case asymmetricFadeCircle = "AsymmetricFadeCircle"
        
        
        /// A pulse style activity indicator.
        case pulse = "Pulse"


        fileprivate func getIndicator() -> BaseActivityIndicator? {
            return BaseActivityIndicator.asIndicator("\(rawValue)ActivityIndicator")
        }
    }
         
    /// Add an activity indicator that shows that a task is in progress HUD.
    ///
    /// - Parameter indicatorType: The indicator's type, refer to `ActivityIndicatorType`.
    func setActivity(_ indicatorType: ActivityIndicatorType) {
        let activityIndicator = indicatorType.getIndicator()
        if let oldValue = self.activityIndicator,
           let newValue = activityIndicator,
           type(of: oldValue.self) == type(of: newValue.self) {
            return
        }
        self.activityIndicator = activityIndicator
    }
    
    /// An progress indicator type  that shows that a task is in progress HUD
    enum ProgressIndicatorType: String {
        
        /// A gradient circle style progress indicator.
        case `default` = "Default"
        
        /// An half circle style progress indicator.
        case halfCircle = "HalfCircle"

        fileprivate func getIndicator() -> BaseActivityIndicator? {
            return BaseActivityIndicator.asIndicator("\(rawValue)ProgressIndicator")
        }
    }

    /// Add a progress indicator that shows that a task is in progress HUD.
    ///
    /// - Parameters:
    ///  - progressValue: The current proress value.
    ///  - indicatorType: The indicator's type, refer to `ProgressIndicatorType`.
    func setProgress(
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
    
    /// The state for progress HUD.
    enum State {
        
        /// The state is success.
        case success
        
        /// The state is fail.
        case fail
    }
    
    /// Add a state that shows that a state in progress HUD.
    ///
    /// - Parameter state: The progress HUD's state, refer to `State`.
    func setState(_ state: State) {
        if let oldValue = activityIndicator as? StateIndicator,
           oldValue.state == state {
            return
        }
        activityIndicator = StateIndicator(state: state)
    }
}



// MARK: - Static

public extension IMProgressHUD {
   
    private static let shared = IMProgressHUD()

    /// The default configuration.
    static var configuration = Configuration()
   
    /// A Boolean value that determines whether the progress HUD is visible.
    static var isVisible: Bool {
        shared.superview != nil
    }
   
    /// 获取指定容器视图上显示的`HUD`
    ///
    /// - parameter containerView: `IMProgressHUD` 显示的容器视图
    /// - returns : `IMProgressHUD`对象
    @discardableResult
    static func hud(from containerView: UIView) -> IMProgressHUD? {
        containerView.subviews.first(where: { $0 is IMProgressHUD }) as? IMProgressHUD
    }
    
    
    
    // MARK: - Presentation
    
    /// Presents the progress HUD with a transition animation.
    ///
    /// - Parameters:
    ///    - windowView: The receiver’s window view.
    ///         If  the windowView is nil,  we will user`KeyWindow` as the window view.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    ///    - configureBlock: The configuration block.
    static func show(
        in windowView: UIView? = nil,
        transitionStyle: TransitionStyle = .default,
        configureBlock: @escaping (IMProgressHUD) -> Void
    ) {
        shared.configuration = Self.configuration
        configureBlock(shared)
        if let windowView = windowView {
            shared.show(in: windowView, transitionStyle: transitionStyle)
        } else {
            shared.show(transitionStyle: transitionStyle)
        }
    }
    
    /// Hides the  progress HUD immediately.
    static func hide() {
        guard isVisible else {
            return
        }
        shared.hide()
    }
    
    /// Hides the  progress HUD after a delay.
    ///
    /// - Parameters:
    ///    - delay: The minimum time before which the message is sent. The defualt value is`200ms`.
    static func hideAfterDelay(_ delay: TimeInterval = 0.2) {
        guard isVisible else {
            return
        }
        shared.hideAfterDelay(delay)
    }
    
    /// Presents the toast with a transition animation.
    ///
    /// - Parameters:
    ///    - message: The toast’s message.
    ///    - location: The toast’s location.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    @discardableResult
    static func showToast(
        message: String,
        location: Location,
        transitionStyle: TransitionStyle = .default
    ) -> IMProgressHUD {
        let hud = IMProgressHUD()
        hud.location = location
        hud.message = message
        hud.show(transitionStyle: transitionStyle)
        return hud
    }
    
    /// Presents the toast with a transition animation.
    ///
    /// - Parameters:
    ///    - message: The toast’s message.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    static func showToast(_ message: String, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.activityIndicator = nil
            $0.icon = nil
        }
    }
    
    /// Presents a info toast with a transition animation.
    ///
    /// - Parameters:
    ///    - message: The toast's message.
    ///    - image: The toast's  image.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    static func show(
        message: String? = nil,
        image: UIImage? = nil,
        transitionStyle: TransitionStyle = .default
    ) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = image
            $0.activityIndicator = nil
        }
    }
    
    /// Presents a successful HUD with a transition animation.
    ///
    /// - Parameters:
    ///    - message: The successful message.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    static func showSuccess(_ message: String? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.icon = nil
            $0.message = message
            $0.setState(.success)
        }
    }
    
    /// Presents a failed HUD with a transition animation.
    ///
    /// - Parameters:
    ///    - message: The failed message.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    static func showFail(_ message: String? = nil, transitionStyle: TransitionStyle = .default) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = nil
            $0.setState(.fail)
        }
    }
    
    /// Presents an indicator HUD with a transition animation.
    ///
    /// - Parameters:
    ///    - activityIndicator: The indicator.
    ///    - message: The message.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    static func showIndicator(
        _ activityIndicator: IMActivityIndicating,
        message: String? = nil,
        transitionStyle: TransitionStyle = .default
    ) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            if let oldValue = $0.activityIndicator,
               type(of: oldValue.self) == type(of: activityIndicator.self) {
                return
            }
            $0.activityIndicator = activityIndicator
        }
    }
    
    /// Presents an indicator HUD with a transition animation.
    ///
    /// - Parameters:
    ///    - indicatorType: The indicator type.
    ///    - message: The message.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    static func showIndicator(
        _ indicatorType: ActivityIndicatorType = .default,
        message: String? = nil,
        transitionStyle: TransitionStyle = .default
    ) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = nil
            $0.setActivity(indicatorType)
        }
    }
    
    /// Presents an indicator HUD with a transition animation.
    ///
    /// - Parameters:
    ///    - progress: The proress value，`[0.0, 1.0]`
    ///    - indicatorType: The indicator type.
    ///    - message: The message.
    ///    - transitionStyle: The transition style to use when presenting the `IMProgressHUD`.
    static func showProgress(
        _ progress: CGFloat,
        indicatorType: ProgressIndicatorType = .default,
        message: String? = nil,
        transitionStyle: TransitionStyle = .default
    ) {
        show(transitionStyle: transitionStyle) {
            $0.message = message
            $0.icon = nil
            $0.setProgress(progress, indicatorType: indicatorType)
        }
    }
    
    
    
    // MARK: - Deprecated
    
    /// Presents the progress HUD.
    ///
    /// - Parameters:
    ///    - windowView: The receiver’s window view.
    ///         If  the windowView is nil,  we will user`KeyWindow` as the window view.
    ///    - configureBlock: The configuration block.
    @available(*, deprecated, message: "Use show(in:,transitionStyle:,configureBlock:) instead of show(in:, configureBlock:), this func will be removed")
    static func show(
        in containerView: UIView? = nil,
        configureBlock: @escaping (IMProgressHUD) -> Void
    ) {
        show(in: containerView, transitionStyle: .none, configureBlock: configureBlock)
    }
    
    /// Hides the  progress HUD immediately.
    @available(*, deprecated, message: "Use hide() instead of dismiss(), this func will be removed")
    static func dismiss() {
        hide()
    }
   
    /// Hides the  progress HUD after a delay.
    ///
    /// - Parameter duration: delay time.
    @available(*, deprecated, message: "Use hideAfterDelay(:) instead of dismiss(delay:), this func will be removed")
    static func dismissAfter(delay duration: TimeInterval) {
        hideAfterDelay(duration)
    }
}



// MARK: - Private creator

private extension IMProgressHUD {
    
    static func createContainerView() -> UIVisualEffectView {
        let visualEffectView = UIVisualEffectView(effect: nil)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }
    
    static func createContentStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }
    
    func createIconView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }
}
