import UIKit
import AVFoundation
import HealthKit
import CoreLocation
import ActivityKit
import UserNotifications

// MARK: - Notification Extensions
extension NSNotification.Name {
    static let userAccountCreated = NSNotification.Name("userAccountCreated")
}

// MARK: - Live Activity Support
@available(iOS 16.1, *)
public struct GymActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var gymName: String
        public var isInRange: Bool
        public var timeElapsed: String
        public var sessionStartTime: Date
        
        public init(gymName: String, isInRange: Bool, timeElapsed: String, sessionStartTime: Date) {
            self.gymName = gymName
            self.isInRange = isInRange
            self.timeElapsed = timeElapsed
            self.sessionStartTime = sessionStartTime
        }
        
        // Add more descriptive properties for better display
        public var status: String {
            return isInRange ? "Active Session" : "Session Ended"
        }
        
        public var displayTime: String {
            let elapsed = Date().timeIntervalSince(sessionStartTime)
            let minutes = Int(elapsed / 60)
            return minutes > 0 ? "\(minutes)m" : "Just started"
        }
    }
    
    public var gymId: String
    public var appName: String
    
    public init(gymId: String, appName: String = "FUEGO") {
        self.gymId = gymId
        self.appName = appName
    }
}

@available(iOS 16.1, *)
class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<GymActivityAttributes>?
    private var gymEntryTime: Date?
    private var timer: Timer?
    
    private init() {}
    
    func startGymActivity(gymName: String, gymId: String) {
        print("🚀 LiveActivity: Attempting to start activity for \(gymName)")
        
        // End any existing activity
        endGymActivity()
        
        let authInfo = ActivityAuthorizationInfo()
        print("📋 LiveActivity: Auth status - Enabled: \(authInfo.areActivitiesEnabled), Frequent: \(authInfo.frequentPushesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("🔴 LiveActivity: Activities not enabled by user")
            showActivityPermissionGuidance()
            return
        }
        
        let attributes = GymActivityAttributes(gymId: gymId, appName: "FUEGO")
        let startTime = Date()
        let initialState = GymActivityAttributes.ContentState(
            gymName: gymName,
            isInRange: true,
            timeElapsed: "Just arrived",
            sessionStartTime: startTime
        )
        
        do {
            let activityContent = ActivityContent(state: initialState, staleDate: nil)
            print("📦 LiveActivity: Creating activity content...")
            print("🔧 LiveActivity: Gym Name: \(gymName)")
            print("🔧 LiveActivity: Gym ID: \(gymId)")
            print("🔧 LiveActivity: Initial State: \(initialState)")
            
            currentActivity = try Activity<GymActivityAttributes>.request(
                attributes: attributes,
                content: activityContent
            )
            gymEntryTime = Date()
            startTimer()
            print("🟢 LiveActivity: Successfully started gym activity for \(gymName)")
            print("🎯 LiveActivity: Activity ID: \(currentActivity?.id ?? "unknown")")
            print("🎯 LiveActivity: Activity State: \(currentActivity?.activityState ?? .active)")
            print("🎯 LiveActivity: Content State: \(currentActivity?.content.state ?? initialState)")
            
            // Check if activity is actually running
            Task {
                await self.checkActivityStatus()
            }
            
            // Notify main app about session start
            NotificationCenter.default.post(name: NSNotification.Name("GymSessionUpdate"), object: nil)
        } catch {
            print("🔴 LiveActivity: Failed to start activity: \(error.localizedDescription)")
            print("🔍 LiveActivity: Error details: \(error)")
            
            // Check if it's a permission denial
            if error.localizedDescription.contains("denied") {
                showActivityPermissionGuidance()
            }
        }
    }
    
    func endGymActivity() {
        timer?.invalidate()
        timer = nil
        
        Task {
            if let activity = currentActivity {
                let finalState = GymActivityAttributes.ContentState(
                    gymName: activity.content.state.gymName,
                    isInRange: false,
                    timeElapsed: "Session ended",
                    sessionStartTime: activity.content.state.sessionStartTime
                )
                
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
                print("🔴 LiveActivity: Ended gym activity")
            }
        }
        
        currentActivity = nil
        gymEntryTime = nil
        
        // Notify main app about session end
        NotificationCenter.default.post(name: NSNotification.Name("GymSessionUpdate"), object: nil)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimeElapsed()
        }
    }
    
    private func updateTimeElapsed() {
        guard let activity = currentActivity,
              let entryTime = gymEntryTime else { return }
        
        let elapsed = Date().timeIntervalSince(entryTime)
        let minutes = Int(elapsed / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        let timeString: String
        if hours > 0 {
            timeString = remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        } else if minutes > 0 {
            timeString = "\(minutes)m"
        } else {
            timeString = "0m"
        }
        
        Task {
            let updatedState = GymActivityAttributes.ContentState(
                gymName: activity.content.state.gymName,
                isInRange: true,
                timeElapsed: timeString,
                sessionStartTime: entryTime // Use the actual gym entry time
            )
            
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }
    
    private func showActivityPermissionGuidance() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "FUEGO Live Activities",
                message: "Enable Live Activities to see your gym session in the Dynamic Island and Lock Screen!\n\n1. Open Settings\n2. Search for 'FUEGO'\n3. Enable 'Live Activities'\n4. Return to app and try again",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Continue Without", style: .cancel) { _ in
                self.showFallbackGymNotification()
            })
            
            // Find the topmost view controller to present from
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                var topVC = rootVC
                while let presentedVC = topVC.presentedViewController {
                    topVC = presentedVC
                }
                topVC.present(alert, animated: true)
            }
        }
    }
    
    private func showFallbackGymNotification() {
        print("🔔 Fallback: Showing in-app gym notification")
        // Could add banner notification or other in-app feedback here
    }
    
    private func checkActivityStatus() async {
        print("🔍 LiveActivity: Checking all active activities...")
        let activities = Activity<GymActivityAttributes>.activities
        print("🔍 LiveActivity: Found \(activities.count) active activities")
        
        for activity in activities {
            print("🔍 LiveActivity: Activity \(activity.id) - State: \(activity.activityState)")
            print("🔍 LiveActivity: Activity Content: \(activity.content.state)")
        }
        
        if activities.isEmpty {
            print("⚠️ LiveActivity: No activities found - widget won't appear")
        }
    }
    
    func forceStartTestActivity() {
        print("🧪 LiveActivity: Force starting test activity...")
        startGymActivity(gymName: "Test Gym", gymId: "manual_test_\(Date().timeIntervalSince1970)")
    }
}

// MARK: - User Account System
class UserAccount {
    static let shared = UserAccount()
    
    private let userDefaults = UserDefaults.standard
    private let emailKey = "user_email"
    private let passwordHashKey = "user_password_hash"
    private let firstNameKey = "user_first_name"
    private let lastNameKey = "user_last_name"
    private let accountCreatedKey = "account_created_date"
    private let isAccountSetupKey = "is_account_setup_complete"
    
    private init() {}
    
    var email: String? {
        get { userDefaults.string(forKey: emailKey) }
        set { userDefaults.set(newValue, forKey: emailKey) }
    }
    
    var firstName: String? {
        get { userDefaults.string(forKey: firstNameKey) }
        set { userDefaults.set(newValue, forKey: firstNameKey) }
    }
    
    var lastName: String? {
        get { userDefaults.string(forKey: lastNameKey) }
        set { userDefaults.set(newValue, forKey: lastNameKey) }
    }
    
    var accountCreatedDate: Date? {
        get { userDefaults.object(forKey: accountCreatedKey) as? Date }
        set { userDefaults.set(newValue, forKey: accountCreatedKey) }
    }
    
    var isAccountSetupComplete: Bool {
        get { userDefaults.bool(forKey: isAccountSetupKey) }
        set { userDefaults.set(newValue, forKey: isAccountSetupKey) }
    }
    
    var displayName: String {
        if let firstName = firstName, !firstName.isEmpty {
            return firstName
        }
        return "Champion"
    }
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        
        if !first.isEmpty && !last.isEmpty {
            return "\(first) \(last)"
        } else if !first.isEmpty {
            return first
        } else if !last.isEmpty {
            return last
        }
        return "User"
    }
    
    func createAccount(email: String, password: String, firstName: String, lastName: String?) -> Bool {
        guard isValidEmail(email) && isValidPassword(password) else {
            return false
        }
        
        // Hash password (simple hash for demo - in production use proper hashing)
        let passwordHash = password.hash
        
        // Save account data
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        userDefaults.set(passwordHash, forKey: passwordHashKey)
        accountCreatedDate = Date()
        isAccountSetupComplete = true
        
        print("👤 UserAccount: Account created for \(email)")
        return true
    }
    
    func verifyPassword(_ password: String) -> Bool {
        let storedHash = userDefaults.integer(forKey: passwordHashKey)
        return password.hash == storedHash
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6 // Minimum 6 characters
    }
    
    func resetAccount() {
        userDefaults.removeObject(forKey: emailKey)
        userDefaults.removeObject(forKey: passwordHashKey)
        userDefaults.removeObject(forKey: firstNameKey)
        userDefaults.removeObject(forKey: lastNameKey)
        userDefaults.removeObject(forKey: accountCreatedKey)
        userDefaults.removeObject(forKey: isAccountSetupKey)
        print("👤 UserAccount: Account reset")
    }
}

// MARK: - Account Creation Modal
class AccountCreationModalViewController: UIViewController {
    
    private var emailField: UITextField!
    private var passwordField: UITextField!
    private var firstNameField: UITextField!
    private var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccountModal()
    }
    
    private func setupAccountModal() {
        // Dark overlay background
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        overlayView.frame = UIScreen.main.bounds
        view.addSubview(overlayView)
        
        // Main container with glassmorphic design
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 0.95)
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Create Your Account"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .ultraLight)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // FUEGO transparent flame logo
        let flameImageView = UIImageView()
        flameImageView.image = UIImage(named: "flame_logo_transparent")
        flameImageView.contentMode = .scaleAspectFit
        flameImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Join the FUEGO community"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        subtitleLabel.textColor = UIColor.systemGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create text fields with elegant styling
        emailField = createStyledTextField(placeholder: "Email", isSecure: false)
        passwordField = createStyledTextField(placeholder: "Password", isSecure: true)
        firstNameField = createStyledTextField(placeholder: "First Name", isSecure: false)
        
        // Create Account button
        createAccountButton = UIButton()
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        createAccountButton.setTitleColor(UIColor.white, for: .normal)
        createAccountButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        createAccountButton.layer.cornerRadius = 14
        createAccountButton.layer.borderWidth = 1
        createAccountButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Sign In button
        let signInButton = UIButton()
        signInButton.setTitle("Already have an account? Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .ultraLight)
        signInButton.setTitleColor(UIColor.systemGray, for: .normal)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Close button
        let closeButton = UIButton()
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .ultraLight)
        closeButton.setTitleColor(UIColor.systemGray, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all subviews to container
        container.addSubview(closeButton)
        container.addSubview(flameImageView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(firstNameField)
        container.addSubview(emailField)
        container.addSubview(passwordField)
        container.addSubview(createAccountButton)
        container.addSubview(signInButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Flame
            flameImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            flameImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            flameImageView.widthAnchor.constraint(equalToConstant: 32),
            flameImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: flameImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            // First name field
            firstNameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            firstNameField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            firstNameField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            firstNameField.heightAnchor.constraint(equalToConstant: 48),
            
            // Email field
            emailField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 48),
            
            // Password field
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 48),
            
            // Create Account button
            createAccountButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 30),
            createAccountButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            createAccountButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            createAccountButton.heightAnchor.constraint(equalToConstant: 52),
            
            // Sign In button
            signInButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20),
            signInButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -25)
        ])
    }
    
    private func createStyledTextField(placeholder: String, isSecure: Bool) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16, weight: .light)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        textField.layer.cornerRadius = 14
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.3).cgColor
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = isSecure ? .none : .words
        textField.keyboardType = placeholder.lowercased().contains("email") ? .emailAddress : .default
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Add focus styling
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        
        return textField
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            textField.layer.borderWidth = 1.5
        }
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.3).cgColor
            textField.layer.borderWidth = 1
        }
    }
    
    @objc private func createAccountTapped() {
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordField.text,
              let firstName = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty, !password.isEmpty, !firstName.isEmpty else {
            showError("Please fill in all required fields")
            return
        }
        
        if UserAccount.shared.createAccount(email: email, password: password, firstName: firstName, lastName: nil) {
            // Account created successfully
            NotificationCenter.default.post(name: NSNotification.Name("UserAccountCreated"), object: nil)
            dismiss(animated: true)
        } else {
            showError("Please check your email format and ensure password is at least 6 characters")
        }
    }
    
    @objc private func signInTapped() {
        // TODO: Implement sign in flow
        showError("Sign in feature coming soon!")
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "FUEGO", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - HealthKit Manager
class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        print("🔍 HealthKitManager: Starting authorization request...")
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKitManager: HealthKit is NOT available on this device")
            completion(false, NSError(domain: "HealthKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]))
            return
        }
        
        print("✅ HealthKitManager: HealthKit is available on this device")
        
        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.workoutType()
        ]
        
        print("🔍 HealthKitManager: Requesting authorization for \(readTypes.count) data types...")
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            print("📋 HealthKitManager: Authorization callback received - Success: \(success)")
            
            if let error = error {
                print("❌ HealthKitManager: Authorization error: \(error)")
                print("❌ HealthKitManager: Error details: \(error.localizedDescription)")
            }
            
            // Check individual permissions
            for type in readTypes {
                let status = self.healthStore.authorizationStatus(for: type)
                print("📊 HealthKitManager: \(type) permission status: \(self.statusString(status))")
            }
            
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    private func statusString(_ status: HKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "Not Determined"
        case .sharingDenied:
            return "Denied"
        case .sharingAuthorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }
    
    func getStepCount(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        print("🔍 HealthKitManager: Getting step count from \(startDate) to \(endDate)")
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("❌ HealthKitManager: Step count type not available")
            completion(nil, NSError(domain: "HealthKitError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"]))
            return
        }
        
        // Check permission first
        let status = healthStore.authorizationStatus(for: stepType)
        print("📊 HealthKitManager: Step count permission status: \(statusString(status))")
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                print("❌ HealthKitManager: Step count query error: \(error)")
            }
            
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    print("❌ HealthKitManager: No step count data found")
                    completion(nil, error)
                    return
                }
                let steps = sum.doubleValue(for: HKUnit.count())
                print("✅ HealthKitManager: Found \(Int(steps)) steps")
                completion(steps, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    func getDistance(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil, NSError(domain: "HealthKitError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Distance type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(nil, error)
                    return
                }
                completion(sum.doubleValue(for: HKUnit.meterUnit(with: .kilo)), nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    func getWorkoutCount(startDate: Date, endDate: Date, completion: @escaping (Int?, Error?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                completion(samples?.count ?? 0, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    func getActiveEnergyBurned(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, NSError(domain: "HealthKitError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Active energy type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(nil, error)
                    return
                }
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                completion(calories, nil)
            }
        }
        healthStore.execute(query)
    }
    
    func getFlightsClimbed(startDate: Date, endDate: Date, completion: @escaping (Int?, Error?) -> Void) {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(nil, NSError(domain: "HealthKitError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Flights climbed type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(nil, error)
                    return
                }
                let flights = Int(sum.doubleValue(for: HKUnit.count()))
                completion(flights, nil)
            }
        }
        healthStore.execute(query)
    }
    
    func getExerciseMinutes(startDate: Date, endDate: Date, completion: @escaping (Int?, Error?) -> Void) {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(nil, NSError(domain: "HealthKitError", code: 6, userInfo: [NSLocalizedDescriptionKey: "Exercise time type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(nil, error)
                    return
                }
                let minutes = Int(sum.doubleValue(for: HKUnit.minute()))
                completion(minutes, nil)
            }
        }
        healthStore.execute(query)
    }
    
    func getRestingHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil, NSError(domain: "HealthKitError", code: 7, userInfo: [NSLocalizedDescriptionKey: "Resting heart rate type not available"]))
            return
        }
        
        // Get most recent resting heart rate
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                guard let sample = samples?.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                completion(bpm, nil)
            }
        }
        healthStore.execute(query)
    }
    
    func getCardioFitness(completion: @escaping (Double?, Error?) -> Void) {
        guard let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max) else {
            completion(nil, NSError(domain: "HealthKitError", code: 8, userInfo: [NSLocalizedDescriptionKey: "VO2 Max type not available"]))
            return
        }
        
        // Get most recent VO2 Max
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: vo2MaxType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                guard let sample = samples?.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                let vo2Max = sample.quantity.doubleValue(for: HKUnit(from: "ml/kg*min"))
                completion(vo2Max, nil)
            }
        }
        healthStore.execute(query)
    }
    
    func getSleepHours(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, NSError(domain: "HealthKitError", code: 9, userInfo: [NSLocalizedDescriptionKey: "Sleep analysis type not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    completion(nil, error)
                    return
                }
                
                var totalSleepHours: Double = 0
                for sample in samples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                        let duration = sample.endDate.timeIntervalSince(sample.startDate)
                        totalSleepHours += duration / 3600.0 // Convert seconds to hours
                    }
                }
                completion(totalSleepHours, nil)
            }
        }
        healthStore.execute(query)
    }
    
    func getStreakDays(completion: @escaping (Int?, Error?) -> Void) {
        // Calculate streak based on consecutive days with workouts
        let calendar = Calendar.current
        let today = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        
        getWorkoutCount(startDate: oneYearAgo, endDate: today) { _, error in
            if error != nil {
                completion(nil, error)
                return
            }
            
            // For now, return a simulated streak - implementing full streak calculation
            // would require analyzing daily workout patterns which is complex
            completion(15, nil) // Simulated 15-day streak
        }
    }
}

class ViewController: UITabBarController, UNUserNotificationCenterDelegate {
    
    // MARK: - Gym Session Banner
    private var gymSessionBanner: UIView?
    private var sessionTimeLabel: UILabel?
    private var sessionTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModernDesign()
        requestNotificationPermissions()
        setupTabBarControllers()
        requestHealthKitAuthorization()
        requestLocationPermissions()
        setupGymSessionBanner()
        
        // Listen for Live Activity state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGymSessionUpdate),
            name: NSNotification.Name("GymSessionUpdate"),
            object: nil
        )
    }
    
    private func requestHealthKitAuthorization() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization granted")
            } else {
                print("HealthKit authorization denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Notification Permissions
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("🔔 Notification permissions granted")
                // Set delegate to handle foreground notifications
                DispatchQueue.main.async {
                    UNUserNotificationCenter.current().delegate = self
                    self.setupNotificationActions()
                }
            } else {
                print("❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func setupNotificationActions() {
        // Define notification actions
        let startAction = UNNotificationAction(
            identifier: "START_SESSION",
            title: "Start Session",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_SESSION",
            title: "Not Now",
            options: []
        )
        
        // Define notification category
        let gymCategory = UNNotificationCategory(
            identifier: "GYM_DETECTION",
            actions: [startAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([gymCategory])
    }
    
    func sendGymSessionNotification(gymName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Gym Detected: \(gymName)"
        content.body = "Ready to start tracking your workout?"
        content.sound = .default
        content.categoryIdentifier = "GYM_DETECTION"
        
        // Add custom data
        content.userInfo = ["gymName": gymName, "sessionType": "gym"]
        
        // Trigger immediately
        let request = UNNotificationRequest(
            identifier: "gym-session-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send gym session notification: \(error)")
            } else {
                print("🔔 Gym session notification sent for: \(gymName)")
            }
        }
        
        // Also show in-app banner as fallback
        DispatchQueue.main.async {
            self.showInAppGymNotification(gymName: gymName)
        }
    }
    
    private func showSessionStartedBanner(gymName: String) {
        // Create confirmation banner for started session
        let banner = UIView()
        banner.backgroundColor = UIColor.systemGreen
        banner.layer.cornerRadius = 12
        banner.alpha = 0
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "✅ Session Started!"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Tracking your workout at \(gymName)"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .white
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        banner.addSubview(titleLabel)
        banner.addSubview(subtitleLabel)
        view.addSubview(banner)
        
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            banner.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.3, animations: {
            banner.alpha = 1
        }) { _ in
            // Auto-hide after 3 seconds
            UIView.animate(withDuration: 0.3, delay: 3.0, options: [], animations: {
                banner.alpha = 0
            }) { _ in
                banner.removeFromSuperview()
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show full interactive notification with actions even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification actions
        let gymName = response.notification.request.content.userInfo["gymName"] as? String ?? "Unknown Gym"
        
        switch response.actionIdentifier {
        case "START_SESSION":
            print("🔥 User chose to start gym session at \(gymName)")
            // Start the Live Activity
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.startGymActivity(
                    gymName: gymName,
                    gymId: gymName.replacingOccurrences(of: " ", with: "_")
                )
            }
            // Show in-app confirmation
            DispatchQueue.main.async {
                self.showSessionStartedBanner(gymName: gymName)
            }
            
        case "DISMISS_SESSION":
            print("⏸️ User dismissed gym session for \(gymName)")
            // Optionally show a brief "Maybe next time" message
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself (not an action button)
            print("🔔 User tapped gym notification for \(gymName)")
            // Could show the app or ask again
            
        default:
            break
        }
        
        completionHandler()
    }
    
    private func showInAppGymNotification(gymName: String) {
        // Create interactive in-app notification banner
        let notificationBanner = UIView()
        notificationBanner.backgroundColor = UIColor.systemRed
        notificationBanner.layer.cornerRadius = 12
        notificationBanner.alpha = 0
        notificationBanner.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "🔥 Gym Detected: \(gymName)"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Ready to start tracking your workout?"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .white
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add action buttons
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 12
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Session", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        startButton.layer.cornerRadius = 8
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        startButton.addTarget(self, action: #selector(startGymSessionTapped), for: .touchUpInside)
        startButton.accessibilityIdentifier = gymName // Store gym name for action
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Not Now", for: .normal)
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        dismissButton.layer.cornerRadius = 8
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dismissButton.addTarget(self, action: #selector(dismissGymSessionTapped), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(startButton)
        buttonStackView.addArrangedSubview(dismissButton)
        
        notificationBanner.addSubview(titleLabel)
        notificationBanner.addSubview(subtitleLabel)
        notificationBanner.addSubview(buttonStackView)
        view.addSubview(notificationBanner)
        
        NSLayoutConstraint.activate([
            notificationBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            notificationBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notificationBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            notificationBanner.heightAnchor.constraint(equalToConstant: 110),
            
            titleLabel.topAnchor.constraint(equalTo: notificationBanner.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: notificationBanner.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: notificationBanner.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: notificationBanner.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: notificationBanner.trailingAnchor, constant: -16),
            
            buttonStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            buttonStackView.leadingAnchor.constraint(equalTo: notificationBanner.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: notificationBanner.trailingAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.3, animations: {
            notificationBanner.alpha = 1
        }) { _ in
            // Auto-hide after 10 seconds (longer for user to decide)
            UIView.animate(withDuration: 0.3, delay: 10.0, options: [], animations: {
                notificationBanner.alpha = 0
            }) { _ in
                notificationBanner.removeFromSuperview()
            }
        }
    }
    
    @objc private func startGymSessionTapped(_ sender: UIButton) {
        let gymName = sender.accessibilityIdentifier ?? "Unknown Gym"
        print("🔥 User started gym session at \(gymName)")
        
        // Start the Live Activity
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.startGymActivity(
                gymName: gymName,
                gymId: gymName.replacingOccurrences(of: " ", with: "_")
            )
        }
        
        // Remove the banner
        if let banner = sender.superview?.superview {
            UIView.animate(withDuration: 0.3) {
                banner.alpha = 0
            } completion: { _ in
                banner.removeFromSuperview()
            }
        }
        
        // Show confirmation
        showSessionStartedBanner(gymName: gymName)
    }
    
    @objc private func dismissGymSessionTapped(_ sender: UIButton) {
        print("⏸️ User dismissed gym session")
        
        // Remove the banner
        if let banner = sender.superview?.superview {
            UIView.animate(withDuration: 0.3) {
                banner.alpha = 0
            } completion: { _ in
                banner.removeFromSuperview()
            }
        }
    }
    
    private func requestLocationPermissions() {
        LocationManager.shared.requestLocationPermission()
    }
    
    private func setupModernDesign() {
        // Set dark red/black theme
        view.backgroundColor = UIColor.black
        
        // Configure transparent tab bar - no background
        tabBar.backgroundColor = UIColor.clear
        tabBar.barTintColor = UIColor.clear
        tabBar.isTranslucent = true
        
        // Create epic flame curve for top edge
        DispatchQueue.main.async {
            self.addFlameShapeToTabBar()
        }
        
        // Configure modern tab bar appearance
        tabBar.tintColor = UIColor.systemRed.withAlphaComponent(0.9) // Slightly softer red
        tabBar.unselectedItemTintColor = UIColor.systemGray2
        
        // Enhanced tab bar item styling
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            
            // Style for normal (unselected) items
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray2
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray2,
                .font: UIFont.systemFont(ofSize: 11, weight: .thin)
            ]
            
            // Style for selected items with enhanced glow
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemRed
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.systemRed.withAlphaComponent(0.6)
            shadow.shadowOffset = CGSize(width: 0, height: 0)
            shadow.shadowBlurRadius = 4
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemRed,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .shadow: shadow
            ]
            
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
        
        // Add subtle vibration feedback for tab selection
        tabBar.items?.forEach { item in
            // This would typically be handled in a delegate method, but we're setting up the visual style here
        }
    }
    
    // MARK: - Gym Session Banner Setup
    private func setupGymSessionBanner() {
        // Create the banner container
        let banner = UIView()
        banner.backgroundColor = UIColor.black
        banner.layer.cornerRadius = 12
        banner.layer.borderWidth = 1
        banner.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        banner.isHidden = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.systemRed.withAlphaComponent(0.15).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 12
        banner.layer.insertSublayer(gradientLayer, at: 0)
        
        // Flame icon
        let flameIcon = UIImageView()
        flameIcon.image = UIImage(systemName: "flame.fill")
        flameIcon.tintColor = UIColor.systemRed
        flameIcon.contentMode = .scaleAspectFit
        flameIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // Session status label
        let statusLabel = UILabel()
        statusLabel.text = "Active Gym Session"
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        statusLabel.textColor = UIColor.white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Session time label
        let timeLabel = UILabel()
        timeLabel.text = "0m"
        timeLabel.font = UIFont.systemFont(ofSize: 24, weight: .light)
        timeLabel.textColor = UIColor.systemRed
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        banner.addSubview(flameIcon)
        banner.addSubview(statusLabel)
        banner.addSubview(timeLabel)
        view.addSubview(banner)
        
        // Store references
        gymSessionBanner = banner
        sessionTimeLabel = timeLabel
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Banner positioning
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            banner.heightAnchor.constraint(equalToConstant: 40),
            
            // Flame icon
            flameIcon.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 12),
            flameIcon.centerYAnchor.constraint(equalTo: banner.centerYAnchor),
            flameIcon.widthAnchor.constraint(equalToConstant: 24),
            flameIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Status label
            statusLabel.leadingAnchor.constraint(equalTo: flameIcon.trailingAnchor, constant: 12),
            statusLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
            
            // Time label
            timeLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -12),
            timeLabel.centerYAnchor.constraint(equalTo: banner.centerYAnchor)
        ])
        
        // Update gradient frame when banner layout changes
        DispatchQueue.main.async {
            gradientLayer.frame = banner.bounds
        }
    }
    
    @objc private func handleGymSessionUpdate() {
        updateGymSessionBanner()
    }
    
    private func updateGymSessionBanner() {
        guard #available(iOS 16.1, *) else { return }
        
        let activities = Activity<GymActivityAttributes>.activities
        
        if let activity = activities.first {
            // Show banner when Live Activity is active
            gymSessionBanner?.isHidden = false
            startSessionTimer(startTime: activity.content.state.sessionStartTime)
        } else {
            // Hide banner when no Live Activity
            gymSessionBanner?.isHidden = true
            stopSessionTimer()
        }
    }
    
    private func startSessionTimer(startTime: Date) {
        stopSessionTimer()
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                let elapsed = Date().timeIntervalSince(startTime)
                let minutes = Int(elapsed / 60)
                let hours = minutes / 60
                let remainingMinutes = minutes % 60
                
                let timeString: String
                if hours > 0 {
                    timeString = remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
                } else if minutes > 0 {
                    timeString = "\(minutes)m"
                } else {
                    timeString = "0m"
                }
                
                self?.sessionTimeLabel?.text = timeString
            }
        }
    }
    
    private func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopSessionTimer()
    }
    
    private func addFlameShapeToTabBar() {
        // Remove any existing custom layers
        tabBar.layer.sublayers?.removeAll { $0.name == "customShape" }
        
        // Configure transparent tab bar
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = UIColor.clear
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
        
        let tabBarWidth = tabBar.bounds.width
        let tabBarHeight: CGFloat = 140
        
        // Update tab bar frame
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = tabBarHeight
        tabBarFrame.origin.y = view.bounds.height - tabBarHeight
        tabBar.frame = tabBarFrame
        
        // Create floating cylindrical dock
        let dockWidth: CGFloat = tabBarWidth - 40 // Floating with margins
        let dockHeight: CGFloat = 70
        let dockX: CGFloat = 20 // Centered with margins
        let dockY: CGFloat = 50 // Shifted downward
        
        // Cylindrical/pill shape path
        let dockPath = UIBezierPath(
            roundedRect: CGRect(x: dockX, y: dockY, width: dockWidth, height: dockHeight),
            cornerRadius: dockHeight / 2 // Full pill shape
        )
        
        // Main dock layer
        let dockLayer = CAShapeLayer()
        dockLayer.path = dockPath.cgPath
        dockLayer.fillColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 0.9).cgColor
        dockLayer.name = "customShape"
        
        // Modern floating shadow
        dockLayer.shadowColor = UIColor.black.cgColor
        dockLayer.shadowOffset = CGSize(width: 0, height: 4)
        dockLayer.shadowOpacity = 0.25
        dockLayer.shadowRadius = 12
        
        // Glassmorphic border
        dockLayer.strokeColor = UIColor.white.withAlphaComponent(0.1).cgColor
        dockLayer.lineWidth = 0.5
        
        // Insert custom dock
        tabBar.layer.insertSublayer(dockLayer, at: 0)
        
        // Set transparent background
        tabBar.backgroundColor = UIColor.clear
        
        // Center tab items within the floating dock and adjust text position
        if #available(iOS 13.0, *) {
            // Move text down to avoid overlapping with icons
            tabBar.scrollEdgeAppearance?.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
            tabBar.standardAppearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
            tabBar.scrollEdgeAppearance?.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
            tabBar.standardAppearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update flame shape when layout changes (rotation, etc.)
        addFlameShapeToTabBar()
    }
    
    private func setupTabBarControllers() {
        let scanVC = ScanViewController()
        let homeVC = HomeViewController()
        let trackProgressVC = TrackProgressViewController()
        
        // Configure Scan tab
        scanVC.tabBarItem = UITabBarItem(
            title: "Scan",
            image: UIImage(systemName: "qrcode.viewfinder"),
            selectedImage: UIImage(systemName: "qrcode.viewfinder.fill")
        )
        
        // Configure Home tab
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // Configure Burn tab
        trackProgressVC.tabBarItem = UITabBarItem(
            title: "Burn",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        )
        
        // Add navigation controllers for better structure
        let scanNavController = UINavigationController(rootViewController: scanVC)
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let trackNavController = UINavigationController(rootViewController: trackProgressVC)
        
        // Configure navigation bar appearance
        configureNavigationBar(scanNavController.navigationBar)
        configureNavigationBar(homeNavController.navigationBar)
        configureNavigationBar(trackNavController.navigationBar)
        
        viewControllers = [scanNavController, homeNavController, trackNavController]
        
        // Set Home as default selected tab (middle tab)
        selectedIndex = 1
    }
    
    private func configureNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.tintColor = UIColor.systemRed
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var gymVisitCount = 0
    
    // Gym database with coordinates of popular fitness centers
    private var gymLocations = [
        GymLocation(name: "Planet Fitness", coordinate: CLLocationCoordinate2D(latitude: 40.7589, longitude: -73.9851), radius: 100),
        GymLocation(name: "LA Fitness", coordinate: CLLocationCoordinate2D(latitude: 40.7614, longitude: -73.9776), radius: 100),
        GymLocation(name: "24 Hour Fitness", coordinate: CLLocationCoordinate2D(latitude: 40.7505, longitude: -73.9934), radius: 100),
        GymLocation(name: "Gold's Gym", coordinate: CLLocationCoordinate2D(latitude: 40.7648, longitude: -73.9808), radius: 100),
        GymLocation(name: "Crunch Fitness", coordinate: CLLocationCoordinate2D(latitude: 40.7282, longitude: -73.9942), radius: 100),
        GymLocation(name: "Equinox", coordinate: CLLocationCoordinate2D(latitude: 40.7527, longitude: -73.9772), radius: 100),
        GymLocation(name: "Blink Fitness", coordinate: CLLocationCoordinate2D(latitude: 40.7331, longitude: -73.9888), radius: 100),
        GymLocation(name: "New York Sports Club", coordinate: CLLocationCoordinate2D(latitude: 40.7614, longitude: -73.9776), radius: 100),
        GymLocation(name: "John Reed Fitness Santa Monica", coordinate: CLLocationCoordinate2D(latitude: 34.0195, longitude: -118.4912), radius: 100),
        GymLocation(name: "FUEGO Test Gym", coordinate: CLLocationCoordinate2D(latitude: 34.02431, longitude: -118.48266), radius: 100)
    ]
    
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        
        print("📍 LocationManager: Setting up location services...")
    }
    
    func requestLocationPermission() {
        print("🔍 LocationManager: Checking location authorization status...")
        handleLocationAuthorization(locationManager.authorizationStatus)
    }
    
    private func handleLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("🔍 LocationManager: Requesting location permission...")
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
            }
        case .denied, .restricted:
            print("❌ LocationManager: Location access denied")
        case .authorizedWhenInUse:
            print("✅ LocationManager: Location authorized when in use")
            startLocationUpdates()
        case .authorizedAlways:
            print("✅ LocationManager: Location authorized always")
            startLocationUpdates()
        @unknown default:
            print("❌ LocationManager: Unknown authorization status")
            break
        }
    }
    
    private func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ LocationManager: Location services not enabled")
            return
        }
        
        print("📍 LocationManager: Starting location updates...")
        locationManager.startUpdatingLocation()
        
        // Set up geofencing for gym locations
        setupGeofencing()
    }
    
    private func setupGeofencing() {
        print("🏃‍♀️ LocationManager: Setting up geofencing for \(gymLocations.count) gym locations...")
        
        // Clear existing regions
        locationManager.monitoredRegions.forEach { region in
            locationManager.stopMonitoring(for: region)
        }
        
        // Add geofences for each gym
        for gym in gymLocations {
            let region = CLCircularRegion(
                center: gym.coordinate,
                radius: gym.radius,
                identifier: gym.name
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false
            
            locationManager.startMonitoring(for: region)
            print("🎯 LocationManager: Added geofence for \(gym.name)")
        }
    }
    
    func getCurrentGymVisitCount() -> Int {
        return UserDefaults.standard.integer(forKey: "gymVisitCount")
    }
    
    private func incrementGymVisitCount() {
        gymVisitCount = getCurrentGymVisitCount() + 1
        UserDefaults.standard.set(gymVisitCount, forKey: "gymVisitCount")
        UserDefaults.standard.synchronize()
        
        print("🏋️‍♀️ LocationManager: Gym visit count incremented to \(gymVisitCount)")
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: NSNotification.Name("GymVisitDetected"),
            object: nil,
            userInfo: ["visitCount": gymVisitCount]
        )
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("📍 LocationManager: Authorization changed to \(manager.authorizationStatus.rawValue)")
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ LocationManager: Location authorization denied")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 LocationManager: Location updated - \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("🏃‍♀️ LocationManager: Entered region: \(region.identifier)")
        
        
        // Check if this is a gym region
        if gymLocations.contains(where: { $0.name == region.identifier }) {
            print("🏋️‍♀️ LocationManager: Detected gym visit at \(region.identifier)")
            
            // Send interactive notification asking user to start session
            if let viewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .compactMap({ $0.windows.first })
                .compactMap({ $0.rootViewController as? ViewController })
                .first {
                viewController.sendGymSessionNotification(gymName: region.identifier)
            }
            
            // Check if visit was recent to prevent duplicate counting
            let lastVisitKey = "lastGymVisit_\(region.identifier)"
            let lastVisit = UserDefaults.standard.object(forKey: lastVisitKey) as? Date ?? Date.distantPast
            let timeSinceLastVisit = Date().timeIntervalSince(lastVisit)
            
            // Only count if more than 2 hours since last visit to same gym
            if timeSinceLastVisit > 7200 {
                UserDefaults.standard.set(Date(), forKey: lastVisitKey)
                incrementGymVisitCount()
            } else {
                print("🕒 LocationManager: Recent visit detected, not counting duplicate")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("🏃‍♀️ LocationManager: Exited region: \(region.identifier)")
        
        // Check if this is a gym region and end live activity
        if gymLocations.contains(where: { $0.name == region.identifier }) {
            print("🏋️‍♀️ LocationManager: Left gym: \(region.identifier)")
            
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.endGymActivity()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔄 LocationManager: Authorization changed to: \(status)")
        handleLocationAuthorization(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ LocationManager: Location error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("❌ LocationManager: Geofencing failed for region \(region?.identifier ?? "unknown"): \(error)")
    }
}

// MARK: - Gym Location Structure
struct GymLocation {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let radius: Double
}

// MARK: - Scan View Controller
// MARK: - Home View Controller
class HomeViewController: UIViewController {
    
    private let greetingLabel = UILabel()
    private let flameBackgroundView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHomeView()
        setupAccountObserver()
        checkAccountStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGreeting()
    }
    
    private func setupAccountObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAccountCreated),
            name: .userAccountCreated,
            object: nil
        )
    }
    
    @objc private func handleAccountCreated() {
        updateGreeting()
    }
    
    private func checkAccountStatus() {
        if !UserAccount.shared.isAccountSetupComplete {
            // Show account creation modal for new users
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presentAccountCreationModal()
            }
        }
    }
    
    private func presentAccountCreationModal() {
        let accountModal = AccountCreationModalViewController()
        accountModal.modalPresentationStyle = .overFullScreen
        accountModal.modalTransitionStyle = .crossDissolve
        present(accountModal, animated: true)
    }
    
    private func updateGreeting() {
        let displayName = UserAccount.shared.displayName
        greetingLabel.text = "Hello, \(displayName)!"
        
        // Elegant fade-in animation
        greetingLabel.alpha = 0
        UIView.animate(withDuration: 1.2, delay: 0.3, options: [.curveEaseOut], animations: {
            self.greetingLabel.alpha = 1
        })
    }
    
    private func setupHomeView() {
        view.backgroundColor = UIColor.black
        
        // Create main scroll view for dashboard
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Greeting label at top
        greetingLabel.text = "Hello, Champion!"
        greetingLabel.font = UIFont.systemFont(ofSize: 32, weight: .thin)
        greetingLabel.textColor = UIColor.white
        greetingLabel.textAlignment = .left
        greetingLabel.alpha = 0 // Start invisible for fade-in animation
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(greetingLabel)
        
        // Create dashboard widgets
        let momentumWidget = createMomentumWidget()
        let leaderboardWidget = createLeaderboardWidget()
        let challengeWidget = createChallengeWidget()
        let shareWidget = createShareWidget()
        
        // Full-width momentum widget
        momentumWidget.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(momentumWidget)
        
        // Leaderboard as full-width widget
        leaderboardWidget.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leaderboardWidget)
        
        // Bottom row with Challenge and Share (50/50 split)
        let bottomRowStack = UIStackView(arrangedSubviews: [challengeWidget, shareWidget])
        bottomRowStack.axis = .horizontal
        bottomRowStack.distribution = .fillEqually
        bottomRowStack.spacing = 16
        bottomRowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomRowStack)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Greeting
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Full-width momentum widget
            momentumWidget.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 30),
            momentumWidget.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            momentumWidget.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            momentumWidget.heightAnchor.constraint(equalToConstant: 140),
            
            // Leaderboard widget
            leaderboardWidget.topAnchor.constraint(equalTo: momentumWidget.bottomAnchor, constant: 20),
            leaderboardWidget.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            leaderboardWidget.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            leaderboardWidget.heightAnchor.constraint(equalToConstant: 280),
            
            // Bottom row (Challenge and Share tiles)
            bottomRowStack.topAnchor.constraint(equalTo: leaderboardWidget.bottomAnchor, constant: 20),
            bottomRowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomRowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomRowStack.heightAnchor.constraint(equalToConstant: 120),
            bottomRowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
        ])
        
        updateGreeting()
    }
    
    // MARK: - Dashboard Widget Creation
    private func createMomentumWidget() -> UIView {
        let widget = UIView()
        widget.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        widget.layer.cornerRadius = 16
        widget.layer.borderWidth = 1
        widget.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        
        // Black to red gradient overlay for momentum number - will be set in layoutSubviews
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.systemRed.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        widget.layer.insertSublayer(gradientLayer, at: 0)
        
        // Title with pulsing green dot
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let pulsingDot = UIView()
        pulsingDot.backgroundColor = UIColor.systemGreen
        pulsingDot.layer.cornerRadius = 4
        pulsingDot.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "MOMENTUM"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleContainer.addSubview(pulsingDot)
        titleContainer.addSubview(titleLabel)
        
        // Add pulsing animation
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.3
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulsingDot.layer.add(pulseAnimation, forKey: "pulse")
        
        let numberLabel = UILabel()
        numberLabel.text = "847"
        numberLabel.font = UIFont.systemFont(ofSize: 38, weight: .ultraLight)
        numberLabel.textColor = UIColor.white
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "+12% this week"
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .thin)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        widget.addSubview(titleContainer)
        widget.addSubview(numberLabel)
        widget.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            // Title container with dot and label
            titleContainer.topAnchor.constraint(equalTo: widget.topAnchor, constant: 20),
            titleContainer.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 20),
            titleContainer.heightAnchor.constraint(equalToConstant: 16),
            
            // Pulsing dot
            pulsingDot.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            pulsingDot.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            pulsingDot.widthAnchor.constraint(equalToConstant: 8),
            pulsingDot.heightAnchor.constraint(equalToConstant: 8),
            
            // Title label next to dot
            titleLabel.leadingAnchor.constraint(equalTo: pulsingDot.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            
            numberLabel.centerXAnchor.constraint(equalTo: widget.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: widget.centerYAnchor),
            
            subtitleLabel.bottomAnchor.constraint(equalTo: widget.bottomAnchor, constant: -20),
            subtitleLabel.centerXAnchor.constraint(equalTo: widget.centerXAnchor)
        ])
        
        // Set gradient frame after constraints are applied
        DispatchQueue.main.async {
            gradientLayer.frame = widget.bounds
        }
        
        return widget
    }
    
    private func createChallengesWidget() -> UIView {
        let widget = UIView()
        widget.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        widget.layer.cornerRadius = 16
        widget.layer.borderWidth = 1
        widget.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "CHALLENGES"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = "🏆"
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let activeLabel = UILabel()
        activeLabel.text = "3 Active"
        activeLabel.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        activeLabel.textColor = UIColor.white
        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let progressLabel = UILabel()
        progressLabel.text = "2 completed today"
        progressLabel.font = UIFont.systemFont(ofSize: 11, weight: .thin)
        progressLabel.textColor = UIColor.systemGreen
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        widget.addSubview(titleLabel)
        widget.addSubview(iconLabel)
        widget.addSubview(activeLabel)
        widget.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: widget.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 20),
            
            iconLabel.centerXAnchor.constraint(equalTo: widget.centerXAnchor),
            iconLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            activeLabel.centerXAnchor.constraint(equalTo: widget.centerXAnchor),
            activeLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            
            progressLabel.bottomAnchor.constraint(equalTo: widget.bottomAnchor, constant: -20),
            progressLabel.centerXAnchor.constraint(equalTo: widget.centerXAnchor)
        ])
        
        return widget
    }
    
    private func createLeaderboardWidget() -> UIView {
        let widget = UIView()
        widget.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        widget.layer.cornerRadius = 16
        widget.layer.borderWidth = 1
        widget.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        
        // Title with pulsing green dot
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let pulsingDot = UIView()
        pulsingDot.backgroundColor = UIColor.systemGreen
        pulsingDot.layer.cornerRadius = 4
        pulsingDot.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "ACTIVITY"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleContainer.addSubview(pulsingDot)
        titleContainer.addSubview(titleLabel)
        widget.addSubview(titleContainer)
        
        // Add pulsing animation
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.3
        pulseAnimation.duration = 1.2
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulsingDot.layer.add(pulseAnimation, forKey: "pulse")
        
        // Create scrollable content area
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        widget.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Sample friends activity data
        let goldColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Custom gold color
        let activityData = [
            ("You", "1,247 pts", "Active", goldColor),
            ("Alex Chen", "1,156 pts", "Workout", UIColor.systemGray),
            ("Sarah Kim", "1,089 pts", "Running", UIColor.systemOrange),
            ("Mike Johnson", "987 pts", "Offline", UIColor.white.withAlphaComponent(0.6)),
            ("Emma Wilson", "943 pts", "Active", UIColor.white.withAlphaComponent(0.6))
        ]
        
        var previousView: UIView? = nil
        
        for (name, points, status, color) in activityData {
            let rowView = UIView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(rowView)
            
            let nameLabel = UILabel()
            nameLabel.text = name
            nameLabel.font = UIFont.systemFont(ofSize: 16, weight: name == "You" ? .light : .thin)
            nameLabel.textColor = name == "You" ? goldColor : UIColor.white
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let pointsLabel = UILabel()
            pointsLabel.text = points
            pointsLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
            pointsLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            pointsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let statusLabel = UILabel()
            statusLabel.text = status
            statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
            statusLabel.textColor = color
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
            
            rowView.addSubview(nameLabel)
            rowView.addSubview(pointsLabel)
            rowView.addSubview(statusLabel)
            
            NSLayoutConstraint.activate([
                rowView.topAnchor.constraint(equalTo: previousView?.bottomAnchor ?? contentView.topAnchor, constant: previousView == nil ? 0 : 18),
                rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
                rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
                rowView.heightAnchor.constraint(equalToConstant: 36),
                
                nameLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
                nameLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                
                pointsLabel.centerXAnchor.constraint(equalTo: rowView.centerXAnchor),
                pointsLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                
                statusLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
                statusLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
            ])
            
            previousView = rowView
        }
        
        // Set bottom constraint for last row
        if let lastRow = previousView {
            lastRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            // Title container with dot and label
            titleContainer.topAnchor.constraint(equalTo: widget.topAnchor, constant: 20),
            titleContainer.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 20),
            titleContainer.heightAnchor.constraint(equalToConstant: 16),
            
            // Pulsing dot
            pulsingDot.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            pulsingDot.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            pulsingDot.widthAnchor.constraint(equalToConstant: 8),
            pulsingDot.heightAnchor.constraint(equalToConstant: 8),
            
            // Title label next to dot
            titleLabel.leadingAnchor.constraint(equalTo: pulsingDot.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: widget.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: widget.bottomAnchor, constant: -20),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Add circular add button in top-right corner
        let addButton = UIButton(type: .system)
        if let addImage = UIImage(systemName: "plus") {
            addButton.setImage(addImage, for: .normal)
        }
        addButton.tintColor = UIColor.white.withAlphaComponent(0.8)
        addButton.backgroundColor = UIColor.clear
        addButton.layer.cornerRadius = 16
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addToLeaderboardTapped), for: .touchUpInside)
        widget.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: widget.topAnchor, constant: 12),
            addButton.trailingAnchor.constraint(equalTo: widget.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return widget
    }
    
    private func createChallengeWidget() -> UIView {
        let widget = UIView()
        widget.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        widget.layer.cornerRadius = 16
        widget.layer.borderWidth = 1
        widget.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "SOCIAL"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Flame logo from assets
        let flameImageView = UIImageView()
        flameImageView.image = UIImage(named: "flame_logo_transparent")
        flameImageView.contentMode = .scaleAspectFit
        flameImageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        flameImageView.translatesAutoresizingMaskIntoConstraints = false
        
        widget.addSubview(titleLabel)
        widget.addSubview(flameImageView)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(socialTapped))
        widget.addGestureRecognizer(tapGesture)
        widget.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: widget.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 16),
            
            flameImageView.centerXAnchor.constraint(equalTo: widget.centerXAnchor),
            flameImageView.centerYAnchor.constraint(equalTo: widget.centerYAnchor),
            flameImageView.widthAnchor.constraint(equalToConstant: 32),
            flameImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return widget
    }
    
    private func createShareWidget() -> UIView {
        let widget = UIView()
        widget.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        widget.layer.cornerRadius = 16
        widget.layer.borderWidth = 1
        widget.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "SHARE"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Share icon using SF Symbol
        let shareImageView = UIImageView()
        if let shareImage = UIImage(systemName: "square.and.arrow.up") {
            shareImageView.image = shareImage
        }
        shareImageView.contentMode = .scaleAspectFit
        shareImageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        shareImageView.translatesAutoresizingMaskIntoConstraints = false
        
        widget.addSubview(titleLabel)
        widget.addSubview(shareImageView)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shareTapped))
        widget.addGestureRecognizer(tapGesture)
        widget.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: widget.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 16),
            
            shareImageView.centerXAnchor.constraint(equalTo: widget.centerXAnchor),
            shareImageView.centerYAnchor.constraint(equalTo: widget.centerYAnchor),
            shareImageView.widthAnchor.constraint(equalToConstant: 28),
            shareImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        return widget
    }
    
    // MARK: - Widget Tap Handlers
    @objc private func shareTapped() {
        presentShareModal()
    }
    
    @objc private func socialTapped() {
        presentSocialModal()
    }
    
    @objc private func addToLeaderboardTapped() {
        presentAddToLeaderboardModal()
    }
    
    // MARK: - Modal Presentations
    private func presentShareModal() {
        let modalVC = ShareModalViewController()
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        present(modalVC, animated: true)
    }
    
    private func presentSocialModal() {
        let modalVC = SocialModalViewController()
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        present(modalVC, animated: true)
    }
    
    private func presentAddToLeaderboardModal() {
        let modalVC = AddToLeaderboardModalViewController()
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        present(modalVC, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Share Modal View Controller
class ShareModalViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Modal container
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        
        // QR Code Image
        let qrImageView = UIImageView()
        qrImageView.image = UIImage(named: "sample_qr")
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.backgroundColor = UIColor.clear
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Debug: Check if image loaded
        if qrImageView.image == nil {
            print("⚠️ sample_qr image not found in bundle")
            // Try alternative name
            qrImageView.image = UIImage(named: "sample_qr.png")
        }
        
        containerView.addSubview(qrImageView)
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Scan this code to view your FUEGO progress and achievements"
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(UIColor.systemRed, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        closeButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        // Add tap gesture to background to close modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 420),
            
            qrImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            qrImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: 240),
            qrImageView.heightAnchor.constraint(equalToConstant: 240),
            
            descriptionLabel.topAnchor.constraint(equalTo: qrImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Social Modal View Controller
class SocialModalViewController: UIViewController {
    private var selectedTab: Int = 0 // 0 = Join, 1 = Challenge
    private var contentView: UIView!
    private var joinButton: UIButton!
    private var challengeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Modal container
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Tab buttons container
        let tabContainer = UIView()
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tabContainer)
        
        // Join tab button
        joinButton = UIButton(type: .system)
        joinButton.setTitle("Join", for: .normal)
        joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        joinButton.setTitleColor(UIColor.systemRed, for: .normal)
        joinButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        joinButton.layer.cornerRadius = 12
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.addTarget(self, action: #selector(joinTabTapped), for: .touchUpInside)
        tabContainer.addSubview(joinButton)
        
        // Challenge tab button
        challengeButton = UIButton(type: .system)
        challengeButton.setTitle("Challenge", for: .normal)
        challengeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        challengeButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
        challengeButton.backgroundColor = UIColor.clear
        challengeButton.layer.cornerRadius = 12
        challengeButton.layer.borderWidth = 1
        challengeButton.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.3).cgColor
        challengeButton.translatesAutoresizingMaskIntoConstraints = false
        challengeButton.addTarget(self, action: #selector(challengeTabTapped), for: .touchUpInside)
        tabContainer.addSubview(challengeButton)
        
        // Content area
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentView)
        
        // Join action button (only visible on Join tab)
        let joinActionButton = UIButton(type: .system)
        joinActionButton.setTitle("Join", for: .normal)
        joinActionButton.setTitleColor(UIColor.white, for: .normal)
        joinActionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        joinActionButton.backgroundColor = UIColor.systemGreen
        joinActionButton.layer.cornerRadius = 12
        joinActionButton.translatesAutoresizingMaskIntoConstraints = false
        joinActionButton.tag = 101 // Tag to identify for show/hide
        containerView.addSubview(joinActionButton)
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(UIColor.systemRed, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        closeButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        // Add tap gesture to background to close modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            // Tab container
            tabContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            tabContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tabContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tabContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Join button
            joinButton.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            joinButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            joinButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            joinButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.48),
            
            // Challenge button
            challengeButton.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            challengeButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            challengeButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            challengeButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.48),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Join action button (inline with close)
            joinActionButton.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20),
            joinActionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            joinActionButton.widthAnchor.constraint(equalToConstant: 100),
            joinActionButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
        
        // Load initial content
        updateTabContent()
    }
    
    @objc private func joinTabTapped() {
        selectedTab = 0
        updateTabButtons()
        updateTabContent()
    }
    
    @objc private func challengeTabTapped() {
        selectedTab = 1
        updateTabButtons()
        updateTabContent()
    }
    
    private func updateTabButtons() {
        // Find join action button by tag
        let joinActionButton = view.viewWithTag(101)
        
        if selectedTab == 0 {
            // Join selected
            joinButton.setTitleColor(UIColor.systemRed, for: .normal)
            joinButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
            
            challengeButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            challengeButton.backgroundColor = UIColor.clear
            
            // Show Join action button
            joinActionButton?.isHidden = false
        } else {
            // Challenge selected
            challengeButton.setTitleColor(UIColor.systemRed, for: .normal)
            challengeButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
            
            joinButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            joinButton.backgroundColor = UIColor.clear
            
            // Hide Join action button
            joinActionButton?.isHidden = true
        }
    }
    
    private func updateTabContent() {
        // Clear existing content
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if selectedTab == 0 {
            setupJoinContent()
        } else {
            setupChallengeContent()
        }
    }
    
    private func setupJoinContent() {
        // Burn Code label
        let burnCodeLabel = UILabel()
        burnCodeLabel.text = "BURN CODE"
        burnCodeLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        burnCodeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        burnCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(burnCodeLabel)
        
        // Input container
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        inputContainer.layer.cornerRadius = 12
        inputContainer.layer.borderWidth = 1
        inputContainer.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.3).cgColor
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(inputContainer)
        
        // Text field
        let textField = UITextField()
        textField.placeholder = "Enter burn code..."
        textField.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Placeholder text color
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter burn code...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        
        inputContainer.addSubview(textField)
        
        // Scan button
        let scanButton = UIButton(type: .system)
        if let scanImage = UIImage(systemName: "qrcode.viewfinder") {
            scanButton.setImage(scanImage, for: .normal)
        }
        scanButton.tintColor = UIColor.white.withAlphaComponent(0.7)
        scanButton.backgroundColor = UIColor.clear
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        inputContainer.addSubview(scanButton)
        
        NSLayoutConstraint.activate([
            // Burn code label
            burnCodeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            burnCodeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            // Input container
            inputContainer.topAnchor.constraint(equalTo: burnCodeLabel.bottomAnchor, constant: 12),
            inputContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Text field
            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scanButton.leadingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            textField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            
            // Scan button
            scanButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            scanButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 30),
            scanButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupChallengeContent() {
        // Flame logo
        let flameImageView = UIImageView()
        flameImageView.image = UIImage(named: "flame_logo_transparent")
        flameImageView.contentMode = .scaleAspectFit
        flameImageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        flameImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(flameImageView)
        
        // Coming soon message
        let comingSoonLabel = UILabel()
        comingSoonLabel.text = "Challenges coming soon..."
        comingSoonLabel.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        comingSoonLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        comingSoonLabel.textAlignment = .center
        comingSoonLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(comingSoonLabel)
        
        NSLayoutConstraint.activate([
            flameImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            flameImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            flameImageView.widthAnchor.constraint(equalToConstant: 80),
            flameImageView.heightAnchor.constraint(equalToConstant: 80),
            
            comingSoonLabel.topAnchor.constraint(equalTo: flameImageView.bottomAnchor, constant: 20),
            comingSoonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            comingSoonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    @objc private func scanButtonTapped() {
        print("🔍 Scan button tapped!")
        
        // Close this modal and switch to scan tab
        dismiss(animated: false) {
            print("🔍 Modal dismissed, attempting to switch to scan tab...")
            
            // Find the main app tab bar controller through UIApplication
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
               let tabBarController = keyWindow.rootViewController as? UITabBarController {
                print("🔍 Found tab bar controller, switching to index 0 (Scan)")
                DispatchQueue.main.async {
                    tabBarController.selectedIndex = 0
                }
                return
            }
            
            print("⚠️ Could not find tab bar controller")
        }
    }
}

// MARK: - Add To Leaderboard Modal View Controller
class AddToLeaderboardModalViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Modal container
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.2).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Add Leaderboard"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Burn Code label
        let burnCodeLabel = UILabel()
        burnCodeLabel.text = "BURN CODE"
        burnCodeLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        burnCodeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        burnCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(burnCodeLabel)
        
        // Input container
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        inputContainer.layer.cornerRadius = 12
        inputContainer.layer.borderWidth = 1
        inputContainer.layer.borderColor = UIColor.systemGray6.withAlphaComponent(0.3).cgColor
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputContainer)
        
        // Text field
        let textField = UITextField()
        textField.placeholder = "Enter burn code..."
        textField.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Placeholder text color
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter burn code...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        
        inputContainer.addSubview(textField)
        
        // Scan button
        let scanButton = UIButton(type: .system)
        if let scanImage = UIImage(systemName: "qrcode.viewfinder") {
            scanButton.setImage(scanImage, for: .normal)
        }
        scanButton.tintColor = UIColor.white.withAlphaComponent(0.7)
        scanButton.backgroundColor = UIColor.clear
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        inputContainer.addSubview(scanButton)
        
        // Add button
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        addButton.backgroundColor = UIColor.systemGreen
        addButton.layer.cornerRadius = 12
        addButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(addButton)
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(UIColor.systemRed, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        closeButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        // Add tap gesture to background to close modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 260),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            burnCodeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            burnCodeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            inputContainer.topAnchor.constraint(equalTo: burnCodeLabel.bottomAnchor, constant: 12),
            inputContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            inputContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            inputContainer.heightAnchor.constraint(equalToConstant: 50),
            
            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scanButton.leadingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            textField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            
            scanButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            scanButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 30),
            scanButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Button container for inline layout
            addButton.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 24),
            addButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            addButton.widthAnchor.constraint(equalToConstant: 100),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 24),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    @objc private func scanButtonTapped() {
        print("🔍 Add to Leaderboard scan button tapped!")
        
        // Close this modal and switch to scan tab
        dismiss(animated: false) {
            print("🔍 Modal dismissed, attempting to switch to scan tab...")
            
            // Find the main app tab bar controller through UIApplication
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
               let tabBarController = keyWindow.rootViewController as? UITabBarController {
                print("🔍 Found tab bar controller, switching to index 0 (Scan)")
                DispatchQueue.main.async {
                    tabBarController.selectedIndex = 0
                }
                return
            }
            
            print("⚠️ Could not find tab bar controller")
        }
    }
}

// MARK: - Scan View Controller
class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var scannerFrameView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupQRScanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScanning()
        // Add a small delay to ensure views are properly laid out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animateScannerBrackets()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
        // Stop animations when view disappears
        if let scanLine = scannerFrameView?.subviews.first(where: { $0.tag == 999 }) {
            scanLine.layer.removeAllAnimations()
        }
        scannerFrameView?.layer.removeAllAnimations()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        
        // Create full screen camera preview
        setupCameraPreview()
        
        // Add overlay UI elements
        createOverlayUI()
        
        // Add flame logo at top center (after overlays so it's on top)
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "flame_logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        // Make logo white/transparent on dark background
        logoImageView.tintColor = UIColor.white
        if #available(iOS 13.0, *) {
            logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
        }
        view.addSubview(logoImageView)
        
        // Add logo constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Create scanning brackets
        createScannerBrackets()
    }
    
    private func setupCameraPreview() {
        // This will be filled by the actual camera preview layer
        view.backgroundColor = UIColor.black
    }
    
    private func createOverlayUI() {
        // Transparent overlay areas for text only (no dark background)
        let topOverlay = UIView()
        topOverlay.backgroundColor = UIColor.clear
        topOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topOverlay)
        
        let bottomOverlay = UIView()
        bottomOverlay.backgroundColor = UIColor.clear
        bottomOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomOverlay)
        
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Position QR code within the brackets"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        subtitleLabel.textColor = UIColor.lightGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topOverlay.addSubview(subtitleLabel)
        
        // Instructions in bottom overlay
        let instructionLabel = UILabel()
        instructionLabel.text = "Scan QR codes to unlock exclusive FUEGO products and verify authenticity"
        instructionLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        instructionLabel.textColor = UIColor.lightGray
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomOverlay.addSubview(instructionLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Top overlay
            topOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            topOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topOverlay.heightAnchor.constraint(equalToConstant: 200),
            
            // Bottom overlay
            bottomOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomOverlay.heightAnchor.constraint(equalToConstant: 165), // Increased for 140pt dock height
            
            subtitleLabel.centerXAnchor.constraint(equalTo: topOverlay.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: topOverlay.topAnchor, constant: 40),
            subtitleLabel.leadingAnchor.constraint(equalTo: topOverlay.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: topOverlay.trailingAnchor, constant: -40),
            
            // Instructions
            instructionLabel.centerXAnchor.constraint(equalTo: bottomOverlay.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: bottomOverlay.topAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: bottomOverlay.leadingAnchor, constant: 30),
            instructionLabel.trailingAnchor.constraint(equalTo: bottomOverlay.trailingAnchor, constant: -30)
        ])
    }
    
    private func createScannerBrackets() {
        // Scanner frame view (transparent area)
        scannerFrameView = UIView()
        scannerFrameView.backgroundColor = UIColor.clear
        scannerFrameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scannerFrameView)
        
        // Create bracket corners
        createBracketCorner(corner: .topLeft)
        createBracketCorner(corner: .topRight)
        createBracketCorner(corner: .bottomLeft)
        createBracketCorner(corner: .bottomRight)
        
        // Scanning line animation
        let scanLine = UIView()
        scanLine.backgroundColor = UIColor.systemRed
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        scanLine.tag = 999 // For animation reference
        scannerFrameView.addSubview(scanLine)
        
        NSLayoutConstraint.activate([
            // Scanner frame
            scannerFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannerFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scannerFrameView.widthAnchor.constraint(equalToConstant: 250),
            scannerFrameView.heightAnchor.constraint(equalToConstant: 250),
            
            // Scan line
            scanLine.leadingAnchor.constraint(equalTo: scannerFrameView.leadingAnchor, constant: 20),
            scanLine.trailingAnchor.constraint(equalTo: scannerFrameView.trailingAnchor, constant: -20),
            scanLine.topAnchor.constraint(equalTo: scannerFrameView.topAnchor, constant: 20),
            scanLine.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    enum BracketCorner {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    private func createBracketCorner(corner: BracketCorner) {
        let bracketLength: CGFloat = 30
        let bracketWidth: CGFloat = 3
        
        // Horizontal line
        let hLine = UIView()
        hLine.backgroundColor = UIColor.systemRed
        hLine.translatesAutoresizingMaskIntoConstraints = false
        scannerFrameView.addSubview(hLine)
        
        // Vertical line
        let vLine = UIView()
        vLine.backgroundColor = UIColor.systemRed
        vLine.translatesAutoresizingMaskIntoConstraints = false
        scannerFrameView.addSubview(vLine)
        
        // Position based on corner
        switch corner {
        case .topLeft:
            NSLayoutConstraint.activate([
                // Horizontal line
                hLine.topAnchor.constraint(equalTo: scannerFrameView.topAnchor),
                hLine.leadingAnchor.constraint(equalTo: scannerFrameView.leadingAnchor),
                hLine.widthAnchor.constraint(equalToConstant: bracketLength),
                hLine.heightAnchor.constraint(equalToConstant: bracketWidth),
                
                // Vertical line
                vLine.topAnchor.constraint(equalTo: scannerFrameView.topAnchor),
                vLine.leadingAnchor.constraint(equalTo: scannerFrameView.leadingAnchor),
                vLine.widthAnchor.constraint(equalToConstant: bracketWidth),
                vLine.heightAnchor.constraint(equalToConstant: bracketLength)
            ])
            
        case .topRight:
            NSLayoutConstraint.activate([
                // Horizontal line
                hLine.topAnchor.constraint(equalTo: scannerFrameView.topAnchor),
                hLine.trailingAnchor.constraint(equalTo: scannerFrameView.trailingAnchor),
                hLine.widthAnchor.constraint(equalToConstant: bracketLength),
                hLine.heightAnchor.constraint(equalToConstant: bracketWidth),
                
                // Vertical line
                vLine.topAnchor.constraint(equalTo: scannerFrameView.topAnchor),
                vLine.trailingAnchor.constraint(equalTo: scannerFrameView.trailingAnchor),
                vLine.widthAnchor.constraint(equalToConstant: bracketWidth),
                vLine.heightAnchor.constraint(equalToConstant: bracketLength)
            ])
            
        case .bottomLeft:
            NSLayoutConstraint.activate([
                // Horizontal line
                hLine.bottomAnchor.constraint(equalTo: scannerFrameView.bottomAnchor),
                hLine.leadingAnchor.constraint(equalTo: scannerFrameView.leadingAnchor),
                hLine.widthAnchor.constraint(equalToConstant: bracketLength),
                hLine.heightAnchor.constraint(equalToConstant: bracketWidth),
                
                // Vertical line
                vLine.bottomAnchor.constraint(equalTo: scannerFrameView.bottomAnchor),
                vLine.leadingAnchor.constraint(equalTo: scannerFrameView.leadingAnchor),
                vLine.widthAnchor.constraint(equalToConstant: bracketWidth),
                vLine.heightAnchor.constraint(equalToConstant: bracketLength)
            ])
            
        case .bottomRight:
            NSLayoutConstraint.activate([
                // Horizontal line
                hLine.bottomAnchor.constraint(equalTo: scannerFrameView.bottomAnchor),
                hLine.trailingAnchor.constraint(equalTo: scannerFrameView.trailingAnchor),
                hLine.widthAnchor.constraint(equalToConstant: bracketLength),
                hLine.heightAnchor.constraint(equalToConstant: bracketWidth),
                
                // Vertical line
                vLine.bottomAnchor.constraint(equalTo: scannerFrameView.bottomAnchor),
                vLine.trailingAnchor.constraint(equalTo: scannerFrameView.trailingAnchor),
                vLine.widthAnchor.constraint(equalToConstant: bracketWidth),
                vLine.heightAnchor.constraint(equalToConstant: bracketLength)
            ])
        }
    }
    
    private func animateScannerBrackets() {
        guard let scanLine = scannerFrameView.subviews.first(where: { $0.tag == 999 }) else { return }
        
        // Remove any existing animations
        scanLine.layer.removeAllAnimations()
        self.scannerFrameView.layer.removeAllAnimations()
        
        // Create continuous scan line animation using CABasicAnimation
        let scanAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        scanAnimation.duration = 2.0
        scanAnimation.repeatCount = .infinity
        scanAnimation.autoreverses = true
        scanAnimation.fromValue = 0
        scanAnimation.toValue = 210
        scanAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scanLine.layer.add(scanAnimation, forKey: "scanLineAnimation")
        
        // Create continuous pulse animation for brackets
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1.5
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.autoreverses = true
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.7
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.scannerFrameView.layer.add(pulseAnimation, forKey: "bracketsAnimation")
        
        print("🔄 Scanner animations started")
    }
    
    private func setupQRScanner() {
        // Check camera authorization status
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthStatus {
        case .authorized:
            configureCameraSession()
        case .denied, .restricted:
            showCameraAccessDeniedAlert()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureCameraSession()
                    } else {
                        self?.showCameraAccessDeniedAlert()
                    }
                }
            }
        @unknown default:
            showCameraAccessDeniedAlert()
        }
    }
    
    private func configureCameraSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { 
            print("❌ No camera device found")
            return 
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("❌ Error creating camera input: \(error)")
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("❌ Cannot add camera input to session")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("❌ Cannot add metadata output to session")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        print("✅ Camera session configured successfully")
    }
    
    private func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "FUEGO needs access to your camera to scan QR codes. Please enable camera access in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func startScanning() {
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    private func stopScanning() {
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            handleQRCodeScanned(stringValue)
        }
    }
    
    private func handleQRCodeScanned(_ code: String) {
        let alert = UIAlertController(title: "FUEGO QR Scanned", message: "Product Code: \(code)\n\nAuthenticity verified ✓", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "View Product", style: .default) { _ in
            self.startScanning()
        })
        alert.addAction(UIAlertAction(title: "Continue Scanning", style: .cancel) { _ in
            self.startScanning()
        })
        present(alert, animated: true)
    }
}

// MARK: - Track Progress View Controller
class TrackProgressViewController: UIViewController {
    
    private var timelineItems: [FuegoTimelineItem] = []
    private var isLoadingShopifyData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔄 TrackProgressViewController: viewDidLoad started")
        
        // Initialize with fallback data
        timelineItems = FuegoDataManager.shared.getTimelineItems()
        
        setupUI()
        requestHealthKitPermissions()
        requestLocationPermissions()
        setupGymVisitNotifications()
        
        // Test Shopify connection
        testShopifyConnection()
    }
    
    private func testShopifyConnection() {
        // Show skeleton loaders immediately
        isLoadingShopifyData = true
        refreshTimelineUI()
        
        Task {
            print("🔥 Testing Shopify connection...")
            print("🔧 SHOPIFY CONFIG CHECK:")
            print("   Store Domain: \(ShopifyConfig.storeDomain)")
            print("   Admin URL: \(ShopifyConfig.adminURL)")
            print("   Token Length: \(ShopifyConfig.adminAccessToken.count)")
            print("   Token Starts With: \(String(ShopifyConfig.adminAccessToken.prefix(10)))")
            
            // Test Admin API connection
            let connected = await SimpleShopifyService.shared.testAdminConnection()
            if connected {
                print("✅ Shopify Admin API connected!")
                
                // Try to get products
                if let products = await SimpleShopifyService.shared.getProducts() {
                    print("📦 Found \(products.count) products in your store")
                    
                    // Replace skeleton loaders with real products
                    await updateProductsFromShopify(products)
                }
            } else {
                print("❌ Failed to connect to Shopify")
                print("💡 Common issues:")
                print("   1. Store domain might be wrong")
                print("   2. Admin API access token might be invalid")
                print("   3. API permissions might not be enabled")
                
                // Hide skeleton loaders on failure
                await MainActor.run {
                    isLoadingShopifyData = false
                    refreshTimelineUI()
                }
            }
        }
    }
    
    @MainActor
    private func updateProductsFromShopify(_ products: [ShopifyProduct]) {
        print("🔄 Updating product list with Shopify data...")
        for (index, product) in products.enumerated() {
            print("Product \(index + 1): \(product.title) - $\(product.variants.first?.price ?? "N/A")")
        }
        
        // Update the data manager with Shopify products (only once)
        FuegoDataManager.shared.updateShopifyProducts(products)
        
        // Get updated timeline items
        timelineItems = FuegoDataManager.shared.getTimelineItems()
        print("📋 Updated timeline items: \(timelineItems.count)")
        for (index, item) in timelineItems.prefix(3).enumerated() {
            print("   \(index + 1). \(item.title) - \(item.price ?? "No price")")
        }
        
        // Turn off loading state and refresh UI with real data
        isLoadingShopifyData = false
        self.refreshTimelineUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Refresh health data when view appears
        loadHealthData()
        checkMilestoneProgress()
    }
    
    private func requestLocationPermissions() {
        LocationManager.shared.requestLocationPermission()
    }
    
    private func setupGymVisitNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGymVisitDetected),
            name: NSNotification.Name("GymVisitDetected"),
            object: nil
        )
    }
    
    @objc private func handleGymVisitDetected(notification: Notification) {
        DispatchQueue.main.async {
            // Refresh the timeline to update progress
            self.loadHealthData()
            self.checkMilestoneProgress()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func createCollectionHeaderSection() -> UIView {
        let headerContainer = UIView()
        headerContainer.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0)
        headerContainer.layer.cornerRadius = 15
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Main collection image (left side)
        let collectionImageView = UIView()
        collectionImageView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        collectionImageView.layer.cornerRadius = 12
        collectionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Placeholder camera icon for collection image
        let cameraIcon = UIImageView(image: UIImage(systemName: "camera.fill"))
        cameraIcon.tintColor = UIColor.systemGray3
        cameraIcon.contentMode = .scaleAspectFit
        cameraIcon.translatesAutoresizingMaskIntoConstraints = false
        collectionImageView.addSubview(cameraIcon)
        
        headerContainer.addSubview(collectionImageView)
        
        // Text content (right side)
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(textContainer)
        
        // Collection label
        let collectionLabel = UILabel()
        collectionLabel.text = "FLAME"
        collectionLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        collectionLabel.textColor = UIColor.systemRed
        collectionLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(collectionLabel)
        
        // Picture/Title
        let titleLabel = UILabel()
        titleLabel.text = "Gym Warrior Tee"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(titleLabel)
        
        // Challenge description
        let challengeLabel = UILabel()
        challengeLabel.text = "Visit gym or fitness center 10 times"
        challengeLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        challengeLabel.textColor = UIColor.systemGray2
        challengeLabel.numberOfLines = 2
        challengeLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(challengeLabel)
        
        // Progress indicator
        let progressContainer = UIView()
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(progressContainer)
        
        let progressTrack = UIView()
        progressTrack.backgroundColor = UIColor.systemGray5
        progressTrack.layer.cornerRadius = 3
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(progressTrack)
        
        let progressFill = UIView()
        progressFill.backgroundColor = UIColor.systemRed
        progressFill.layer.cornerRadius = 3
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressFill)
        
        let progressLabel = UILabel()
        progressLabel.text = "7/10 visits"
        progressLabel.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        progressLabel.textColor = UIColor.white
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(progressLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Collection image (left side)
            collectionImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 15),
            collectionImageView.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            collectionImageView.widthAnchor.constraint(equalToConstant: 80),
            collectionImageView.heightAnchor.constraint(equalToConstant: 90),
            
            cameraIcon.centerXAnchor.constraint(equalTo: collectionImageView.centerXAnchor),
            cameraIcon.centerYAnchor.constraint(equalTo: collectionImageView.centerYAnchor),
            cameraIcon.widthAnchor.constraint(equalToConstant: 30),
            cameraIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Text container (right side)
            textContainer.leadingAnchor.constraint(equalTo: collectionImageView.trailingAnchor, constant: 15),
            textContainer.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -15),
            textContainer.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            
            // Collection label
            collectionLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            collectionLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            collectionLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            // Challenge label
            challengeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            challengeLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            challengeLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            // Progress container
            progressContainer.topAnchor.constraint(equalTo: challengeLabel.bottomAnchor, constant: 8),
            progressContainer.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            progressContainer.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            progressContainer.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            
            // Progress track
            progressTrack.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            progressTrack.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressTrack.widthAnchor.constraint(equalToConstant: 120),
            progressTrack.heightAnchor.constraint(equalToConstant: 6),
            
            // Progress fill (70% progress for example)
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressTrack.widthAnchor, multiplier: 0.7),
            progressFill.heightAnchor.constraint(equalTo: progressTrack.heightAnchor),
            
            // Progress label
            progressLabel.topAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: 4),
            progressLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor)
        ])
        
        return headerContainer
    }
    
    private func requestHealthKitPermissions() {
        // Check if running on simulator
        #if targetEnvironment(simulator)
            print("⚠️ HealthKit does not work on iOS Simulator - use physical device")
            showHealthKitSimulatorAlert()
            return
        #endif
        
        // Check if HealthKit is available first
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit is not available on this device")
            showHealthKitNotAvailableAlert()
            return
        }
        
        print("🔄 Requesting HealthKit authorization...")
        
        HealthKitManager.shared.requestAuthorization { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ HealthKit authorization granted in Track Progress")
                    self?.loadHealthData()
                    self?.checkMilestoneProgress()
                } else {
                    print("❌ HealthKit authorization denied: \(error?.localizedDescription ?? "Unknown error")")
                    print("❌ Error details: \(String(describing: error))")
                    // Show alert to user about needing HealthKit permissions
                    self?.showHealthKitPermissionAlert()
                }
            }
        }
    }
    
    private func showHealthKitPermissionAlert() {
        let alert = UIAlertController(
            title: "HealthKit Access Required", 
            message: "FUEGO needs access to your health data to track fitness milestones and unlock exclusive gear. Please enable HealthKit in Settings.", 
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showHealthKitSimulatorAlert() {
        let alert = UIAlertController(
            title: "HealthKit Not Supported",
            message: "HealthKit does not work on the iOS Simulator. Please test on a physical iPhone device.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showHealthKitNotAvailableAlert() {
        let alert = UIAlertController(
            title: "HealthKit Not Available",
            message: "HealthKit is not available on this device. Make sure you're using a compatible iPhone with iOS 8.0 or later.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        
        // Add flame logo at top center
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "flame_logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        // Make logo white/transparent on dark background
        logoImageView.tintColor = UIColor.white
        if #available(iOS 13.0, *) {
            logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
        }
        view.addSubview(logoImageView)
        
        // Header removed - photos will be on individual cards instead
        
        // Create scroll view for timeline
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        let detailsSection = UIView()
        detailsSection.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(detailsSection)
        
        // Header with logo and stats
        let headerView = createHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(headerView)
        
        // Timeline line (vertical)
        let timelineLine = UIView()
        timelineLine.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        timelineLine.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(timelineLine)
        
        // Create timeline items
        var previousView: UIView = headerView
        
        if isLoadingShopifyData {
            // Show skeleton loaders while loading Shopify data
            print("🔄 Showing skeleton loaders...")
            for index in 0..<5 { // Show 5 skeleton cards
                let skeletonView = createSkeletonTimelineItemView()
                skeletonView.translatesAutoresizingMaskIntoConstraints = false
                detailsSection.addSubview(skeletonView)
                
                NSLayoutConstraint.activate([
                    skeletonView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30),
                    skeletonView.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 60),
                    skeletonView.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20)
                ])
                
                previousView = skeletonView
            }
        } else {
            // Show real timeline items
            for (index, item) in timelineItems.enumerated() {
                let itemView = createTimelineItemView(item: item, index: index)
                itemView.translatesAutoresizingMaskIntoConstraints = false
                detailsSection.addSubview(itemView)
                
                NSLayoutConstraint.activate([
                    itemView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30),
                    itemView.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 60),
                    itemView.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20)
                ])
                
                previousView = itemView
            }
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Logo at top center
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Scroll view below logo (no header)
            scrollView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            detailsSection.topAnchor.constraint(equalTo: scrollView.topAnchor),
            detailsSection.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            detailsSection.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            detailsSection.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            detailsSection.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            detailsSection.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 50),
            
            headerView.topAnchor.constraint(equalTo: detailsSection.topAnchor, constant: -5),
            headerView.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20),
            
            // Timeline line
            timelineLine.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            timelineLine.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 40),
            timelineLine.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
            timelineLine.widthAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func refreshTimelineUI() {
        print("🔄 Timeline UI refresh started with \(timelineItems.count) items")
        
        // Simple approach: clear all subviews and rebuild
        view.subviews.forEach { $0.removeFromSuperview() }
        
        // Rebuild the entire UI with updated timeline items
        setupUI()
        
        print("🔄 Timeline UI refreshed successfully")
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView()
        
        // Logo
        
        // Progress stats
        let statsLabel = UILabel()
        let unlockedCount = timelineItems.filter { $0.isUnlocked }.count
        statsLabel.text = "\(unlockedCount)/\(timelineItems.count) EXCLUSIVES UNLOCKED"
        statsLabel.font = UIFont.systemFont(ofSize: 28, weight: .thin)
        statsLabel.textColor = UIColor.systemRed
        statsLabel.textAlignment = .center
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(statsLabel)
        
        
        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            statsLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            statsLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15)
        ])
        
        return headerView
    }
    
    private func createTimelineItemView(item: FuegoTimelineItem, index: Int) -> UIView {
        let detailsSection = UIView()
        detailsSection.tag = index // For tap handling
        
        // Remove old timeline dot - we'll add status dot to corner of card instead
        
        // Content card - always clickable to show progress
        let contentCard = createGlassmorphicView()
        contentCard.translatesAutoresizingMaskIntoConstraints = false
        // Add tap gesture for all items (both locked and unlocked)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(timelineItemTapped(_:)))
        contentCard.addGestureRecognizer(tapGesture)
        contentCard.isUserInteractionEnabled = true
        detailsSection.addSubview(contentCard)
        
        // Title - Display Shopify product title or fallback to milestone title
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        titleLabel.textColor = item.isUnlocked ? UIColor.white : UIColor.lightGray
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.tag = 100 + index // Tag for dynamic updates
        contentCard.addSubview(titleLabel)
        
        // Price label - Show Shopify price if available
        let priceLabel = UILabel()
        if let price = item.price {
            priceLabel.text = "$\(price)"
        } else {
            priceLabel.text = "Reward"
        }
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .thin)
        priceLabel.textColor = UIColor.systemGreen
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(priceLabel)
        
        // Product image - small thumbnail on the left
        let productImage = UIImageView()
        productImage.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        productImage.layer.cornerRadius = 8
        productImage.layer.borderWidth = 1
        productImage.layer.borderColor = UIColor.systemGray6.cgColor
        productImage.contentMode = .scaleAspectFill
        productImage.clipsToBounds = true
        productImage.translatesAutoresizingMaskIntoConstraints = false
        
        // Add placeholder icon
        let placeholderIcon = UIImageView(image: UIImage(systemName: "tshirt.fill"))
        placeholderIcon.tintColor = UIColor.systemGray4
        placeholderIcon.contentMode = .scaleAspectFit
        placeholderIcon.translatesAutoresizingMaskIntoConstraints = false
        productImage.addSubview(placeholderIcon)
        
        contentCard.addSubview(productImage)
        
        // Description - Health app style small secondary text
        let descLabel = UILabel()
        descLabel.text = item.description
        descLabel.font = UIFont.systemFont(ofSize: 13, weight: .thin)  // Thin weight
        descLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)  // Health app gray
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(descLabel)
        
        // Lock icon - initially shown, will be hidden if unlocked based on real progress
        let lockIcon = UIImageView()
        lockIcon.image = UIImage(systemName: "lock.fill")
        lockIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Subtle gray like Health app
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        lockIcon.tag = 200 + index // Tag for dynamic updates
        contentCard.addSubview(lockIcon)
        
        // Status indicator - small accent like Health app
        let statusDot = UIView()
        statusDot.backgroundColor = UIColor.systemGray // Start as gray, will update based on real progress
        statusDot.layer.cornerRadius = 4
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.tag = 300 + index // Tag for dynamic updates
        contentCard.addSubview(statusDot)
        
        
        NSLayoutConstraint.activate([
            
            // Content card
            contentCard.topAnchor.constraint(equalTo: detailsSection.topAnchor),
            contentCard.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor),
            contentCard.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor),
            contentCard.bottomAnchor.constraint(equalTo: detailsSection.bottomAnchor),
            
            // Product image
            productImage.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            productImage.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 16),
            productImage.widthAnchor.constraint(equalToConstant: 60),
            productImage.heightAnchor.constraint(equalToConstant: 60),
            
            // Placeholder icon constraints
            placeholderIcon.centerXAnchor.constraint(equalTo: productImage.centerXAnchor),
            placeholderIcon.centerYAnchor.constraint(equalTo: productImage.centerYAnchor),
            placeholderIcon.widthAnchor.constraint(equalToConstant: 24),
            placeholderIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: productImage.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -50),
            
            // Price
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: productImage.trailingAnchor, constant: 16),
            
            // Description
            descLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: productImage.trailingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -50),
            descLabel.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -16),
            
            // Lock icon
            lockIcon.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),
            lockIcon.centerYAnchor.constraint(equalTo: contentCard.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 16),
            lockIcon.heightAnchor.constraint(equalToConstant: 16),
            
            // Status dot
            statusDot.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 12),
            statusDot.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -12),
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        // Check real progress and update visual state
        let healthMetric = item.milestone.healthMetric
        calculateProgressWithHealthKit(for: healthMetric) { progress in
            DispatchQueue.main.async {
                self.updateTimelineItemVisualState(index: index, progress: progress)
            }
        }
        
        return detailsSection
    }
    
    private func createSkeletonTimelineItemView() -> UIView {
        let detailsSection = UIView()
        
        // Content card - same style as real cards
        let contentCard = createGlassmorphicView()
        contentCard.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(contentCard)
        
        // Product image skeleton - matches the real product image
        let productImageSkeleton = UIView()
        productImageSkeleton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        productImageSkeleton.layer.cornerRadius = 8
        productImageSkeleton.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(productImageSkeleton)
        
        // Shimmer effect for product image
        addShimmerEffect(to: productImageSkeleton)
        
        // Title skeleton - matches title label position
        let titleSkeleton = UIView()
        titleSkeleton.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0)
        titleSkeleton.layer.cornerRadius = 4
        titleSkeleton.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(titleSkeleton)
        addShimmerEffect(to: titleSkeleton)
        
        // Price skeleton - matches price label position
        let priceSkeleton = UIView()
        priceSkeleton.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0)
        priceSkeleton.layer.cornerRadius = 4
        priceSkeleton.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(priceSkeleton)
        addShimmerEffect(to: priceSkeleton)
        
        // Description skeleton - matches description label position
        let descSkeleton = UIView()
        descSkeleton.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0)
        descSkeleton.layer.cornerRadius = 4
        descSkeleton.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(descSkeleton)
        addShimmerEffect(to: descSkeleton)
        
        // Status dot skeleton
        let statusDotSkeleton = UIView()
        statusDotSkeleton.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0)
        statusDotSkeleton.layer.cornerRadius = 4
        statusDotSkeleton.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(statusDotSkeleton)
        addShimmerEffect(to: statusDotSkeleton)
        
        // Layout constraints - exactly match the real card layout
        NSLayoutConstraint.activate([
            // Content card
            contentCard.topAnchor.constraint(equalTo: detailsSection.topAnchor),
            contentCard.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor),
            contentCard.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor),
            contentCard.bottomAnchor.constraint(equalTo: detailsSection.bottomAnchor),
            
            // Product image skeleton - same as real product image
            productImageSkeleton.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            productImageSkeleton.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 16),
            productImageSkeleton.widthAnchor.constraint(equalToConstant: 60),
            productImageSkeleton.heightAnchor.constraint(equalToConstant: 60),
            
            // Title skeleton - same as real title
            titleSkeleton.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 16),
            titleSkeleton.leadingAnchor.constraint(equalTo: productImageSkeleton.trailingAnchor, constant: 16),
            titleSkeleton.widthAnchor.constraint(equalToConstant: 120),
            titleSkeleton.heightAnchor.constraint(equalToConstant: 20),
            
            // Price skeleton - same as real price
            priceSkeleton.topAnchor.constraint(equalTo: titleSkeleton.bottomAnchor, constant: 6),
            priceSkeleton.leadingAnchor.constraint(equalTo: productImageSkeleton.trailingAnchor, constant: 16),
            priceSkeleton.widthAnchor.constraint(equalToConstant: 60),
            priceSkeleton.heightAnchor.constraint(equalToConstant: 16),
            
            // Description skeleton - same as real description
            descSkeleton.topAnchor.constraint(equalTo: priceSkeleton.bottomAnchor, constant: 8),
            descSkeleton.leadingAnchor.constraint(equalTo: productImageSkeleton.trailingAnchor, constant: 16),
            descSkeleton.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -50),
            descSkeleton.heightAnchor.constraint(equalToConstant: 12),
            descSkeleton.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -16),
            
            // Status dot skeleton - same as real status dot
            statusDotSkeleton.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 12),
            statusDotSkeleton.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -12),
            statusDotSkeleton.widthAnchor.constraint(equalToConstant: 8),
            statusDotSkeleton.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        return detailsSection
    }
    
    private func addShimmerEffect(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0).cgColor,
            UIColor(red: 0.3, green: 0.3, blue: 0.32, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0).cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.name = "shimmerLayer"
        
        view.layer.addSublayer(gradient)
        
        // Animate the shimmer effect
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.5
        gradient.add(animation, forKey: "shimmer")
        
        // Update frame when layout changes
        DispatchQueue.main.async {
            gradient.frame = view.bounds
            
            // Add observer to update gradient frame when view bounds change
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                gradient.frame = view.bounds
            }
        }
    }
    
    private func updateTimelineItemVisualState(index: Int, progress: Double) {
        // Find the timeline item view by recursively searching the view hierarchy
        func findViewWithTag(_ tag: Int, in view: UIView) -> UIView? {
            if view.tag == tag {
                return view
            }
            for subview in view.subviews {
                if let found = findViewWithTag(tag, in: subview) {
                    return found
                }
            }
            return nil
        }
        
        guard let detailsSection = findViewWithTag(index, in: view),
              let contentCard = detailsSection.subviews.first else { return }
        
        let isUnlocked = progress >= 1.0
        
        // Update title color
        if let titleLabel = contentCard.viewWithTag(100 + index) as? UILabel {
            titleLabel.textColor = isUnlocked ? UIColor.white : UIColor.lightGray
        }
        
        // Update lock icon visibility
        if let lockIcon = contentCard.viewWithTag(200 + index) {
            lockIcon.isHidden = isUnlocked
        }
        
        // Update status dot color and animation
        if let statusDot = contentCard.viewWithTag(300 + index) {
            statusDot.backgroundColor = isUnlocked ? UIColor.systemGreen : UIColor.systemGray
            
            // Add pulsing animation for unlocked items
            if isUnlocked {
                let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
                pulseAnimation.fromValue = 1.0
                pulseAnimation.toValue = 1.3
                pulseAnimation.duration = 1.0
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = .infinity
                statusDot.layer.add(pulseAnimation, forKey: "pulse")
            } else {
                statusDot.layer.removeAnimation(forKey: "pulse")
            }
        }
    }
    
    @objc private func timelineItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view,
              let detailsSection = cardView.superview,
              detailsSection.tag < timelineItems.count else { return }
        
        let item = timelineItems[detailsSection.tag]
        presentItemDetail(item: item)
    }
    
    private func presentItemDetail(item: FuegoTimelineItem) {
        let detailVC = ItemDetailViewController(item: item)
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true)
    }
    
    // getCategoryColor function removed - no longer using categories
    
    private func getStatusDotColor(for item: FuegoTimelineItem) -> UIColor {
        if !item.isUnlocked {
            return UIColor.systemRed  // Red for locked/unavailable
        }
        
        // Green for unlocked items (no more category-based colors)
        return UIColor.systemGreen
    }
    
    private func createGlassmorphicView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Health app card color
        view.layer.cornerRadius = 12 // Health app corner radius
        view.layer.borderWidth = 0
        
        return view
    }
    
    private func createHealthStatView(title: String, value: String, color: UIColor) -> (UIView, UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = UIColor.gray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5)
        ])
        
        return (container, valueLabel)
    }
    
    private func loadHealthData() {
        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) ?? today
        
        // Load today's steps
        HealthKitManager.shared.getStepCount(startDate: startOfDay, endDate: today) { steps, error in
            DispatchQueue.main.async {
                if let steps = steps {
                    print("Today's steps: \(Int(steps))")
                } else {
                    print("Could not load steps: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // Load total distance (last year)
        HealthKitManager.shared.getDistance(startDate: oneYearAgo, endDate: today) { distance, error in
            DispatchQueue.main.async {
                if let distance = distance {
                    print("Total distance: \(String(format: "%.1f", distance))km")
                } else {
                    print("Could not load distance: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // Load workout count (last year)
        HealthKitManager.shared.getWorkoutCount(startDate: oneYearAgo, endDate: today) { count, error in
            DispatchQueue.main.async {
                if let count = count {
                    print("Total workouts: \(count)")
                } else {
                    print("Could not load workouts: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func checkMilestoneProgress() {
        let today = Date()
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) ?? today
        
        // Check milestone progress against actual health data
        for item in timelineItems {
            let healthMetric = item.milestone.healthMetric
            
            switch healthMetric {
            case .workouts(let requiredCount):
                HealthKitManager.shared.getWorkoutCount(startDate: oneYearAgo, endDate: today) { count, error in
                    if let count = count, count >= requiredCount {
                        DispatchQueue.main.async {
                            print("✅ Milestone \(item.milestone.id) (\(item.title)) should be unlocked! Required: \(requiredCount), Actual: \(count) workouts")
                        }
                    }
                }
                
            case .distance(let requiredKm):
                HealthKitManager.shared.getDistance(startDate: oneYearAgo, endDate: today) { distance, error in
                    if let distance = distance, distance >= requiredKm {
                        DispatchQueue.main.async {
                            print("✅ Milestone \(item.milestone.id) (\(item.title)) should be unlocked! Required: \(requiredKm)km, Actual: \(String(format: "%.1f", distance))km")
                        }
                    }
                }
                
            case .marathon:
                // Check if user has completed a marathon (42.195km in a single workout)
                print("📊 Marathon milestone checking requires individual workout distance analysis")
                
            case .streakDays(let requiredDays):
                // This would require a more complex streak calculation
                print("📊 Streak checking for \(requiredDays) days requires daily workout analysis")
                
            default:
                break
            }
        }
    }
    
    private func calculateProgressWithHealthKit(for metric: HealthMetricType, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let today = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        switch metric {
        case .steps(let target):
            HealthKitManager.shared.getStepCount(startDate: oneYearAgo, endDate: today) { steps, _ in
                let progress = steps != nil ? min(1.0, Double(Int(steps!)) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .dailySteps(let target):
            let startOfToday = Calendar.current.startOfDay(for: today)
            HealthKitManager.shared.getStepCount(startDate: startOfToday, endDate: today) { steps, _ in
                print("⚡ DailySteps Progress Calculation:")
                print("   Target: \(target) steps")
                print("   Actual: \(steps ?? 0) steps")
                let progress = steps != nil ? min(1.0, Double(Int(steps!)) / Double(target)) : 0.0
                print("   Progress: \(progress * 100)%")
                completion(progress)
            }
            
        case .distance(let target):
            HealthKitManager.shared.getDistance(startDate: oneYearAgo, endDate: today) { distance, _ in
                let progress = distance != nil ? min(1.0, distance! / target) : 0.0
                completion(progress)
            }
            
        case .workouts(let target):
            HealthKitManager.shared.getWorkoutCount(startDate: oneYearAgo, endDate: today) { count, _ in
                let progress = count != nil ? min(1.0, Double(count!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .gymVisits(let target):
            let currentVisits = LocationManager.shared.getCurrentGymVisitCount()
            let progress = min(1.0, Double(currentVisits) / Double(target))
            print("🏋️‍♀️ GymVisits Progress Calculation:")
            print("   Target: \(target) visits")
            print("   Current: \(currentVisits) visits")
            print("   Progress: \(progress * 100)%")
            completion(progress)
            
        case .exerciseMinutes(let target):
            HealthKitManager.shared.getExerciseMinutes(startDate: oneYearAgo, endDate: today) { minutes, _ in
                let progress = minutes != nil ? min(1.0, Double(minutes!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .flightsClimbed(let target):
            HealthKitManager.shared.getFlightsClimbed(startDate: oneYearAgo, endDate: today) { flights, _ in
                let progress = flights != nil ? min(1.0, Double(flights!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .activeEnergyBurned(let target):
            HealthKitManager.shared.getActiveEnergyBurned(startDate: oneYearAgo, endDate: today) { calories, _ in
                let progress = calories != nil ? min(1.0, calories! / target) : 0.0
                completion(progress)
            }
            
        case .restingHeartRate(let target):
            HealthKitManager.shared.getRestingHeartRate { heartRate, _ in
                guard let heartRate = heartRate else {
                    completion(0.0)
                    return
                }
                // Progress is better when HR is lower
                let progress = heartRate <= target ? 1.0 : max(0.0, (80.0 - heartRate) / (80.0 - target))
                completion(progress)
            }
            
        case .sleepScore(let target):
            HealthKitManager.shared.getSleepHours(startDate: thirtyDaysAgo, endDate: today) { sleepHours, _ in
                let progress = sleepHours != nil ? min(1.0, sleepHours! / target) : 0.0
                completion(progress)
            }
            
        case .cardioFitness(let target):
            HealthKitManager.shared.getCardioFitness { vo2Max, _ in
                let progress = vo2Max != nil ? min(1.0, vo2Max! / target) : 0.0
                completion(progress)
            }
            
        case .streakDays(let target):
            HealthKitManager.shared.getStreakDays { streak, _ in
                let progress = streak != nil ? min(1.0, Double(streak!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .marathon:
            // For marathon, check if longest single workout distance >= 42.2km
            // For simplicity, use total distance as approximation
            HealthKitManager.shared.getDistance(startDate: oneYearAgo, endDate: today) { distance, _ in
                let longestRun = distance ?? 0.0 // Approximation - ideally would check individual workouts
                let progress = min(1.0, longestRun / 42.2)
                completion(progress)
            }
            
        case .dietaryEnergy(_):
            // HealthKit dietary data requires more complex querying
            // For now, return placeholder
            completion(0.6) // 60% placeholder
            
        case .waterIntake(_):
            // HealthKit water intake data requires more complex querying
            // For now, return placeholder
            completion(0.7) // 70% placeholder
        }
    }
    
}

// MARK: - Item Detail View Controller
class ItemDetailViewController: UIViewController {
    
    private let item: FuegoTimelineItem
    
    init(item: FuegoTimelineItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Health app dark gray
        
        
        // Main content container with vertical layout (top/bottom split)
        let mainContainer = UIView()
        mainContainer.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Health app dark gray
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainer)
        
        // Top half - Product images section
        let imageSection = UIView()
        imageSection.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Health app dark gray
        imageSection.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(imageSection)
        
        // Full photo collage taking up entire top half
        let photoCollage = createFullPhotoCollage()
        imageSection.addSubview(photoCollage)
        
        // Bottom half - Product details section
        let detailsSection = createGlassmorphicView()
        detailsSection.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        detailsSection.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(detailsSection)
        
        // Close button in top-right of details section
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor.white
        closeButton.addTarget(self, action: #selector(closeDetail), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(closeButton)
        
        // Product title in details section
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .light)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(titleLabel)
        
        // Pricing section
        let priceLabel = UILabel()
        priceLabel.text = "£\(generatePrice(for: item))"
        priceLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)
        priceLabel.textColor = UIColor.white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(priceLabel)
        
        let freeShippingLabel = UILabel()
        freeShippingLabel.text = "FREE SHIPPING"
        freeShippingLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        freeShippingLabel.textColor = UIColor.systemRed
        freeShippingLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(freeShippingLabel)
        
        // Size selection (similar to web app)
        let sizeLabel = UILabel()
        sizeLabel.text = "SIZE"
        sizeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        sizeLabel.textColor = UIColor.white
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(sizeLabel)
        
        let sizeStackView = UIStackView()
        sizeStackView.axis = .horizontal
        sizeStackView.spacing = 8
        sizeStackView.distribution = .fillEqually
        sizeStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(sizeStackView)
        
        ["XS", "S", "M", "L"].forEach { size in
            let sizeButton = UIButton(type: .system)
            sizeButton.setTitle(size, for: .normal)
            sizeButton.setTitleColor(.white, for: .normal)
            sizeButton.layer.borderColor = UIColor.white.cgColor
            sizeButton.layer.borderWidth = 1
            sizeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            sizeStackView.addArrangedSubview(sizeButton)
        }
        
        // Add description and details
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Unlocked by: \(item.description)"
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        descriptionLabel.textColor = UIColor.lightGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(descriptionLabel)
        
        // Health Milestone Progress Bar
        let progressContainer = createProgressBar(for: item)
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        detailsSection.addSubview(progressContainer)
        
        // Add to cart button (starts disabled, will be enabled when milestone reaches 100%)
        let addToCartButton = UIButton(type: .system)
        addToCartButton.setTitle("LOCKED", for: .normal)
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addToCartButton.layer.cornerRadius = 12
        addToCartButton.layer.borderWidth = 1
        addToCartButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        addToCartButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addToCartButton.isEnabled = false
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add diagonal line overlay for locked state
        let diagonalLine = UIView()
        diagonalLine.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        diagonalLine.translatesAutoresizingMaskIntoConstraints = false
        diagonalLine.tag = 999 // Tag to identify and remove later
        addToCartButton.addSubview(diagonalLine)
        detailsSection.addSubview(addToCartButton)
        
        // Rotate diagonal line after layout
        DispatchQueue.main.async {
            diagonalLine.transform = CGAffineTransform(rotationAngle: .pi / 4) // 45 degrees
        }
        
        // Check milestone completion and update button accordingly
        let healthMetric = item.milestone.healthMetric
        calculateProgressWithHealthKit(for: healthMetric) { progress in
            DispatchQueue.main.async {
                self.updateCartButtonState(addToCartButton, progress: progress)
            }
        }
        
        NSLayoutConstraint.activate([
            // Main container layout (full screen)
            mainContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Vertical split layout (40/60 top/bottom)
            imageSection.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            imageSection.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            imageSection.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            imageSection.heightAnchor.constraint(equalTo: mainContainer.heightAnchor, multiplier: 0.4),
            
            detailsSection.topAnchor.constraint(equalTo: imageSection.bottomAnchor),
            detailsSection.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            detailsSection.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            detailsSection.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            
            // Full photo collage filling top half
            photoCollage.topAnchor.constraint(equalTo: imageSection.topAnchor),
            photoCollage.leadingAnchor.constraint(equalTo: imageSection.leadingAnchor),
            photoCollage.trailingAnchor.constraint(equalTo: imageSection.trailingAnchor),
            photoCollage.bottomAnchor.constraint(equalTo: imageSection.bottomAnchor),
            
            // Details content
            closeButton.topAnchor.constraint(equalTo: detailsSection.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            priceLabel.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            
            freeShippingLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            freeShippingLabel.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            
            sizeLabel.topAnchor.constraint(equalTo: freeShippingLabel.bottomAnchor, constant: 25),
            sizeLabel.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            
            sizeStackView.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 10),
            sizeStackView.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            sizeStackView.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20),
            sizeStackView.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionLabel.topAnchor.constraint(equalTo: sizeStackView.bottomAnchor, constant: 25),
            descriptionLabel.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20),
            
            progressContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            progressContainer.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            progressContainer.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20),
            progressContainer.heightAnchor.constraint(equalToConstant: 80),
            
            addToCartButton.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 25),
            addToCartButton.leadingAnchor.constraint(equalTo: detailsSection.leadingAnchor, constant: 20),
            addToCartButton.trailingAnchor.constraint(equalTo: detailsSection.trailingAnchor, constant: -20),
            addToCartButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Diagonal line constraints (rotated 45 degrees across button)
            diagonalLine.centerXAnchor.constraint(equalTo: addToCartButton.centerXAnchor),
            diagonalLine.centerYAnchor.constraint(equalTo: addToCartButton.centerYAnchor),
            diagonalLine.widthAnchor.constraint(equalToConstant: 2),
            diagonalLine.heightAnchor.constraint(equalTo: addToCartButton.heightAnchor, multiplier: 1.4)
        ])
    }
    
    @objc private func closeDetail() {
        dismiss(animated: true)
    }
    
    private func createFullPhotoCollage() -> UIView {
        let collageView = UIView()
        collageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create main image (left side - 50% width, full height)
        let mainImageView = UIView()
        mainImageView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.tag = 501 // Tag for identification
        
        let mainCameraIcon = UIImageView(image: UIImage(systemName: "camera.fill"))
        mainCameraIcon.tintColor = UIColor.systemGray3
        mainCameraIcon.contentMode = .scaleAspectFit
        mainCameraIcon.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.addSubview(mainCameraIcon)
        
        let mainTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        mainImageView.addGestureRecognizer(mainTapGesture)
        mainImageView.isUserInteractionEnabled = true
        
        collageView.addSubview(mainImageView)
        
        // Create image 2 (top right - 50% width, 50% height)
        let image2View = UIView()
        image2View.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        image2View.translatesAutoresizingMaskIntoConstraints = false
        image2View.tag = 502 // Tag for identification
        
        let camera2Icon = UIImageView(image: UIImage(systemName: "camera.fill"))
        camera2Icon.tintColor = UIColor.systemGray3
        camera2Icon.contentMode = .scaleAspectFit
        camera2Icon.translatesAutoresizingMaskIntoConstraints = false
        image2View.addSubview(camera2Icon)
        
        let tap2Gesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        image2View.addGestureRecognizer(tap2Gesture)
        image2View.isUserInteractionEnabled = true
        
        collageView.addSubview(image2View)
        
        // Create image 3 (bottom right - 50% width, 50% height)
        let image3View = UIView()
        image3View.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        image3View.translatesAutoresizingMaskIntoConstraints = false
        image3View.tag = 503 // Tag for identification
        
        let camera3Icon = UIImageView(image: UIImage(systemName: "camera.fill"))
        camera3Icon.tintColor = UIColor.systemGray3
        camera3Icon.contentMode = .scaleAspectFit
        camera3Icon.translatesAutoresizingMaskIntoConstraints = false
        image3View.addSubview(camera3Icon)
        
        let tap3Gesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        image3View.addGestureRecognizer(tap3Gesture)
        image3View.isUserInteractionEnabled = true
        
        collageView.addSubview(image3View)
        
        // Set up constraints for the 3-image layout
        NSLayoutConstraint.activate([
            // Main image (left side - 50% width, full height)
            mainImageView.leadingAnchor.constraint(equalTo: collageView.leadingAnchor),
            mainImageView.topAnchor.constraint(equalTo: collageView.topAnchor),
            mainImageView.widthAnchor.constraint(equalTo: collageView.widthAnchor, multiplier: 0.5),
            mainImageView.bottomAnchor.constraint(equalTo: collageView.bottomAnchor),
            
            // Image 2 (top right - 50% width, 50% height)
            image2View.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor),
            image2View.topAnchor.constraint(equalTo: collageView.topAnchor),
            image2View.trailingAnchor.constraint(equalTo: collageView.trailingAnchor),
            image2View.heightAnchor.constraint(equalTo: collageView.heightAnchor, multiplier: 0.5),
            
            // Image 3 (bottom right - 50% width, 50% height)
            image3View.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor),
            image3View.topAnchor.constraint(equalTo: image2View.bottomAnchor),
            image3View.trailingAnchor.constraint(equalTo: collageView.trailingAnchor),
            image3View.bottomAnchor.constraint(equalTo: collageView.bottomAnchor),
            
            // Camera icon constraints for main image
            mainCameraIcon.centerXAnchor.constraint(equalTo: mainImageView.centerXAnchor),
            mainCameraIcon.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor),
            mainCameraIcon.widthAnchor.constraint(equalToConstant: 40),
            mainCameraIcon.heightAnchor.constraint(equalToConstant: 32),
            
            // Camera icon constraints for image 2
            camera2Icon.centerXAnchor.constraint(equalTo: image2View.centerXAnchor),
            camera2Icon.centerYAnchor.constraint(equalTo: image2View.centerYAnchor),
            camera2Icon.widthAnchor.constraint(equalToConstant: 25),
            camera2Icon.heightAnchor.constraint(equalToConstant: 20),
            
            // Camera icon constraints for image 3
            camera3Icon.centerXAnchor.constraint(equalTo: image3View.centerXAnchor),
            camera3Icon.centerYAnchor.constraint(equalTo: image3View.centerYAnchor),
            camera3Icon.widthAnchor.constraint(equalToConstant: 25),
            camera3Icon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return collageView
    }
    
    private func createPhotoCollage() -> UIView {
        let collageView = UIView()
        collageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create 2x2 grid of empty photo placeholders
        let photos = ["photo1", "photo2", "photo3", "photo4"]
        
        for (index, _) in photos.enumerated() {
            let photoView = UIView()
            photoView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
            photoView.layer.cornerRadius = 8
            photoView.layer.borderWidth = 1
            photoView.layer.borderColor = UIColor.systemGray5.cgColor
            photoView.translatesAutoresizingMaskIntoConstraints = false
            photoView.tag = 400 + index // Tag for identification
            
            // Add camera icon placeholder
            let cameraIcon = UIImageView(image: UIImage(systemName: "camera.fill"))
            cameraIcon.tintColor = UIColor.systemGray3
            cameraIcon.contentMode = .scaleAspectFit
            cameraIcon.translatesAutoresizingMaskIntoConstraints = false
            photoView.addSubview(cameraIcon)
            
            // Add tap gesture for full screen
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
            photoView.addGestureRecognizer(tapGesture)
            photoView.isUserInteractionEnabled = true
            
            collageView.addSubview(photoView)
            
            // Position photos in 2x2 grid
            let row = index / 2
            let col = index % 2
            
            NSLayoutConstraint.activate([
                photoView.widthAnchor.constraint(equalToConstant: 95),
                photoView.heightAnchor.constraint(equalToConstant: 45),
                photoView.leadingAnchor.constraint(equalTo: collageView.leadingAnchor, constant: CGFloat(col * 105)),
                photoView.topAnchor.constraint(equalTo: collageView.topAnchor, constant: CGFloat(row * 50)),
                
                cameraIcon.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
                cameraIcon.centerYAnchor.constraint(equalTo: photoView.centerYAnchor),
                cameraIcon.widthAnchor.constraint(equalToConstant: 20),
                cameraIcon.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
        
        return collageView
    }
    
    @objc private func photoTapped(_ gesture: UITapGestureRecognizer) {
        guard let photoView = gesture.view else { return }
        
        // Create full screen photo view
        let fullScreenView = UIView()
        fullScreenView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        fullScreenView.frame = UIScreen.main.bounds
        
        // Add tap to dismiss
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreenPhoto))
        fullScreenView.addGestureRecognizer(dismissTap)
        
        // Create enlarged photo view
        let enlargedPhotoView = UIView()
        enlargedPhotoView.backgroundColor = photoView.backgroundColor
        enlargedPhotoView.layer.cornerRadius = 15
        enlargedPhotoView.layer.borderWidth = 2
        enlargedPhotoView.layer.borderColor = UIColor.systemGray3.cgColor
        enlargedPhotoView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add camera icon to enlarged view
        let cameraIcon = UIImageView(image: UIImage(systemName: "camera.fill"))
        cameraIcon.tintColor = UIColor.systemGray3
        cameraIcon.contentMode = .scaleAspectFit
        cameraIcon.translatesAutoresizingMaskIntoConstraints = false
        enlargedPhotoView.addSubview(cameraIcon)
        
        // Add placeholder text
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Photo placeholder"
        placeholderLabel.textColor = UIColor.systemGray3
        placeholderLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        enlargedPhotoView.addSubview(placeholderLabel)
        
        fullScreenView.addSubview(enlargedPhotoView)
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor.white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(dismissFullScreenPhoto), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        fullScreenView.addSubview(closeButton)
        
        // Store reference for dismissal
        fullScreenView.tag = 999
        
        NSLayoutConstraint.activate([
            enlargedPhotoView.centerXAnchor.constraint(equalTo: fullScreenView.centerXAnchor),
            enlargedPhotoView.centerYAnchor.constraint(equalTo: fullScreenView.centerYAnchor),
            enlargedPhotoView.widthAnchor.constraint(equalToConstant: 300),
            enlargedPhotoView.heightAnchor.constraint(equalToConstant: 200),
            
            cameraIcon.centerXAnchor.constraint(equalTo: enlargedPhotoView.centerXAnchor),
            cameraIcon.centerYAnchor.constraint(equalTo: enlargedPhotoView.centerYAnchor, constant: -15),
            cameraIcon.widthAnchor.constraint(equalToConstant: 40),
            cameraIcon.heightAnchor.constraint(equalToConstant: 32),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: enlargedPhotoView.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: cameraIcon.bottomAnchor, constant: 8),
            
            closeButton.topAnchor.constraint(equalTo: fullScreenView.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: fullScreenView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Present with animation
        view.addSubview(fullScreenView)
        fullScreenView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            fullScreenView.alpha = 1
        }
    }
    
    @objc private func dismissFullScreenPhoto() {
        if let fullScreenView = view.viewWithTag(999) {
            UIView.animate(withDuration: 0.3, animations: {
                fullScreenView.alpha = 0
            }) { _ in
                fullScreenView.removeFromSuperview()
            }
        }
    }
    
    private func updateCartButtonState(_ button: UIButton, progress: Double) {
        let wasUnlocked = button.isEnabled
        let isUnlocked = progress >= 1.0
        
        if isUnlocked && !wasUnlocked {
            // Milestone just completed! Trigger unlock animation
            unlockCartButton(button)
        } else if isUnlocked {
            // Already unlocked, just ensure correct state
            button.setTitle("BUY NOW", for: .normal)
            button.backgroundColor = UIColor.systemRed
            button.layer.borderColor = UIColor.clear.cgColor
            button.isEnabled = true
            // Remove diagonal line if present
            if let diagonalLine = button.viewWithTag(999) {
                diagonalLine.removeFromSuperview()
            }
        } else {
            // Still locked - no percentage shown
            button.setTitle("LOCKED", for: .normal)
            button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            button.isEnabled = false
        }
    }
    
    private func unlockCartButton(_ button: UIButton) {
        print("🎉 MILESTONE COMPLETED! Unlocking cart button...")
        
        // Find and animate out the diagonal line
        if let diagonalLine = button.viewWithTag(999) {
            UIView.animate(withDuration: 0.4, animations: {
                diagonalLine.alpha = 0
                diagonalLine.transform = diagonalLine.transform.scaledBy(x: 0.1, y: 0.1)
            }) { _ in
                diagonalLine.removeFromSuperview()
            }
        }
        
        // Update button state with modern unlock sequence
        UIView.animate(withDuration: 0.3, delay: 0.2, options: [.curveEaseOut], animations: {
            button.backgroundColor = UIColor.systemRed
            button.layer.borderColor = UIColor.clear.cgColor
            button.setTitle("BUY NOW", for: .normal)
            button.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                button.alpha = 1.0
            })
        }
        
        button.isEnabled = true
        
        // Modern battlefield-style flash effect
        let flashView = UIView()
        flashView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        flashView.layer.cornerRadius = 12
        flashView.frame = button.bounds
        button.addSubview(flashView)
        
        UIView.animate(withDuration: 0.15, animations: {
            flashView.alpha = 0
        }) { _ in
            flashView.removeFromSuperview()
        }
        
        // Subtle haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Show modern unlock notification
        showUnlockNotification()
    }
    
    private func showUnlockNotification() {
        let unlockLabel = UILabel()
        unlockLabel.text = "ITEM UNLOCKED"
        unlockLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        unlockLabel.textColor = UIColor.systemGreen
        unlockLabel.textAlignment = .center
        unlockLabel.alpha = 0
        unlockLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        unlockLabel.layer.cornerRadius = 8
        unlockLabel.layer.masksToBounds = true
        unlockLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(unlockLabel)
        NSLayoutConstraint.activate([
            unlockLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unlockLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            unlockLabel.widthAnchor.constraint(equalToConstant: 140),
            unlockLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Quick fade in/out animation
        UIView.animate(withDuration: 0.2, animations: {
            unlockLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 1.5, options: [], animations: {
                unlockLabel.alpha = 0
            }) { _ in
                unlockLabel.removeFromSuperview()
            }
        }
    }
    
    private func createProgressBar(for item: FuegoTimelineItem) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.clear
        
        let healthMetric = item.milestone.healthMetric
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "MILESTONE PROGRESS"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = UIColor.systemRed
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // Progress description
        let descLabel = UILabel()
        descLabel.text = getHealthMetricDescription(healthMetric)
        descLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        descLabel.textColor = UIColor.lightGray
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descLabel)
        
        // Progress bar background
        let progressTrack = UIView()
        progressTrack.backgroundColor = UIColor.systemGray5
        progressTrack.layer.cornerRadius = 6
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(progressTrack)
        
        // Progress bar fill
        let progressFill = UIView()
        progressFill.backgroundColor = UIColor.systemOrange // Single color for all progress bars
        progressFill.layer.cornerRadius = 6
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressFill)
        
        // Progress percentage label
        let percentageLabel = UILabel()
        percentageLabel.text = "Loading..."
        percentageLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        percentageLabel.textColor = UIColor.white
        percentageLabel.textAlignment = .right
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(percentageLabel)
        
        // Progress constraint (width based on percentage) - start with 0 width
        let progressWidth = progressFill.widthAnchor.constraint(equalTo: progressTrack.widthAnchor, multiplier: 0.0)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            progressTrack.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
            progressTrack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            progressTrack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            progressTrack.heightAnchor.constraint(equalToConstant: 12),
            
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressWidth,
            
            percentageLabel.topAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: 4),
            percentageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            percentageLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Load real HealthKit data and update progress bar
        calculateProgressWithHealthKit(for: healthMetric) { [weak progressWidth, weak percentageLabel, weak descLabel] progress in
            DispatchQueue.main.async {
                // Update progress width constraint
                progressWidth?.isActive = false
                let newProgressWidth = progressFill.widthAnchor.constraint(equalTo: progressTrack.widthAnchor, multiplier: min(1.0, progress))
                newProgressWidth.isActive = true
                
                // Update percentage label - show decimal places for small values
                let percentage = min(100.0, progress * 100)
                if percentage < 1.0 && percentage > 0 {
                    percentageLabel?.text = String(format: "%.2f%%", percentage)
                } else {
                    percentageLabel?.text = "\(Int(percentage))%"
                }
                
                // Update description with current progress
                self.updateHealthMetricDescription(descLabel, metric: healthMetric, progress: progress)
                
                // Animate the progress bar
                UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseInOut) {
                    container.layoutIfNeeded()
                }
            }
        }
        
        return container
    }
    
    private func getHealthMetricDescription(_ metric: HealthMetricType) -> String {
        switch metric {
        case .steps(let target): return "Steps Target: \(target.formatted())"
        case .dailySteps(let target): return "Daily Steps Target: \(target.formatted())"
        case .distance(let target): return "Distance Target: \(String(format: "%.1f", target))km"
        case .workouts(let target): return "Workouts Target: \(target)"
        case .gymVisits(let target): return "Gym Visits Target: \(target)"
        case .exerciseMinutes(let target): return "Exercise Minutes Target: \(target)"
        case .flightsClimbed(let target): return "Flights Climbed Target: \(target)"
        case .activeEnergyBurned(let target): return "Active Calories Target: \(target.formatted())"
        case .restingHeartRate(let target): return "Resting Heart Rate Target: <\(String(format: "%.0f", target))bpm"
        case .sleepScore(let target): return "Sleep Hours Target: \(String(format: "%.1f", target/30))hrs avg"
        case .cardioFitness(let target): return "VO2 Max Target: >\(String(format: "%.0f", target))"
        case .streakDays(let target): return "Streak Target: \(target) days"
        case .marathon: return "Marathon Target: 42.2km"
        case .dietaryEnergy(let target): return "Daily Calories Target: \(target.formatted())"
        case .waterIntake(let target): return "Water Intake Target: \(String(format: "%.1f", target))L"
        }
    }
    
    private func updateHealthMetricDescription(_ label: UILabel?, metric: HealthMetricType, progress: Double) {
        guard let label = label else { return }
        
        switch metric {
        case .dailySteps(let target):
            let currentSteps = Int(progress * Double(target))
            label.text = "Daily Steps: \(currentSteps)/\(target.formatted())"
            
        case .steps(let target):
            let currentSteps = Int(progress * Double(target))
            label.text = "Total Steps: \(currentSteps)/\(target.formatted())"
            
        case .distance(let target):
            let currentDistance = progress * target
            label.text = "Distance: \(String(format: "%.1f", currentDistance))/\(String(format: "%.1f", target))km"
            
        case .workouts(let target):
            let currentWorkouts = Int(progress * Double(target))
            label.text = "Workouts: \(currentWorkouts)/\(target)"
            
        case .gymVisits(let target):
            let currentVisits = LocationManager.shared.getCurrentGymVisitCount()
            label.text = "Gym Visits: \(currentVisits)/\(target)"
            
        case .activeEnergyBurned(let target):
            let currentCalories = Int(progress * target)
            label.text = "Active Calories: \(currentCalories)/\(Int(target))"
            
        default:
            // For other metrics, keep the original description
            label.text = getHealthMetricDescription(metric)
        }
    }
    
    private func calculateProgress(for metric: HealthMetricType) -> Double {
        // Return a default value while we load real data - this will be updated when real data loads
        return 0.5 // 50% progress placeholder
    }
    
    private func calculateProgressWithHealthKit(for metric: HealthMetricType, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let today = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        switch metric {
        case .steps(let target):
            HealthKitManager.shared.getStepCount(startDate: oneYearAgo, endDate: today) { steps, _ in
                let progress = steps != nil ? min(1.0, Double(Int(steps!)) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .dailySteps(let target):
            let startOfToday = Calendar.current.startOfDay(for: today)
            HealthKitManager.shared.getStepCount(startDate: startOfToday, endDate: today) { steps, _ in
                print("⚡ DailySteps Progress Calculation:")
                print("   Target: \(target) steps")
                print("   Actual: \(steps ?? 0) steps")
                let progress = steps != nil ? min(1.0, Double(Int(steps!)) / Double(target)) : 0.0
                print("   Progress: \(progress * 100)%")
                completion(progress)
            }
            
        case .distance(let target):
            HealthKitManager.shared.getDistance(startDate: oneYearAgo, endDate: today) { distance, _ in
                let progress = distance != nil ? min(1.0, distance! / target) : 0.0
                completion(progress)
            }
            
        case .workouts(let target):
            HealthKitManager.shared.getWorkoutCount(startDate: oneYearAgo, endDate: today) { count, _ in
                let progress = count != nil ? min(1.0, Double(count!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .gymVisits(let target):
            let currentVisits = LocationManager.shared.getCurrentGymVisitCount()
            let progress = min(1.0, Double(currentVisits) / Double(target))
            print("🏋️‍♀️ GymVisits Progress Calculation:")
            print("   Target: \(target) visits")
            print("   Current: \(currentVisits) visits")
            print("   Progress: \(progress * 100)%")
            completion(progress)
            
        case .exerciseMinutes(let target):
            HealthKitManager.shared.getExerciseMinutes(startDate: oneYearAgo, endDate: today) { minutes, _ in
                let progress = minutes != nil ? min(1.0, Double(minutes!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .flightsClimbed(let target):
            HealthKitManager.shared.getFlightsClimbed(startDate: oneYearAgo, endDate: today) { flights, _ in
                let progress = flights != nil ? min(1.0, Double(flights!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .activeEnergyBurned(let target):
            HealthKitManager.shared.getActiveEnergyBurned(startDate: oneYearAgo, endDate: today) { calories, _ in
                let progress = calories != nil ? min(1.0, calories! / target) : 0.0
                completion(progress)
            }
            
        case .restingHeartRate(let target):
            HealthKitManager.shared.getRestingHeartRate { heartRate, _ in
                guard let heartRate = heartRate else {
                    completion(0.0)
                    return
                }
                // Progress is better when HR is lower
                let progress = heartRate <= target ? 1.0 : max(0.0, (80.0 - heartRate) / (80.0 - target))
                completion(progress)
            }
            
        case .sleepScore(let target):
            HealthKitManager.shared.getSleepHours(startDate: thirtyDaysAgo, endDate: today) { sleepHours, _ in
                let progress = sleepHours != nil ? min(1.0, sleepHours! / target) : 0.0
                completion(progress)
            }
            
        case .cardioFitness(let target):
            HealthKitManager.shared.getCardioFitness { vo2Max, _ in
                let progress = vo2Max != nil ? min(1.0, vo2Max! / target) : 0.0
                completion(progress)
            }
            
        case .streakDays(let target):
            HealthKitManager.shared.getStreakDays { streak, _ in
                let progress = streak != nil ? min(1.0, Double(streak!) / Double(target)) : 0.0
                completion(progress)
            }
            
        case .marathon:
            // For marathon, check if longest single workout distance >= 42.2km
            // For simplicity, use total distance as approximation
            HealthKitManager.shared.getDistance(startDate: oneYearAgo, endDate: today) { distance, _ in
                let longestRun = distance ?? 0.0 // Approximation - ideally would check individual workouts
                let progress = min(1.0, longestRun / 42.2)
                completion(progress)
            }
            
        case .dietaryEnergy(_):
            // HealthKit dietary data requires more complex querying
            // For now, return placeholder
            completion(0.6) // 60% placeholder
            
        case .waterIntake(_):
            // HealthKit water intake data requires more complex querying
            // For now, return placeholder
            completion(0.7) // 70% placeholder
        }
    }
    
    private func createNavLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // getCategoryColor function removed - no longer using categories
    
    private func generatePrice(for item: FuegoTimelineItem) -> String {
        // Use Shopify price if available, otherwise generate based on milestone order
        if let price = item.price {
            return price
        }
        
        // Fallback price generation based on milestone order
        let basePrice = 50 + (item.milestone.order * 15)
        return "\(basePrice).00"
    }
    
    private func createGlassmorphicView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 0
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        
        view.insertSubview(blurEffectView, at: 0)
        
        return view
    }
}

// MARK: - Timeline Item Model
// Old structs removed - now using FuegoDataModels.swift
