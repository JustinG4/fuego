import Foundation

// MARK: - Simple Shopify Service
class SimpleShopifyService {
    static let shared = SimpleShopifyService()
    
    private init() {}
    
    // MARK: - Test Admin API Connection
    func testAdminConnection() async -> Bool {
        let url = "\(ShopifyConfig.adminURL)/shop.json"
        
        print("🔧 Debug Info:")
        print("   Store Domain: \(ShopifyConfig.storeDomain)")
        print("   Admin URL: \(ShopifyConfig.adminURL)")
        print("   Full URL: \(url)")
        print("   Access Token: \(String(ShopifyConfig.adminAccessToken.prefix(20)))...")
        
        guard let requestURL = URL(string: url) else {
            print("❌ Invalid URL: \(url)")
            return false
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ShopifyConfig.adminAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Shopify Admin API Response: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("✅ Connection successful!")
                        print("📊 Response preview: \(String(responseString.prefix(200)))...")
                        return true
                    }
                } else {
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Error details: \(responseString)")
                    }
                }
            }
        } catch {
            print("❌ Network error: \(error)")
        }
        
        return false
    }
    
    // MARK: - Get Products (Simple)
    func getProducts() async -> [ShopifyProduct]? {
        let url = "\(ShopifyConfig.adminURL)/products.json?limit=10"
        
        guard let requestURL = URL(string: url) else {
            print("❌ Invalid URL: \(url)")
            return nil
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ShopifyConfig.adminAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                
                let productsResponse = try JSONDecoder().decode(ProductsResponse.self, from: data)
                print("✅ Fetched \(productsResponse.products.count) products")
                
                // Print first product as example
                if let firstProduct = productsResponse.products.first {
                    print("📦 Sample Product:")
                    print("   ID: \(firstProduct.id)")
                    print("   Title: \(firstProduct.title)")
                    print("   Handle: \(firstProduct.handle)")
                    print("   Price: $\(firstProduct.variants.first?.price ?? "N/A")")
                }
                
                return productsResponse.products
            }
        } catch {
            print("❌ Error fetching products: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Generate Storefront Access Token
    func generateStorefrontToken() async -> String? {
        let url = "\(ShopifyConfig.adminURL)/storefront_access_tokens.json"
        
        guard let requestURL = URL(string: url) else {
            print("❌ Invalid URL: \(url)")
            return nil
        }
        
        let tokenRequest = [
            "storefront_access_token": [
                "title": "FUEGO Mobile App"
            ]
        ]
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ShopifyConfig.adminAccessToken, forHTTPHeaderField: "X-Shopify-Access-Token")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: tokenRequest)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 201 {
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tokenData = json["storefront_access_token"] as? [String: Any],
                   let accessToken = tokenData["access_token"] as? String {
                    
                    print("✅ Generated Storefront Access Token!")
                    print("🔑 Token: \(accessToken)")
                    return accessToken
                }
            } else {
                print("❌ Failed to create Storefront token")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Error: \(responseString)")
                }
            }
        } catch {
            print("❌ Error generating token: \(error)")
        }
        
        return nil
    }
}

// MARK: - Simple Data Models
struct ProductsResponse: Codable {
    let products: [ShopifyProduct]
}

struct ShopifyProduct: Codable {
    let id: Int
    let title: String
    let handle: String
    let body_html: String?
    let vendor: String?
    let product_type: String?
    let created_at: String
    let updated_at: String
    let published_at: String?
    let tags: String
    let status: String
    let variants: [ShopifyVariant]
}

struct ShopifyVariant: Codable {
    let id: Int
    let product_id: Int
    let title: String
    let price: String
    let sku: String?
    let inventory_quantity: Int?
}