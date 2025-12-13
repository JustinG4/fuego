import Foundation

// MARK: - Shopify Configuration
struct ShopifyConfig {
    // Your Shopify credentials - these should be set via environment variables or config
    static let storeDomain = "fuego-10038.myshopify.com"
    static let adminAPIKey = "YOUR_ADMIN_API_KEY"  // Replace with your actual key
    static let adminAccessToken = "YOUR_ADMIN_ACCESS_TOKEN"  // Replace with your actual token
    static let apiSecret = "YOUR_API_SECRET"  // Replace with your actual secret
    static let apiVersion = "2023-10"
    
    // Storefront API token (for mobile app GraphQL queries)
    static let storefrontAccessToken = "YOUR_STOREFRONT_ACCESS_TOKEN"  // Replace with your actual token
    
    // Computed URLs
    static var adminURL: String {
        return "https://\(storeDomain)/admin/api/\(apiVersion)"
    }
    
    static var storefrontURL: String {
        return "https://\(storeDomain)/api/\(apiVersion)/graphql.json"
    }
}