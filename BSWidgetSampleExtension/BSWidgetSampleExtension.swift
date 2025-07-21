//
//  BSWidgetSampleExtension.swift
//  BSWidgetSampleExtension
//
//  Created by Fahad Baig on 12/07/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

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
                // Enhanced frame change detection
                let currentText = sizeCategory
                let lastText = UserDefaults.standard.string(forKey: "lastWidgetText") ?? ""
                let lastWidth = UserDefaults.standard.double(forKey: "lastWidgetWidth")
                let lastHeight = UserDefaults.standard.double(forKey: "lastWidgetHeight")
                
                // Detect if size actually changed
                let sizeChanged = abs(widgetSize.width - lastWidth) > 1.0 || abs(widgetSize.height - lastHeight) > 1.0
                
                if currentText != lastText || sizeChanged {
                    print("🚨 WIDGET SIZE CHANGE DETECTED!")
                    print("   📝 Text: '\(lastText)' → '\(currentText)'")
                    print("   📏 Size: \(Int(lastWidth))×\(Int(lastHeight)) → \(Int(widgetSize.width))×\(Int(widgetSize.height))")
                    print("   🔄 Change Timestamp: \(Date())")
                    
                    // Store new values
                    UserDefaults.standard.set(currentText, forKey: "lastWidgetText")
                    UserDefaults.standard.set(Double(widgetSize.width), forKey: "lastWidgetWidth")
                    UserDefaults.standard.set(Double(widgetSize.height), forKey: "lastWidgetHeight")
                    UserDefaults.standard.set(Date(), forKey: "lastWidgetChangeTime")
                }
                
                print("🎯 Current Widget State:")
                print("   📱 Category: \(sizeCategory)")
                print("   📏 Dimensions: \(Int(widgetSize.width)) × \(Int(widgetSize.height))")
                print("   📊 Area: \(Int(widgetSize.width * widgetSize.height))")
                print("   🏗️ Widget Family: \(widgetFamily)")
                print("   🎨 Color Scheme: \(colorScheme)")
                print("   📈 Display Scale: \(displayScale)")
                print("   🔧 Rendering Mode: \(widgetRenderingMode)")
                print("   📅 Entry Date: \(entry.date)")
                print("   😀 Config Emoji: \(entry.configuration.favoriteEmoji)")
                
                // Enhanced geometry logging
                print("🖼️ Detailed Geometry:")
                print("   📐 Safe Area: \(geometry.safeAreaInsets)")
                print("   🖥️ Local Frame: \(geometry.frame(in: .local))")
                print("   🌍 Global Frame: \(geometry.frame(in: .global))")
                
                // Environment detection
                print("🌐 Environment Context:")
                print("   📏 Size Category: \(sizeCategory)")
                print("   🎭 Interface Style: \(colorScheme == .dark ? "Dark" : "Light")")
                
                print("═══════════════════════════════════════")
            }
        }
    }
    
    private func determineSizeCategory(width: CGFloat, height: CGFloat) -> String {
        // More reliable detection based on widget family and actual dimensions
        // Use both absolute size and aspect ratio for better accuracy
        
        let area = width * height
        let aspectRatio = width / height
        
        print("🔍 Size Detection Debug:")
        print("   • Width: \(width), Height: \(height)")
        print("   • Area: \(area)")
        print("   • Aspect Ratio: \(aspectRatio)")
        
        // Enhanced detection logic:
        // Small icons typically have smaller widget dimensions
        // Large icons typically have larger widget dimensions
        
        // Method 1: Area-based detection with dynamic thresholds
        if area < 39000 {
            print("   • Detection Method: Area < 39000 → Small")
            return "Small"
        } else if area > 41000 {
            print("   • Detection Method: Area > 41000 → Large")
            return "Large"
        }
        
        // Method 2: Width-based detection (more reliable)
        if width < 310 {
            print("   • Detection Method: Width < 310 → Small")
            return "Small"
        } else if width > 315 {
            print("   • Detection Method: Width > 315 → Large")  
            return "Large"
        }
        
        // Method 3: Height-based detection as fallback
        if height < 130 {
            print("   • Detection Method: Height < 130 → Small")
            return "Small"
        } else {
            print("   • Detection Method: Height >= 130 → Large")
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
    SimpleEntry(date: Date.now, configuration: .smiley)
    SimpleEntry(date: Date.now, configuration: .starEyes)
}
