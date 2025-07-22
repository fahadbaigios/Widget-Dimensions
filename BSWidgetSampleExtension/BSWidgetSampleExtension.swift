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
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) var displayScale
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    var body: some View {
        GeometryReader { geometry in
            let widgetSize = geometry.size
            let sizeCategory = determineSizeCategory(width: widgetSize.width, height: widgetSize.height)
            
            VStack(spacing: 3) {
                // Main size indicator - prominently displayed
                Text(sizeCategory)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(sizeCategory == "Small" ? .orange : .blue)
                    .frame(maxWidth: .infinity)
        
                Divider()
                
                // Secondary content
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(entry.date, style: .time)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Emoji")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(entry.configuration.favoriteEmoji)
                            .font(.title2)
                    }
                }
                
                // Debug dimensions (small)
                Text("\(Int(widgetSize.width)) × \(Int(widgetSize.height))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                // Debounce mechanism to prevent multiple rapid calls
                let currentText = sizeCategory
                let lastText = UserDefaults.standard.string(forKey: "lastWidgetText") ?? ""
                let lastChangeTime = UserDefaults.standard.object(forKey: "lastChangeTime") as? Date ?? Date.distantPast
                let now = Date()
                
                // Only log if text changed AND enough time has passed (debounce)
                if currentText != lastText && now.timeIntervalSince(lastChangeTime) > 2.0 {
                    print("📝 Widget Size Changed: \(currentText)")
                    UserDefaults.standard.set(currentText, forKey: "lastWidgetText")
                    UserDefaults.standard.set(now, forKey: "lastChangeTime")
                }
                
                print("🎯 Widget Size Detection: \(sizeCategory)")
                print("📏 Dimensions: \(Int(widgetSize.width)) × \(Int(widgetSize.height))")
                print("📊 Area: \(Int(widgetSize.width * widgetSize.height))")
                print("🔧 Widget Properties:")
                print("   • Widget Family: \(widgetFamily)")
                print("   • Color Scheme: \(colorScheme)")
                print("   • Display Scale: \(displayScale)")
                print("   • Size Category: \(sizeCategory)")
                print("   • Rendering Mode: \(widgetRenderingMode)")
                print("   • Entry Date: \(entry.date)")
                print("   • Entry Config: \(entry.configuration.favoriteEmoji)")
                
                // Log geometry frame info
                print("🖼️ Geometry Info:")
                print("   • Safe Area: \(geometry.safeAreaInsets)")
                print("   • Frame: \(geometry.frame(in: .local))")
            }
        }
    }
    
    private func determineSizeCategory(width: CGFloat, height: CGFloat) -> String {
        // Based on actual measurements:
        // Large: 317×133 = 42,161 area
        // Small: 306×126 = 38,556 area
        let area = width * height
        
        if area < 40000 {
            print("determineSizeCategory -> Small")
            return "Small"
        } else {
            print("determineSizeCategory -> Large")
            return "Large"
        }
    }
    
    // Function to get the most reliable current user setting
    static func getCurrentHomeScreenSetting() -> String {
        return UserDefaults.standard.string(forKey: "currentSizeSetting") ?? "Unknown"
    }
    
    // Function to get the current widget text being displayed
    static func getCurrentWidgetText() -> String {
        return UserDefaults.standard.string(forKey: "lastWidgetText") ?? "Unknown"
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
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
