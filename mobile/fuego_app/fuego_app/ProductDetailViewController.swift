import UIKit

class ProductDetailViewController: UIViewController {
    
    // Product data structure matching web interface
    struct Product {
        let name: String
        let description: String
        let price: String
        let images: [String]
        let collection: String
        let isUnlocked: Bool
        let customizables: [Customizable]
    }
    
    struct Customizable {
        let name: String
        let type: CustomizableType
        let options: [CustomizableOption]
        let requiredChallenge: String
        let isUnlocked: Bool
    }
    
    struct CustomizableOption {
        let name: String
        let value: String
        let previewImage: String?
    }
    
    enum CustomizableType {
        case color
        case text
        case logo
        case material
    }
    
    private let product: Product
    private var currentImageIndex = 0
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let closeButton = UIButton(type: .system)
    private let productImageView = UIImageView()
    private let imageIndicatorStack = UIStackView()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let productNameLabel = UILabel()
    private let collectionLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let customizablesContainer = UIView()
    private let customizablesTitle = UILabel()
    private let customizablesStack = UIStackView()
    private let addToBagButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    
    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
        
        // Set modal presentation style to match web modal
        self.modalPresentationStyle = .pageSheet
        self.modalTransitionStyle = .coverVertical
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        populateContent()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0) // brand-black
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Product image
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        contentView.addSubview(productImageView)
        
        // Image navigation buttons
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.setTitle("‹", for: .normal)
        prevButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        prevButton.tintColor = .white
        prevButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        prevButton.layer.cornerRadius = 20
        prevButton.addTarget(self, action: #selector(previousImage), for: .touchUpInside)
        contentView.addSubview(prevButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("›", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        nextButton.tintColor = .white
        nextButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        nextButton.layer.cornerRadius = 20
        nextButton.addTarget(self, action: #selector(nextImage), for: .touchUpInside)
        contentView.addSubview(nextButton)
        
        // Image indicators
        imageIndicatorStack.translatesAutoresizingMaskIntoConstraints = false
        imageIndicatorStack.axis = .horizontal
        imageIndicatorStack.spacing = 8
        imageIndicatorStack.alignment = .center
        contentView.addSubview(imageIndicatorStack)
        
        // Product info labels
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        productNameLabel.font = UIFont.systemFont(ofSize: 28, weight: .light)
        productNameLabel.textColor = .white
        productNameLabel.numberOfLines = 0
        contentView.addSubview(productNameLabel)
        
        collectionLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        collectionLabel.textColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0) // brand-accent
        collectionLabel.text = product.collection.uppercased()
        contentView.addSubview(collectionLabel)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        priceLabel.textColor = .white
        contentView.addSubview(priceLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        contentView.addSubview(descriptionLabel)
        
        // Customizables section
        setupCustomizablesSection()
        
        // Action buttons
        setupActionButtons()
    }
    
    private func setupActionButtons() {
        addToBagButton.translatesAutoresizingMaskIntoConstraints = false
        addToBagButton.backgroundColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0) // brand-accent
        addToBagButton.setTitleColor(.black, for: .normal)
        addToBagButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        addToBagButton.layer.cornerRadius = 8
        addToBagButton.setTitle(product.isUnlocked ? "ADD TO BAG" : "LOCKED", for: .normal)
        addToBagButton.isEnabled = product.isUnlocked
        if !product.isUnlocked {
            addToBagButton.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
            addToBagButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
        }
        addToBagButton.addTarget(self, action: #selector(addToBag), for: .touchUpInside)
        contentView.addSubview(addToBagButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("SHARE", for: .normal)
        shareButton.setTitleColor(UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0), for: .normal)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        shareButton.layer.borderWidth = 2
        shareButton.layer.borderColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0).cgColor
        shareButton.layer.cornerRadius = 8
        shareButton.addTarget(self, action: #selector(shareProduct), for: .touchUpInside)
        contentView.addSubview(shareButton)
    }
    
    private func setupCustomizablesSection() {
        // Container for customizables
        customizablesContainer.translatesAutoresizingMaskIntoConstraints = false
        customizablesContainer.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        customizablesContainer.layer.cornerRadius = 12
        customizablesContainer.layer.borderWidth = 1
        customizablesContainer.layer.borderColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0).cgColor
        contentView.addSubview(customizablesContainer)
        
        // Title
        customizablesTitle.translatesAutoresizingMaskIntoConstraints = false
        customizablesTitle.text = "🏆 FITNESS REWARDS"
        customizablesTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        customizablesTitle.textColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        customizablesContainer.addSubview(customizablesTitle)
        
        // Stack view for customizable options
        customizablesStack.translatesAutoresizingMaskIntoConstraints = false
        customizablesStack.axis = .vertical
        customizablesStack.spacing = 16
        customizablesContainer.addSubview(customizablesStack)
        
        // Populate with product customizables
        populateCustomizables()
    }
    
    private func populateCustomizables() {
        // Clear existing customizables
        customizablesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for customizable in product.customizables {
            let customizableView = createCustomizableView(customizable: customizable)
            customizablesStack.addArrangedSubview(customizableView)
        }
        
        // Hide section if no customizables
        customizablesContainer.isHidden = product.customizables.isEmpty
        
        // Update constraints based on visibility
        updateActionButtonConstraints()
    }
    
    private func createCustomizableView(customizable: Customizable) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Header with name and lock status
        let headerStack = UIStackView()
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 8
        
        let nameLabel = UILabel()
        nameLabel.text = customizable.name.uppercased()
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        nameLabel.textColor = customizable.isUnlocked ? .white : UIColor(white: 0.5, alpha: 1.0)
        
        let statusIcon = UILabel()
        statusIcon.text = customizable.isUnlocked ? "✅" : "🔒"
        statusIcon.font = UIFont.systemFont(ofSize: 16)
        
        headerStack.addArrangedSubview(nameLabel)
        headerStack.addArrangedSubview(UIView()) // Spacer
        headerStack.addArrangedSubview(statusIcon)
        
        container.addSubview(headerStack)
        
        // Challenge requirement
        let challengeLabel = UILabel()
        challengeLabel.translatesAutoresizingMaskIntoConstraints = false
        challengeLabel.text = customizable.isUnlocked ? "UNLOCKED" : "Unlock by: \(customizable.requiredChallenge)"
        challengeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        challengeLabel.textColor = customizable.isUnlocked ? UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0) : UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        challengeLabel.numberOfLines = 0
        container.addSubview(challengeLabel)
        
        // Options (only show if unlocked)
        if customizable.isUnlocked {
            let optionsStack = UIStackView()
            optionsStack.translatesAutoresizingMaskIntoConstraints = false
            optionsStack.axis = .horizontal
            optionsStack.spacing = 8
            optionsStack.distribution = .fillEqually
            
            for option in customizable.options.prefix(4) { // Show up to 4 options
                let optionButton = createOptionButton(option: option, type: customizable.type)
                optionsStack.addArrangedSubview(optionButton)
            }
            
            container.addSubview(optionsStack)
            
            NSLayoutConstraint.activate([
                optionsStack.topAnchor.constraint(equalTo: challengeLabel.bottomAnchor, constant: 12),
                optionsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                optionsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                optionsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                optionsStack.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            challengeLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: container.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            challengeLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 4),
            challengeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            challengeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createOptionButton(option: CustomizableOption, type: CustomizableType) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0).cgColor
        
        switch type {
        case .color:
            // Show color swatch
            button.backgroundColor = UIColor(named: option.value) ?? UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
            button.setTitle("", for: .normal)
        case .text, .logo, .material:
            // Show text label
            button.setTitle(option.name, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        
        button.addTarget(self, action: #selector(customizableOptionTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func customizableOptionTapped(_ sender: UIButton) {
        // Handle customizable option selection
        sender.backgroundColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // You could add more logic here to update product preview, etc.
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Product image
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor, multiplier: 1.25),
            
            // Navigation buttons
            prevButton.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor, constant: 16),
            prevButton.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),
            prevButton.widthAnchor.constraint(equalToConstant: 40),
            prevButton.heightAnchor.constraint(equalToConstant: 40),
            
            nextButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -16),
            nextButton.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 40),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Image indicators
            imageIndicatorStack.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 16),
            imageIndicatorStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Collection label
            collectionLabel.topAnchor.constraint(equalTo: imageIndicatorStack.bottomAnchor, constant: 24),
            collectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            collectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Product name
            productNameLabel.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: 8),
            productNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            productNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Price
            priceLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Customizables section
            customizablesContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            customizablesContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            customizablesContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            customizablesTitle.topAnchor.constraint(equalTo: customizablesContainer.topAnchor, constant: 16),
            customizablesTitle.leadingAnchor.constraint(equalTo: customizablesContainer.leadingAnchor, constant: 16),
            customizablesTitle.trailingAnchor.constraint(equalTo: customizablesContainer.trailingAnchor, constant: -16),
            
            customizablesStack.topAnchor.constraint(equalTo: customizablesTitle.bottomAnchor, constant: 16),
            customizablesStack.leadingAnchor.constraint(equalTo: customizablesContainer.leadingAnchor, constant: 16),
            customizablesStack.trailingAnchor.constraint(equalTo: customizablesContainer.trailingAnchor, constant: -16),
            customizablesStack.bottomAnchor.constraint(equalTo: customizablesContainer.bottomAnchor, constant: -16),
            
            // Action buttons
            addToBagButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            addToBagButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            addToBagButton.heightAnchor.constraint(equalToConstant: 56),
            
            shareButton.topAnchor.constraint(equalTo: addToBagButton.bottomAnchor, constant: 16),
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            shareButton.heightAnchor.constraint(equalToConstant: 56),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        // Set up conditional constraints for action buttons
        updateActionButtonConstraints()
    }
    
    private func updateActionButtonConstraints() {
        // Remove existing top constraint for add to bag button
        addToBagButton.constraints.forEach { constraint in
            if constraint.firstAttribute == .top {
                constraint.isActive = false
            }
        }
        
        // Add appropriate constraint based on customizables visibility
        if customizablesContainer.isHidden || product.customizables.isEmpty {
            addToBagButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32).isActive = true
        } else {
            addToBagButton.topAnchor.constraint(equalTo: customizablesContainer.bottomAnchor, constant: 32).isActive = true
        }
    }
    
    private func populateContent() {
        productNameLabel.text = product.name
        priceLabel.text = product.price
        descriptionLabel.text = product.description
        
        // Setup image indicators
        setupImageIndicators()
        
        // Load first image
        updateImageDisplay()
        
        // Hide navigation buttons if only one image
        if product.images.count <= 1 {
            prevButton.isHidden = true
            nextButton.isHidden = true
        }
    }
    
    private func setupImageIndicators() {
        // Clear existing indicators
        imageIndicatorStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add indicator dots for each image
        for i in 0..<product.images.count {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 4
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            
            if i == currentImageIndex {
                dot.backgroundColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0) // brand-accent
            } else {
                dot.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
            }
            
            imageIndicatorStack.addArrangedSubview(dot)
        }
    }
    
    private func updateImageDisplay() {
        guard !product.images.isEmpty,
              currentImageIndex < product.images.count else {
            // Show placeholder gradient if no images
            showPlaceholderImage()
            return
        }
        
        let imageUrl = product.images[currentImageIndex]
        
        // If it's a URL, load the image
        if imageUrl.hasPrefix("http") {
            loadImageFromURL(imageUrl)
        } else {
            // Show placeholder for non-URL images
            showPlaceholderImage()
        }
        
        // Update indicators
        setupImageIndicators()
    }
    
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            showPlaceholderImage()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.showPlaceholderImage()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.productImageView.layer.sublayers?.removeAll()
                self.productImageView.image = image
                self.productImageView.contentMode = .scaleAspectFill
            }
        }.resume()
    }
    
    private func showPlaceholderImage() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor,
            UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            gradientLayer.frame = self.productImageView.bounds
            self.productImageView.image = nil
            self.productImageView.layer.sublayers?.removeAll()
            self.productImageView.layer.addSublayer(gradientLayer)
        }
    }
    
    // MARK: - Actions
    @objc private func closeModal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func previousImage() {
        guard product.images.count > 1 else { return }
        currentImageIndex = currentImageIndex > 0 ? currentImageIndex - 1 : product.images.count - 1
        updateImageDisplay()
    }
    
    @objc private func nextImage() {
        guard product.images.count > 1 else { return }
        currentImageIndex = (currentImageIndex + 1) % product.images.count
        updateImageDisplay()
    }
    
    @objc private func addToBag() {
        guard product.isUnlocked else { return }
        
        // Show success feedback
        let alert = UIAlertController(title: "Added to Bag", 
                                    message: "\(product.name) has been added to your bag.", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue Shopping", style: .default))
        alert.addAction(UIAlertAction(title: "View Bag", style: .default))
        
        present(alert, animated: true)
    }
    
    @objc private func shareProduct() {
        let shareText = "Check out this \(product.collection) item: \(product.name) - Earn it through FUEGO!"
        let activityController = UIActivityViewController(activityItems: [shareText], 
                                                        applicationActivities: nil)
        
        // For iPad support
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        
        present(activityController, animated: true)
    }
}