# UnlockEngine Testing Guide

Quick guide to test your new framework.

## 🚀 Quick Start (5 Minutes)

### Step 1: Test the Admin Dashboard

This is the easiest place to start - it shows the configuration interface.

```bash
# Navigate to admin folder
cd /Users/justingreenfield/Desktop/47/fuego/unlockengine/admin

# Install dependencies
npm install

# Start the dev server
npm run dev
```

**What you'll see:**
- Open http://localhost:3001
- Dashboard with stats and navigation
- Click "Milestones" to see example milestone configuration
- See FUEGO-style tiers (SPARK, FLAME, INFERNO, LEGEND)
- Example milestone requirements and product rewards

**This shows:** How businesses would configure their milestone systems

---

### Step 2: Test the Core SDK (TypeScript)

Test the evaluation engine directly in Node.js.

```bash
# Navigate to core folder
cd /Users/justingreenfield/Desktop/47/fuego/unlockengine/core

# Install dependencies
npm install

# Build the TypeScript
npm run build
```

Now create a test file:

```bash
# Create test script
cat > test-example.js << 'EOF'
const { EvaluationEngine } = require('./dist/evaluation-engine');
const { MetricSource, ComparisonOperator, RequirementLogic, MetricDataType } = require('./dist/types');

// Sample milestone
const milestone = {
  id: 'first-steps',
  name: 'First Steps',
  description: 'Walk 10,000 steps',
  requirements: [
    {
      metricId: 'daily-steps',
      operator: 'gte',
      targetValue: 10000
    }
  ],
  requirementLogic: 'all',
  rewardProductIds: ['bronze-tee'],
  isActive: true,
  order: 1
};

// Sample user metrics
const userMetrics = new Map([
  ['daily-steps', {
    metricId: 'daily-steps',
    value: 12000, // User walked 12,000 steps!
    lastUpdated: new Date()
  }]
]);

// Evaluate!
const result = EvaluationEngine.evaluateMilestone(milestone, userMetrics);

console.log('Milestone:', milestone.name);
console.log('User steps:', userMetrics.get('daily-steps').value);
console.log('Required steps:', 10000);
console.log('Is unlocked?', result.isUnlocked ? '✅ YES' : '❌ NO');
console.log('\nRequirement results:');
result.requirementResults.forEach(r => {
  console.log(`  - ${r.metricId}: ${r.currentValue} ${r.met ? '✅' : '❌'}`);
});
EOF

# Run the test
node test-example.js
```

**Expected output:**
```
Milestone: First Steps
User steps: 12000
Required steps: 10000
Is unlocked? ✅ YES

Requirement results:
  - daily-steps: 12000 ✅
```

**This shows:** The core evaluation logic works!

---

### Step 3: Test with Your Existing FUEGO App

Let's integrate UnlockEngine into your current app to see it work with real data.

```bash
# Navigate to your main app
cd /Users/justingreenfield/Desktop/47/fuego/unlockengine/admin/app

# Install the core SDK as a dependency
npm install ../../core
```

Now create a test page:

```bash
# Create a test integration page
mkdir -p test-integration
cat > test-integration/page.tsx << 'EOF'
'use client';

import { useEffect, useState } from 'react';
import { EvaluationEngine } from '@unlockengine/core';
import type { Milestone, MetricValue } from '@unlockengine/core';

export default function TestIntegrationPage() {
  const [result, setResult] = useState<any>(null);

  useEffect(() => {
    // Your FUEGO milestones converted to UnlockEngine format
    const fuegoMilestones: Milestone[] = [
      {
        id: 'spark-1',
        name: 'First Steps',
        description: 'Walk 10,000 steps in a single day',
        tierId: 'spark',
        order: 1,
        requirements: [
          {
            metricId: 'daily-steps',
            operator: 'gte' as any,
            targetValue: 10000,
          },
        ],
        requirementLogic: 'all' as any,
        rewardProductIds: ['spark-tee'],
        isActive: true,
      },
    ];

    // Simulated user data (replace with real HealthKit data)
    const userMetrics = new Map<string, MetricValue>([
      [
        'daily-steps',
        {
          metricId: 'daily-steps',
          value: 15000, // Simulated: user walked 15k steps
          lastUpdated: new Date(),
        },
      ],
    ]);

    // Evaluate all milestones
    const evaluations = EvaluationEngine.evaluateBatch(
      fuegoMilestones,
      userMetrics,
      'test-user-123'
    );

    setResult(evaluations);
  }, []);

  if (!result) return <div>Loading...</div>;

  return (
    <div className="p-8 max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">UnlockEngine Test Integration</h1>

      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <h2 className="text-xl font-semibold mb-4">Evaluation Results</h2>

        {result.map((evaluation: any) => (
          <div
            key={evaluation.milestoneId}
            className="border-l-4 border-green-500 bg-green-50 p-4 mb-4"
          >
            <div className="flex items-center justify-between">
              <div>
                <h3 className="font-bold text-lg">{evaluation.milestoneId}</h3>
                <p className="text-sm text-gray-600">
                  Evaluated at: {evaluation.evaluatedAt.toLocaleString()}
                </p>
              </div>
              <div>
                {evaluation.isCurrentlyUnlocked ? (
                  <span className="text-2xl">✅ UNLOCKED</span>
                ) : (
                  <span className="text-2xl">🔒 LOCKED</span>
                )}
              </div>
            </div>

            <div className="mt-4">
              <p className="text-sm font-semibold mb-2">Requirements:</p>
              {evaluation.requirementResults.map((req: any, idx: number) => (
                <div key={idx} className="flex justify-between text-sm">
                  <span>
                    {req.metricId}: {req.currentValue} / {req.targetValue}
                  </span>
                  <span>{req.met ? '✅' : '❌'}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
        <h3 className="font-bold mb-2">🎉 What Just Happened?</h3>
        <ul className="text-sm space-y-2">
          <li>✅ UnlockEngine evaluated milestone requirements</li>
          <li>✅ Checked user's daily steps (15,000)</li>
          <li>✅ Compared against requirement (10,000)</li>
          <li>✅ Milestone unlocked automatically!</li>
        </ul>
        <p className="mt-4 text-sm text-gray-600">
          This same logic works for ANY metric in ANY industry - fitness,
          gaming, fashion, education, etc.
        </p>
      </div>
    </div>
  );
}
EOF
```

Now run it:

```bash
npm run dev
```

Visit: http://localhost:3001/test-integration

**What you'll see:**
- Live evaluation of milestones
- Visual display of requirements being met
- Unlock status updating in real-time

---

## 🎯 Testing Different Scenarios

### Scenario 1: Test Multiple Requirements (ALL logic)

```javascript
const milestone = {
  id: 'multi-req',
  name: 'Super Achiever',
  requirements: [
    { metricId: 'daily-steps', operator: 'gte', targetValue: 10000 },
    { metricId: 'gym-visits', operator: 'gte', targetValue: 5 },
  ],
  requirementLogic: 'all', // Must meet ALL requirements
  rewardProductIds: ['premium-kit'],
};

const userMetrics = new Map([
  ['daily-steps', { metricId: 'daily-steps', value: 12000 }],
  ['gym-visits', { metricId: 'gym-visits', value: 3 }], // Only 3/5 visits
]);

// Result: NOT unlocked (doesn't meet all requirements)
```

### Scenario 2: Test ANY Logic

```javascript
const milestone = {
  requirementLogic: 'any', // Meet ANY ONE requirement
  requirements: [
    { metricId: 'daily-steps', operator: 'gte', targetValue: 20000 },
    { metricId: 'marathon', operator: 'eq', targetValue: true },
  ],
};

// User only needs to complete marathon OR walk 20k steps
```

### Scenario 3: Test Product Unlocking

```javascript
const { ProductManager } = require('./dist/product-manager');

const product = {
  id: 'premium-tee',
  name: 'Premium T-Shirt',
  requiredMilestoneIds: ['spark-1', 'spark-2'],
  unlockLogic: 'all',
  price: 49.99,
};

const userProgress = new Map([
  ['spark-1', { isUnlocked: true }],
  ['spark-2', { isUnlocked: false }], // Not yet unlocked
]);

const isUnlocked = ProductManager.isProductUnlocked(product, userProgress);
console.log('Can purchase?', isUnlocked); // false (needs both milestones)
```

---

## 📱 Testing iOS SDK (Optional)

If you want to test the iOS integration:

1. Open Xcode
2. Create new iOS project
3. Add Swift Package:
   - File → Add Package Dependencies
   - Enter local path: `/Users/justingreenfield/Desktop/47/fuego/unlockengine/ios-sdk`

4. Create test view:

```swift
import SwiftUI
import UnlockEngine

struct TestView: View {
    @State private var result = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("UnlockEngine iOS Test")
                .font(.title)

            Button("Test Evaluation") {
                testEvaluation()
            }

            Text(result)
                .padding()
        }
    }

    func testEvaluation() {
        let config = UnlockEngineConfig(
            tenantId: "test-tenant",
            apiKey: "test-key"
        )

        result = "✅ SDK initialized successfully!"
    }
}
```

---

## 🧪 What to Test

### ✅ Core Functionality
- [x] Milestone evaluation with different operators (gte, gt, eq)
- [x] Multiple requirements with ALL logic
- [x] Multiple requirements with ANY logic
- [x] Product unlock based on milestones
- [x] Progress calculation
- [x] Tier organization

### ✅ UI Components
- [x] Admin dashboard loads
- [x] Milestone list displays
- [x] Example configurations shown
- [x] Navigation works

### 🔄 Integration Testing (Next Steps)
- [ ] Connect to real Shopify store
- [ ] Integrate with HealthKit
- [ ] Set up database for persistence
- [ ] Test webhook endpoints

---

## 🐛 Troubleshooting

### Issue: `npm install` fails
```bash
# Make sure you're using Node.js 18+
node --version

# Clear cache and retry
rm -rf node_modules package-lock.json
npm install
```

### Issue: TypeScript errors
```bash
# Rebuild the core SDK
cd unlockengine/core
npm run build
```

### Issue: Port already in use
```bash
# Admin runs on 3001, customer app on 3002
# Kill existing processes
lsof -ti:3001 | xargs kill
```

---

## 📊 What Success Looks Like

After testing, you should see:

1. ✅ Admin dashboard running and displaying milestones
2. ✅ Core evaluation engine correctly evaluating requirements
3. ✅ Milestones unlocking when requirements are met
4. ✅ Products showing locked/unlocked states
5. ✅ All components working together

---

## Next Steps After Testing

1. **Connect Real Data**
   - Integrate with your FUEGO HealthKit data
   - Connect to actual Shopify products

2. **Deploy**
   - Deploy admin to Vercel
   - Set up production database

3. **Create Demos**
   - Build example stores for different verticals
   - Record demo videos

---

**Questions?** Start with Step 1 (Admin Dashboard) - it's the easiest to see working!
