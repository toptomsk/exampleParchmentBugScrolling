import UIKit

/// A custom `UIView` subclass used by `PagingViewController`,
/// responsible for setting up the view hierarchy and its layout
/// constraints.
///
/// If you need additional customization, like changing the
/// constraints, you can subclass `PagingView` and override
/// `loadView:` in `PagingViewController` to use your subclass.
open class PagingView: UIView {
    // MARK: Public Properties

    
    public var leftMenuAnchor: NSLayoutConstraint?
    public var rightMenuAnchor: NSLayoutConstraint?
    
    public let collectionView: UICollectionView
    public let pageView: UIView
    public var options: PagingOptions {
        didSet {
            heightConstraint?.constant = options.menuItemSize.height
            collectionView.backgroundColor = options.menuBackgroundColor
        }
    }

    // MARK: Private Properties

    private var heightConstraint: NSLayoutConstraint?

    // MARK: Initializers

    /// Creates an instance of `PagingView`.
    ///
    /// - Parameter options: The `PagingOptions` passed into the
    /// `PagingViewController`.
    public init(options: PagingOptions, collectionView: UICollectionView, pageView: UIView) {
        self.options = options
        self.collectionView = collectionView
        self.pageView = pageView
        super.init(frame: .zero)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Methods

    /// Configures the view hierarchy, sets up the layout constraints
    /// and does any other customization based on the `PagingOptions`.
    /// Override this if you need any custom behavior.
    open func configure() {
        collectionView.backgroundColor = options.menuBackgroundColor
        addSubview(pageView)
        addSubview(collectionView)
        setupConstraints()
    }

    /// Sets up all the layout constraints. Override this if you need to
    /// make changes to how the views are layed out.
    open func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageView.translatesAutoresizingMaskIntoConstraints = false

        let metrics = [
            "height": options.menuHeight,
        ]

        let views = [
            "collectionView": collectionView,
            "pageView": pageView,
        ]

        #if swift(>=4.2)
            let formatOptions = NSLayoutConstraint.FormatOptions()
        #else
            let formatOptions = NSLayoutFormatOptions()
        #endif
        
        if #available(iOS 9.0, *) {
            leftMenuAnchor = collectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
            leftMenuAnchor!.isActive = true
            rightMenuAnchor = collectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
            rightMenuAnchor!.isActive = true
        } else {
            // Fallback on earlier versions
            let horizontalMenuViewContraints = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[collectionView]|",
                options: formatOptions,
                metrics: metrics,
                views: views
            )
            addConstraints(horizontalMenuViewContraints)
        }
        
        let horizontalPagingContentViewContraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[pageView]|",
            options: formatOptions,
            metrics: metrics,
            views: views
        )

        let verticalConstraintsFormat: String
        switch options.menuPosition {
        case .top:
            verticalConstraintsFormat = "V:|[collectionView(==height)][pageView]|"
        case .bottom:
            verticalConstraintsFormat = "V:|[pageView][collectionView(==height)]|"
        }

        let verticalContraints = NSLayoutConstraint.constraints(
            withVisualFormat: verticalConstraintsFormat,
            options: formatOptions,
            metrics: metrics,
            views: views
        )

        addConstraints(horizontalPagingContentViewContraints)
        addConstraints(verticalContraints)

        for constraint in verticalContraints {
            if constraint.firstAttribute == NSLayoutConstraint.Attribute.height {
                heightConstraint = constraint
            }
        }
    }
}

