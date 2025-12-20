# UnlockEngine

**Domain-agnostic milestone-driven commerce framework**

Transform any business into an achievement-based shopping experience. UnlockEngine lets you gate products behind milestones, creating engagement-driven retail experiences across any vertical.

## What is UnlockEngine?

UnlockEngine is a complete framework that abstracts the milestone-driven retail pattern pioneered by platforms like FUEGO. It allows businesses in any industry to create engaging shopping experiences where customers unlock products by achieving milestones.

### Key Features

- **Domain-Agnostic**: Works for fitness, gaming, fashion, education, or any vertical
- **Flexible Metrics**: Track anything - steps, purchases, game levels, learning modules
- **Multi-Platform**: Web, iOS, and Shopify extension
- **Customizable**: Full control over branding, tiers, and unlock logic
- **Scalable**: Built for businesses of any size
- **Developer-Friendly**: Clean APIs, comprehensive SDKs, detailed docs

## Architecture

```
UnlockEngine/
├── core/                    # TypeScript SDK (universal)
├── admin/                   # Admin dashboard (Next.js)
├── customer-app/            # Customer webapp template (Next.js)
├── ios-sdk/                 # iOS Swift Package
├── shopify-extension/       # Shopify App Extension
└── docs/                    # Documentation
```

## Quick Start

### 1. Install Core SDK

```bash
npm install @unlockengine/core
```

### 2. Configure Your Domain

```typescript
import UnlockEngineClient from '@unlockengine/core';

const client = new UnlockEngineClient({
  tenantId: 'your-tenant-id',
  apiKey: 'your-api-key',
});
```

### 3. Define Metrics

```typescript
const metric = {
  id: 'daily-steps',
  name: 'Daily Steps',
  source: MetricSource.HEALTH_KIT,
  dataType: MetricDataType.NUMBER,
  unit: 'steps',
};
```

### 4. Create Milestones

```typescript
const milestone = {
  id: 'bronze-achievement',
  name: 'Bronze Achievement',
  requirements: [
    {
      metricId: 'daily-steps',
      operator: ComparisonOperator.GREATER_THAN_OR_EQUAL,
      targetValue: 10000,
    },
  ],
  rewardProductIds: ['product-123'],
};
```

### 5. Deploy

Deploy the admin dashboard, customer app, or integrate into your existing platforms.

## Use Cases

### Fitness & Wellness
Track workouts, steps, calories → Unlock premium gear, supplements, coaching

**Example**: FUEGO - Complete running milestones to unlock limited-edition apparel

### Gaming
Track achievements, levels, scores → Unlock merch, DLC, exclusive items

**Example**: Complete game challenges to unlock branded merchandise

### Fashion
Track purchases, loyalty, social engagement → Unlock exclusive collections

**Example**: Spend $500 to unlock access to luxury tier with rare pieces

### Education
Track course completion, quiz scores, certifications → Unlock resources, tools

**Example**: Complete 10 courses to unlock professional certification materials

### Creator Economy
Track subscribers, engagement, content creation → Unlock tools, features

**Example**: Hit 1K subscribers to unlock premium creator tools

## Components

### Core SDK (@unlockengine/core)

Universal TypeScript library with:
- Type-safe API client
- Evaluation engine (client-side milestone checking)
- Product unlock manager
- Caching & offline support

### Admin Dashboard

Next.js webapp for configuring:
- Domain settings (vertical, branding)
- Metric definitions
- Milestone tiers and requirements
- Product mappings
- Shopify integration

### Customer App Template

Customizable Next.js template with:
- Milestone timeline visualization
- Product catalog with lock states
- Progress tracking
- Shopify checkout integration

### iOS SDK

Swift Package with:
- HealthKit integration
- Offline evaluation
- Live Activities & Widgets
- SwiftUI components

### Shopify Extension

Official Shopify app with:
- Product unlock configuration
- Customer progress display
- Checkout integration
- Admin product management

## Domain Configuration

UnlockEngine supports any vertical out of the box:

```typescript
const domains = {
  fitness: {
    metrics: ['steps', 'distance', 'workouts', 'calories'],
    tiers: ['Rookie', 'Athlete', 'Pro', 'Legend'],
  },
  gaming: {
    metrics: ['achievements', 'levels', 'playtime', 'wins'],
    tiers: ['Bronze', 'Silver', 'Gold', 'Platinum'],
  },
  fashion: {
    metrics: ['purchases', 'loyalty-points', 'social-engagement'],
    tiers: ['Essential', 'Premium', 'Luxury', 'Exclusive'],
  },
  education: {
    metrics: ['courses-completed', 'quiz-scores', 'certifications'],
    tiers: ['Student', 'Scholar', 'Expert', 'Master'],
  },
  custom: {
    metrics: ['your-custom-metrics'],
    tiers: ['your-custom-tiers'],
  },
};
```

## Data Flow

```
1. User performs action (workout, purchase, game level)
      ↓
2. Metric data sent to UnlockEngine API
      ↓
3. Evaluation engine checks milestone requirements
      ↓
4. Milestone unlocked → Product becomes available
      ↓
5. User can purchase unlocked product
      ↓
6. Checkout via Shopify or custom platform
```

## Deployment

### Admin Dashboard

```bash
cd admin
npm install
npm run build
vercel deploy
```

### Customer App

```bash
cd customer-app
npm install
npm run build
vercel deploy
```

### Shopify Extension

```bash
cd shopify-extension
npm install
shopify app deploy
```

### iOS SDK

Add to your Xcode project:

```swift
dependencies: [
    .package(url: "https://github.com/unlockengine/ios-sdk", from: "1.0.0")
]
```

## Documentation

- [Getting Started](./docs/getting-started.md)
- [Core SDK Reference](./core/README.md)
- [Admin Dashboard Guide](./admin/README.md)
- [iOS SDK Guide](./ios-sdk/README.md)
- [Shopify Extension Guide](./shopify-extension/README.md)
- [API Reference](./docs/api-reference.md)
- [Examples](./docs/examples.md)

## Examples

See the `/examples` directory for complete implementations:

- **Fitness Store**: FUEGO-style running milestone store
- **Gaming Merch**: Unlock merch by completing game achievements
- **Fashion Loyalty**: Exclusive collections based on purchase history
- **Learning Platform**: Unlock resources by completing courses

## Pricing Model

UnlockEngine is designed to be sold as a SaaS platform:

- **Starter**: $99/month - Up to 1,000 active users
- **Growth**: $299/month - Up to 10,000 active users
- **Enterprise**: Custom pricing - Unlimited users, white-label

## Business Model

1. **SaaS Licensing**: Monthly subscription for platform access
2. **Shopify App**: Revenue share via Shopify App Store
3. **Custom Development**: Professional services for custom implementations
4. **Transaction Fees**: Optional percentage of unlocked product sales

## Technology Stack

- **Frontend**: Next.js 14, React 18, TypeScript, Tailwind CSS
- **Mobile**: Swift, SwiftUI, HealthKit
- **Backend**: Node.js (optional - can be serverless)
- **Commerce**: Shopify Storefront & Admin APIs
- **Database**: Any (Postgres, MongoDB, Supabase recommended)
- **Deployment**: Vercel, AWS, or any cloud provider

## Contributing

UnlockEngine is designed to be extensible:

- Add new metric sources (Fitbit, Garmin, custom APIs)
- Create domain templates
- Build custom UI components
- Contribute examples

## Support

- Documentation: https://docs.unlockengine.io
- GitHub Issues: https://github.com/unlockengine/unlockengine
- Discord: https://discord.gg/unlockengine
- Email: support@unlockengine.io

## License

MIT License - See [LICENSE](./LICENSE) for details

## Acknowledgments

Built from the groundbreaking work of platforms like FUEGO, proving that milestone-driven commerce creates unprecedented engagement and loyalty.

---

**Built to unlock the future of commerce.**
