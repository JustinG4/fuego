import Foundation

// MARK: - FUEGO Data Models

// MARK: - Health Metric Types
enum HealthMetricType {
    case workouts(Int)
    case distance(Double) // km
    case steps(Int)
    case dailySteps(Int) // daily step target
    case streakDays(Int)
    case marathon
    case flightsClimbed(Int)
    case exerciseMinutes(Int)
    case restingHeartRate(Double) // bpm
    case dietaryEnergy(Double) // kcal
    case waterIntake(Double) // liters
    case sleepScore(Double) // hours
    case cardioFitness(Double) // VO2 max
    case activeEnergyBurned(Double) // kcal
    case gymVisits(Int) // gym attendance count
}

// MARK: - Milestone (Achievement/Goal)
struct Milestone {
    let id: Int
    let title: String
    let description: String
    let healthMetric: HealthMetricType
    let requiredValue: Double
    let isUnlocked: Bool
    let rewardProductId: Int? // Links to Shopify product ID
    let order: Int
}

// MARK: - Timeline Item (combines milestone + product)
struct FuegoTimelineItem {
    let milestone: Milestone
    let product: ShopifyProduct?
    
    var isUnlocked: Bool {
        return milestone.isUnlocked
    }
    
    var title: String {
        return product?.title ?? milestone.title
    }
    
    var description: String {
        return milestone.description
    }
    
    var price: String? {
        return product?.variants.first?.price
    }
    
    var imageURL: String? {
        return product?.variants.first { !$0.title.isEmpty }?.title // We'll need proper image handling
    }
}

// MARK: - Fallback Sample Data
struct FallbackData {
    static let sampleMilestones: [Milestone] = [
        Milestone(id: 1, title: "SPARK Starter Tee", description: "Walk 50,000 steps in a single day", healthMetric: HealthMetricType.dailySteps(50000), requiredValue: 50000, isUnlocked: true, rewardProductId: nil, order: 1),
        Milestone(id: 2, title: "SPARK Foundation Shorts", description: "Burn 5,000 active calories", healthMetric: HealthMetricType.activeEnergyBurned(5000), requiredValue: 5000, isUnlocked: true, rewardProductId: nil, order: 2),
        Milestone(id: 3, title: "FLAME Performance Tank", description: "Run 25km total distance", healthMetric: HealthMetricType.distance(25.0), requiredValue: 25.0, isUnlocked: true, rewardProductId: nil, order: 3),
        Milestone(id: 4, title: "FLAME Gym Warrior Tee", description: "Visit gym or fitness center 10 times", healthMetric: HealthMetricType.gymVisits(10), requiredValue: 10, isUnlocked: false, rewardProductId: nil, order: 4),
        Milestone(id: 5, title: "FLAME Speed Shorts", description: "Complete 150 exercise minutes", healthMetric: HealthMetricType.exerciseMinutes(150), requiredValue: 150, isUnlocked: false, rewardProductId: nil, order: 5),
        Milestone(id: 6, title: "FLAME Recovery Hoodie", description: "Climb 500 flights of stairs", healthMetric: HealthMetricType.flightsClimbed(500), requiredValue: 500, isUnlocked: false, rewardProductId: nil, order: 6),
        Milestone(id: 7, title: "INFERNO Elite Kit", description: "Run 100km total distance", healthMetric: HealthMetricType.distance(100.0), requiredValue: 100.0, isUnlocked: false, rewardProductId: nil, order: 7),
        Milestone(id: 8, title: "INFERNO Carbon Jacket", description: "Achieve 8hrs sleep for 30 days", healthMetric: HealthMetricType.sleepScore(240.0), requiredValue: 240.0, isUnlocked: false, rewardProductId: nil, order: 8),
        Milestone(id: 9, title: "INFERNO Victory Pants", description: "Maintain <60bpm resting HR", healthMetric: HealthMetricType.restingHeartRate(60.0), requiredValue: 60.0, isUnlocked: false, rewardProductId: nil, order: 9),
        Milestone(id: 10, title: "LEGEND Champion Jersey", description: "Complete a full marathon", healthMetric: HealthMetricType.marathon, requiredValue: 42.2, isUnlocked: false, rewardProductId: nil, order: 10),
        Milestone(id: 11, title: "LEGEND Crown Cap", description: "Achieve VO2 Max >45", healthMetric: HealthMetricType.cardioFitness(45.0), requiredValue: 45.0, isUnlocked: false, rewardProductId: nil, order: 11),
        Milestone(id: 12, title: "LEGEND Mythical Set", description: "Complete 100 total workouts", healthMetric: HealthMetricType.workouts(100), requiredValue: 100, isUnlocked: false, rewardProductId: nil, order: 12),
        Milestone(id: 13, title: "LEGEND Hall of Fame", description: "Maintain 6 month streak", healthMetric: HealthMetricType.streakDays(180), requiredValue: 180, isUnlocked: false, rewardProductId: nil, order: 13)
    ]
    
    static let sampleProducts: [ShopifyProduct] = [
        ShopifyProduct(
            id: 1,
            title: "Classic Workout Tee",
            handle: "classic-workout-tee",
            body_html: "Premium cotton workout tee",
            vendor: "FUEGO",
            product_type: "T-Shirt",
            created_at: "2023-01-01T00:00:00Z",
            updated_at: "2023-01-01T00:00:00Z",
            published_at: "2023-01-01T00:00:00Z",
            tags: "workout,tee",
            status: "active",
            variants: [
                ShopifyVariant(
                    id: 101,
                    product_id: 1,
                    title: "Medium / Black",
                    price: "29.99",
                    sku: "WORKOUT-TEE-M-BLK",
                    inventory_quantity: 100
                )
            ]
        )
    ]
}

// MARK: - Data Manager
class FuegoDataManager {
    static let shared = FuegoDataManager()
    
    private var milestones: [Milestone] = FallbackData.sampleMilestones
    private var shopifyProducts: [ShopifyProduct] = []
    private var timelineItems: [FuegoTimelineItem] = []
    
    private init() {
        generateTimelineItems()
    }
    
    func updateShopifyProducts(_ products: [ShopifyProduct]) {
        self.shopifyProducts = products
        generateTimelineItems()
    }
    
    func getTimelineItems() -> [FuegoTimelineItem] {
        return timelineItems
    }
    
    private func generateTimelineItems() {
        timelineItems = milestones.map { milestone in
            // Try to find a matching Shopify product
            let product = findMatchingProduct(for: milestone)
            return FuegoTimelineItem(milestone: milestone, product: product)
        }
    }
    
    private func findMatchingProduct(for milestone: Milestone) -> ShopifyProduct? {
        // If we have a specific product ID linked, use that
        if let productId = milestone.rewardProductId {
            return shopifyProducts.first { $0.id == productId }
        }
        
        // Otherwise, try to match by milestone order to product array position
        let index = milestone.order - 1
        guard index >= 0 && index < shopifyProducts.count else {
            return shopifyProducts.first // Fallback to first product if available
        }
        
        return shopifyProducts[index]
    }
    
    // Update milestone unlock status based on health data
    func updateMilestoneProgress(milestoneId: Int, isUnlocked: Bool) {
        if let index = milestones.firstIndex(where: { $0.id == milestoneId }) {
            let currentMilestone = milestones[index]
            milestones[index] = Milestone(
                id: currentMilestone.id,
                title: currentMilestone.title,
                description: currentMilestone.description,
                healthMetric: currentMilestone.healthMetric,
                requiredValue: currentMilestone.requiredValue,
                isUnlocked: isUnlocked,
                rewardProductId: currentMilestone.rewardProductId,
                order: currentMilestone.order
            )
            generateTimelineItems()
        }
    }
}