# FUEGO

## Description

An innovative "Burn to Earn" fitness-fashion ecommerce platform that combines fitness tracking with earned commerce. Operating on the tagline "You can't *Drip* without *Sweat*", FUEGO is a milestone-verified commerce engine where users must complete fitness challenges to unlock exclusive fashion products - the world's first earned commerce platform for athletic wear and streetwear.

## Goal

Create a comprehensive fitness-driven ecommerce platform that gamifies fashion purchasing through achievement-based product unlocking, combining health motivation with exclusive streetwear access.

## Status

- **Stage:** active
- **Priority:** high
- **Owner:** Justin
- **Target date:** TBD
- **Last human update:** 2024-12-13

## Scope

### In Scope

- Milestone-verified commerce engine with fitness tracking integration
- Native iOS app with Apple HealthKit integration for comprehensive fitness tracking
- Responsive Next.js web platform with Shopify Storefront API integration
- Real-time progress tracking through Apple Health and gym check-ins
- Achievement-based product access using dynamic Shopify tagging system
- Interactive product customization with unlockable options

### Out of Scope

- Android app development (iOS first approach)
- Third-party fitness tracker integration beyond Apple ecosystem
- Social media platform features
- Marketplace for user-generated products
- Subscription-based fitness content
- Basic leaderboard and social features

## Milestones

- [x] Core Next.js web platform with Shopify integration
- [x] Native iOS app with HealthKit integration
- [x] Achievement-based product unlocking system
- [x] Real-time fitness tracking and milestone verification
- [x] QR code gym check-in system
- [ ] Counter-culture magnetic flame patching integration & mockup image
- [x] Netted Flame Rip Sweats integration & mockup image
- [ ] Comprehensive design spec book with designs, measurements, materials, & sourcing
- [ ] Custom Prototyping (get clothing item custom created and shipped)
- [ ] QC and product design iteration
- [ ] Custom Packing
- [ ] Reactivate Shopify
- [ ] Investigate licenses and requirements for selling clothes
- [ ] Apply for LA Trading Post stall
- [ ] Gym Partnership (John Reed, Equinox)
- [ ] Paris Fashion Week Appearance 

## Tasks

### Now

- [ ] Clear the pending iOS skeleton loader issue called out in the 2026-05-07 PM note
- [ ] Commit and push the current working tree changes so implementation can move forward from a clean baseline
- [ ] Start the counter-culture magnetic flame patching integration

### Next

- [ ] Define the magnetic flame patch product behavior, unlock requirements, and Shopify tagging model
- [ ] Build the counter-culture magnetic flame patching ecommerce flow across web and iOS
- [ ] Run unit tests and a focused smoke test around unlock, product detail, and cart flows

### Later

- [ ] Complete the design spec book with designs, measurements, materials, and sourcing
- [ ] Add basic leaderboard and social features
- [ ] Produce the v1 real product prototype

### Done

- [x] Built responsive Next.js ecommerce platform
- [x] Integrated Shopify Storefront API with GraphQL
- [x] Created native iOS app with SwiftUI
- [x] Implemented Apple HealthKit integration
- [x] Built achievement-based unlocking system
- [x] Added QR code gym check-in functionality
- [x] Created interactive product modals and cart system
- [x] Implemented glassmorphic design system

## Blockers

- None

## Risks

- **Risk:** Apple HealthKit data accuracy and availability
  **Impact:** Inconsistent fitness milestone verification
  **Mitigation:** Implement multiple verification methods and manual override options

- **Risk:** Shopify API rate limiting during high traffic
  **Impact:** Poor user experience during product browsing
  **Mitigation:** Implement caching strategies and fallback to mock data

## Decisions

- **2024-12-13:** iOS-first approach with Apple HealthKit for fitness tracking
- **2024-12-13:** Using Shopify headless architecture for custom frontend control
- **2024-12-13:** Implementing milestone system through dynamic product tagging

## Notes

The platform uses Next.js 14.0.3 with TypeScript and Tailwind CSS for the web application. Native iOS app built with SwiftUI and comprehensive HealthKit integration. Features include steps, workouts, heart rate monitoring, active calories, sleep tracking, and gym location verification. The earned commerce model creates a unique intersection of fitness motivation and exclusive fashion retail.

## Agent Review Log

Agent appends below this line. Do not manually edit old entries unless correcting factual errors.

---
## Atlas PM Review - 2026-05-03 18:04 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

## Atlas PM Review - 2026-05-03 18:18 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

## Atlas PM Review - 2026-05-03 19:23 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

## Atlas PM Review - 2026-05-03 20:53 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
At 76% complete, the project is stalled by pending commits and an unchanged sync status; pushing updates will unlock the next integration phase.

## Atlas PM Review - 2026-05-03 21:11 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
Pushing a clean commit and establishing a proper history is essential before the patch integration can proceed.

## Atlas PM Review - 2026-05-03 21:23 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
Progress stuck at 76% and the working tree is dirty; a quick commit and review of the 5-month-old iOS work should clear the path to the magnetic flame patching integration.

## Atlas PM Review - 2026-05-04 11:10 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
Fuego is also flat at 76%. Commit the pending changes and push them, then start the counter-culture magnetic flame patching integration.

## Atlas PM Review - 2026-05-06 07:33 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
76% and flat. Finish the counter-culture patch integration and push a fresh commit.

## Atlas PM Review - 2026-05-06 09:30 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
With uncommitted changes, the project can't advance; create a feature branch, implement the flame patch integration, and run the full test suite.

## Atlas PM Review - 2026-05-06 09:31 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
needs attention; stop admiring the backlog and move Counter-culture magnetic flame patching integration forward with a concrete commit.

## Atlas PM Review - 2026-05-07 09:01 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
The project sits at 76% with the Counter-culture patch yet to roll out; first clear the iOS skeleton loader bug and then integrate the patch.

## Atlas PM Review - 2026-05-08 09:01 PDT

- **Progress:** 76% complete
- **Git:** `356d893` Add complete iOS mobile app with skeleton loader and security (5 months ago); working tree has uncommitted changes; sync up to date with origin/main
- **Tasks:** 13 done, 4 open
- **Assessment:** needs attention
- **Next steps:**
  - Counter-culture magnetic flame patching integration
  - Comprehensive design spec book with designs, measurements, materials, & sourcing
  - Basic leaderboard and social features
  - v1 real product prototype

### PM Note
Integration of the magnetic flame patching is key to finalising the feature set; push the last commit to main and start unit tests.
