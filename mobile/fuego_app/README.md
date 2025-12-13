# FUEGO iOS Mobile App

This is the iOS mobile app for FUEGO's "Burn to Earn" fitness platform. Users track their fitness progress and unlock exclusive products through achievements.

## Features

- **Fitness Tracking**: HealthKit integration for steps, workouts, heart rate, and more
- **Milestone System**: Achievement-based product unlocks
- **Shopify Integration**: Real-time product sync from your store
- **Skeleton Loaders**: Smooth loading experience during data fetching
- **Live Activity Widget**: Workout tracking with iOS Dynamic Island
- **QR Code Scanning**: Gym check-ins and location verification
- **Social Features**: Leaderboards and progress sharing

## Setup

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ target device
- Apple Developer Account (for HealthKit entitlements)

### Configuration

1. **Shopify Credentials**: Update `fuego_app/ShopifyConfig.swift` with your actual credentials:
```swift
static let adminAPIKey = "your_actual_admin_api_key"
static let adminAccessToken = "your_actual_admin_access_token"  
static let apiSecret = "your_actual_api_secret"
static let storefrontAccessToken = "your_actual_storefront_token"
```

2. **HealthKit Permissions**: The app is configured for:
   - Steps and distance tracking
   - Workout monitoring
   - Heart rate data
   - Active calories burned
   - Sleep tracking

3. **Entitlements**: Already configured in `fuego_app.entitlements`:
   - HealthKit access
   - Live Activity widget support
   - Push notifications

### Building

1. Open `fuego_app.xcodeproj` in Xcode
2. Update bundle identifier for your Apple Developer account
3. Configure signing with your team
4. Update Shopify credentials in `ShopifyConfig.swift`
5. Build and run on device (required for HealthKit)

## App Architecture

### Key Files

- **`ViewController.swift`**: Main timeline view with skeleton loaders
- **`FuegoDataModels.swift`**: Data models for milestones and products
- **`ShopifyConfig.swift`**: Shopify API configuration
- **`SimpleShopifyService.swift`**: Shopify integration service
- **`MILESTONE_MANAGEMENT.md`**: Guide for updating achievements

### Skeleton Loader Implementation

The app features smooth skeleton loaders during Shopify data fetching:
- Matches exact design of product cards
- Shimmer animations for polished UX
- Seamless transition to real data
- Glassmorphic design matching brand guidelines

### Milestone System

Users unlock products by achieving fitness goals:
- Daily step targets
- Distance milestones  
- Workout completions
- Health metrics (heart rate, VO2 max)
- Gym visit tracking
- Sleep score achievements

## Security Notes

**Important**: Never commit actual API keys or secrets to version control. The current `ShopifyConfig.swift` uses placeholder values that must be replaced with your actual credentials locally.

For production apps, consider:
- Using iOS Keychain for credential storage
- Server-side API proxy for sensitive operations
- Environment-specific configuration files
- CI/CD secrets management

## Support

For milestone management and product configuration, see `MILESTONE_MANAGEMENT.md`.

For Shopify setup, see the main project's `SHOPIFY_SETUP.md`.