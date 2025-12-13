# 🏆 FUEGO Milestone Management Guide

## Overview

The FUEGO app uses a milestone system that tracks user achievements and rewards them with product unlocks from your Shopify store. This guide explains how to manage milestones and link them to products.

## Current Milestone Structure

Milestones are defined in `FuegoDataModels.swift` in the `FallbackData.sampleMilestones` array. Each milestone has:

- **ID**: Unique identifier
- **Title**: Fallback name (replaced by Shopify product title when linked)
- **Description**: The challenge/achievement requirement
- **Health Metric**: What health data to track
- **Required Value**: The target value to unlock
- **Unlock Status**: Whether it's currently unlocked
- **Reward Product ID**: Links to specific Shopify product
- **Order**: Display order in the timeline

## Current Milestones

| ID | Title | Description | Health Metric | Required Value |
|----|-------|-------------|---------------|----------------|
| 1 | SPARK Starter Tee | Walk 50,000 steps in a single day | Daily Steps | 50,000 |
| 2 | SPARK Foundation Shorts | Burn 5,000 active calories | Active Energy | 5,000 |
| 3 | FLAME Performance Tank | Run 25km total distance | Distance | 25.0 km |
| 4 | FLAME Gym Warrior Tee | Visit gym or fitness center 10 times | Gym Visits | 10 |
| 5 | FLAME Speed Shorts | Complete 150 exercise minutes | Exercise Time | 150 min |
| 6 | FLAME Recovery Hoodie | Climb 500 flights of stairs | Flights Climbed | 500 |
| 7 | INFERNO Elite Kit | Run 100km total distance | Distance | 100.0 km |
| 8 | INFERNO Carbon Jacket | Achieve 8hrs sleep for 30 days | Sleep Score | 240 hrs |
| 9 | INFERNO Victory Pants | Maintain <60bpm resting HR | Resting HR | 60 bpm |
| 10 | LEGEND Champion Jersey | Complete a full marathon | Marathon | 42.2 km |
| 11 | LEGEND Crown Cap | Achieve VO2 Max >45 | Cardio Fitness | 45.0 |
| 12 | LEGEND Mythical Set | Complete 100 total workouts | Workouts | 100 |
| 13 | LEGEND Hall of Fame | Maintain 6 month streak | Streak Days | 180 |

## How to Update Milestones

### 1. Modify Existing Milestones

Edit the milestone in `FuegoDataModels.swift`:

```swift
Milestone(
    id: 1,
    title: "New Product Name", // This gets replaced by Shopify product
    description: "Walk 75,000 steps in a single day", // Update challenge
    healthMetric: .dailySteps(75000), // Update metric
    requiredValue: 75000, // Update target
    isUnlocked: false, // Update status
    rewardProductId: 123, // Link to Shopify product ID
    order: 1
)
```

### 2. Add New Milestones

Add new milestone to the array:

```swift
Milestone(
    id: 14, // New unique ID
    title: "New Challenge",
    description: "Your new challenge description",
    healthMetric: .steps(10000), // Choose appropriate metric
    requiredValue: 10000,
    isUnlocked: false,
    rewardProductId: nil, // Optional: link to product
    order: 14
)
```

### 3. Link Milestones to Shopify Products

#### Method 1: By Product ID
Set `rewardProductId` to match your Shopify product ID:

```swift
rewardProductId: 123 // Must match Shopify product.id
```

#### Method 2: By Order (Automatic)
If `rewardProductId` is `nil`, the system automatically assigns products based on milestone order. The first milestone gets the first Shopify product, second gets second, etc.

### 4. Available Health Metrics

```swift
.dailySteps(target)        // Steps in one day
.distance(target)          // Total distance in km
.activeEnergyBurned(target) // Calories burned
.exerciseMinutes(target)   // Exercise time in minutes
.gymVisits(target)         // Gym check-ins
.flightsClimbed(target)    // Stairs climbed
.workouts(target)          // Total workouts completed
.sleepScore(target)        // Sleep hours (target = hours * 30)
.restingHeartRate(target)  // Resting heart rate BPM
.cardioFitness(target)     // VO2 max score
.streakDays(target)        // Consecutive active days
.marathon                  // Special: complete 42.2km
```

### 5. Product Assignment Logic

The `FuegoDataManager` handles product assignment:

1. **Specific Assignment**: If `rewardProductId` is set, uses that exact product
2. **Automatic Assignment**: If `rewardProductId` is `nil`, assigns by order
3. **Fallback**: If no product available, uses milestone title as product name

### 6. Updating Product Display

When Shopify products are loaded:
- **Product Title**: Replaces milestone title in UI
- **Product Price**: Shows actual Shopify price
- **Product Images**: Can be added to display product photos
- **Milestone Description**: Always shows the achievement challenge

## Example: Adding a New Milestone

```swift
// Add this to FallbackData.sampleMilestones array
Milestone(
    id: 15,
    title: "Ultra Runner Tee", // Fallback name
    description: "Run 200km total distance", // Challenge
    healthMetric: .distance(200.0), // Health metric
    requiredValue: 200.0, // Target value
    isUnlocked: false, // Initial status
    rewardProductId: 456, // Link to Shopify product ID 456
    order: 15 // Display order
)
```

## Testing Changes

1. Update the milestone array in `FuegoDataModels.swift`
2. Run the app and go to the Burn tab
3. Check console for Shopify product sync logs
4. Verify milestones display correctly with product data

## Advanced Features

### Custom Milestone Categories
The old SPARK/FLAME/INFERNO/LEGEND categories have been removed. You can create your own logic by:

1. Adding category field to `Milestone` struct
2. Using category for styling/grouping
3. Filtering products by category

### Dynamic Unlocking
Milestones automatically check health data and unlock when targets are met. The unlock logic is in `checkMilestoneProgress()` method.

### Progress Tracking
Real-time progress tracking shows how close users are to unlocking each milestone.

---

**Need to modify milestone behavior?** Edit the `FuegoDataManager` class in `FuegoDataModels.swift`.

**Need to change unlock criteria?** Update the health metrics and required values in the milestone definitions.