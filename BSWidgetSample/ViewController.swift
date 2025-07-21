//
//  ViewController.swift
//  BSWidgetSample
//
//  Created by Fahad Baig on 12/07/2025.
//

import UIKit
import WidgetKit

class ViewController: UIViewController {
    
    var detectionLabel: UILabel!
    var timer: Timer?
    var lastBounds: CGRect = .zero
    var lastNativeBounds: CGRect = .zero
    var lastScale: CGFloat = 0
    var lastDisplayScale: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        detectHomeScreenSetting()
        startMonitoring()
        
        // Detect when app comes to foreground (user might have changed setting)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // Watch for various system notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: UIScreen.modeDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: UIScreen.brightnessDidChangeNotification,
            object: nil
        )
    }
    
    func setupUI() {
        // Create label programmatically
        detectionLabel = UILabel()
        detectionLabel.numberOfLines = 0
        detectionLabel.textAlignment = .center
        detectionLabel.font = UIFont.systemFont(ofSize: 16)
        detectionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detectionLabel)
        
        NSLayoutConstraint.activate([
            detectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detectionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            detectionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            detectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func appDidBecomeActive() {
        print("🔄 App became active - checking for changes")
        detectHomeScreenSetting()
    }
    
    @objc func screenDidChange() {
        print("📺 Screen notification received - checking for changes")
        detectHomeScreenSetting()
    }
    
    func startMonitoring() {
        // Poll every 0.5 seconds for changes
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkForChanges()
        }
        print("🕐 Started real-time monitoring (every 0.5s)")
    }
    
    func checkForChanges() {
        guard let window = view.window,
              let windowScene = window.windowScene else { return }
        
        let screen = windowScene.screen
        let bounds = screen.bounds
        let nativeBounds = screen.nativeBounds
        let scale = screen.scale
        let displayScale = traitCollection.displayScale
        
        // Check if anything changed
        if bounds != lastBounds || 
           nativeBounds != lastNativeBounds || 
           scale != lastScale || 
           displayScale != lastDisplayScale {
            
            print("🚨 CHANGE DETECTED!")
            print("   Bounds: \(lastBounds) → \(bounds)")
            print("   Native: \(lastNativeBounds) → \(nativeBounds)")
            print("   Scale: \(lastScale) → \(scale)")
            print("   Display Scale: \(lastDisplayScale) → \(displayScale)")
            
            // Update stored values
            lastBounds = bounds
            lastNativeBounds = nativeBounds
            lastScale = scale
            lastDisplayScale = displayScale
            
            // Update UI
            detectHomeScreenSetting()
        }
    }
    
    func detectHomeScreenSetting() {
        guard let window = view.window,
              let windowScene = window.windowScene else { 
            detectionLabel?.text = "❌ No window/scene available"
            return 
        }
        
        let screen = windowScene.screen
        let bounds = screen.bounds
        let nativeBounds = screen.nativeBounds
        let scale = screen.scale
        
        // Store initial values if not set
        if lastBounds == .zero {
            lastBounds = bounds
            lastNativeBounds = nativeBounds
            lastScale = scale
            lastDisplayScale = traitCollection.displayScale
            print("📌 Initial values stored")
        }
        
        // Get various screen metrics
        let screenWidth = bounds.width
        let screenHeight = bounds.height
        let nativeWidth = nativeBounds.width
        let nativeHeight = nativeBounds.height
        
        // Try to detect based on effective screen area or scaling
        let effectiveArea = screenWidth * screenHeight
        
        // Check for any traits that might indicate the setting
        let traitCollection = self.traitCollection
        
        // Display results in UI
        let results = """
        📱 App Screen Detection (Live):
        
        Bounds: \(Int(screenWidth)) × \(Int(screenHeight))
        Native: \(Int(nativeWidth)) × \(Int(nativeHeight))
        Scale: \(scale)
        Effective Area: \(Int(effectiveArea))
        Display Scale: \(traitCollection.displayScale)
        UI Style: \(traitCollection.userInterfaceStyle.rawValue)
        
        🕐 Monitoring every 0.5s for changes...
        Change home screen size setting now!
        """
        
        detectionLabel?.text = results
        
        // Store detected information
        UserDefaults.standard.set(effectiveArea, forKey: "appEffectiveArea")
        UserDefaults.standard.set(Date(), forKey: "lastAppDetection")
        
        print("📱 Current values - Area: \(effectiveArea), Bounds: \(bounds)")
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        print("🛑 Monitoring stopped")
    }
}

