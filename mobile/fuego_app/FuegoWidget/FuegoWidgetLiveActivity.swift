//
//  FuegoWidgetLiveActivity.swift
//  FuegoWidget
//
//  Created by Justin Greenfield on 12/11/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Shared Activity Attributes
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
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if hours > 0 {
                return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
            } else if minutes > 0 {
                return "\(minutes)m"
            } else {
                return "0m"
            }
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
struct FuegoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GymActivityAttributes.self) { context in
            // Lock screen/banner UI - Nike Run Club style with darker red background
            VStack(spacing: 12) {
                // Top section with flame logo in top right like Nike
                HStack {
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Main content section
                VStack(spacing: 8) {
                    HStack {
                        // Large time display like "2.94 Miles"
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.displayTime)
                                .font(.system(size: 34, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                            Text("Time")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Right side - Just FUEGO branding (no duplicate status)
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("FUEGO")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Progress bar - thick like Nike
                    ProgressView(value: min(Date().timeIntervalSince(context.state.sessionStartTime) / 3600, 1.0))
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .scaleEffect(x: 1, y: 2.5, anchor: .center)
                }
                
                // Bottom section with gym name only
                HStack {
                    Text(context.state.gymName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black, Color(red: 0.8, green: 0.0, blue: 0.0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .activityBackgroundTint(Color(red: 0.8, green: 0.0, blue: 0.0))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI - Nike style
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                        Text("FUEGO")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.displayTime)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Time")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        Text(context.state.gymName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // Thick progress bar like Nike
                        ProgressView(value: min(Date().timeIntervalSince(context.state.sessionStartTime) / 3600, 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    }
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            } compactTrailing: {
                Text(context.state.displayTime)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
            } minimal: {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)
            }
            .keylineTint(Color.red)
        }
    }
}

@available(iOS 16.1, *)
extension GymActivityAttributes {
    fileprivate static var preview: GymActivityAttributes {
        GymActivityAttributes(gymId: "test_gym_001", appName: "FUEGO")
    }
}

@available(iOS 16.1, *)
extension GymActivityAttributes.ContentState {
    fileprivate static var activeSession: GymActivityAttributes.ContentState {
        GymActivityAttributes.ContentState(
            gymName: "Planet Fitness",
            isInRange: true,
            timeElapsed: "15m",
            sessionStartTime: Date().addingTimeInterval(-900) // 15 minutes ago
        )
    }
     
    fileprivate static var endedSession: GymActivityAttributes.ContentState {
        GymActivityAttributes.ContentState(
            gymName: "Gold's Gym",
            isInRange: false,
            timeElapsed: "45m",
            sessionStartTime: Date().addingTimeInterval(-2700) // 45 minutes ago
        )
    }
}

// MARK: - Widget Extensions

// MARK: - Widget Preview Extensions

#Preview("Notification", as: .content, using: GymActivityAttributes.preview) {
   FuegoWidgetLiveActivity()
} contentStates: {
    GymActivityAttributes.ContentState.activeSession
    GymActivityAttributes.ContentState.endedSession
}