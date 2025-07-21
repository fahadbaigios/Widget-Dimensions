//
//  BSWidgetSampleExtension.swift
//  BSWidgetSampleExtension
//
//  Created by Fahad Baig on 12/07/2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
//        print("widht is ==> \(context.displaySize.width) && height is ==> \(context.displaySize.height)")
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct BSWidgetSampleExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            let widgetSize = geometry.size
            let sizeCategory = determineSizeCategory(width: widgetSize.width, height: widgetSize.height)
            
            VStack {
                Text("Time:")
                Text(entry.date, style: .time)

                Text("Favorite Emoji:")
                Text(entry.configuration.favoriteEmoji)
                
                // Display size information for testing
                VStack {
                    Text("Size: \(Int(widgetSize.width))×\(Int(widgetSize.height))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Home Screen: \(sizeCategory)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                let currentTime = Date().timeIntervalSince1970
                let area = widgetSize.width * widgetSize.height
                
                // Store the most recent size measurement with timestamp
                UserDefaults.standard.set(area, forKey: "currentWidgetArea")
                UserDefaults.standard.set(currentTime, forKey: "lastMeasurementTime")
                UserDefaults.standard.set(sizeCategory, forKey: "currentSizeSetting")
                
                print("📱 Widget rendered: \(Int(widgetSize.width))×\(Int(widgetSize.height)) (\(sizeCategory)) at \(Date())")
                
                // Show the current stored setting
                let storedSetting = UserDefaults.standard.string(forKey: "currentSizeSetting") ?? "Unknown"
                print("🎯 Current user setting: \(storedSetting)")
            }
        }
    }
    
    private func determineSizeCategory(width: CGFloat, height: CGFloat) -> String {
        // Based on actual measurements:
        // Large: 317×133 = 42,161 area
        // Small: 306×126 = 38,556 area
        let area = width * height
        
        if area < 40000 {
            return "Small"
        } else {
            return "Large"
        }
    }
    
    // Function to get the most reliable current user setting
    static func getCurrentHomeScreenSetting() -> String {
        return UserDefaults.standard.string(forKey: "currentSizeSetting") ?? "Unknown"
    }
}

struct BSWidgetSampleExtension: Widget {
    let kind: String = "BSWidgetSampleExtension"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BSWidgetSampleExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
            
        }
        .supportedFamilies([.systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview("Widget Preview", as: .systemMedium) {
    BSWidgetSampleExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent.smiley)
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent.starEyes)
}
