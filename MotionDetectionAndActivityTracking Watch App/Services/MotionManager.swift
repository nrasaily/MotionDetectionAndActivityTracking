//
//  MotionManager.swift
//  MotionDetectionAndActivityTracking
//
//  Created by Nar Rasaily on 2/4/26.
import Foundation
import CoreMotion
import WatchKit
import Combine

// Manages Core Motion sensor data
class MotionManager: ObservableObject {
    
    // MARK: - Published Properties
    // Accelerometer X value(left/right tilt)
    @Published var x: Double = 0.0
    
    // Accelerometer Y value (forward/backward tilt)
    @Published var y: Double = 0.0
    
    // Accelerometer Z value (faceup/ down)
    @Published var z: Double = 0.0
    
    // Whether motion updates are active
    @Published var isRunning: Bool = false
    
    // Number of shakes detected
    @Published var shakeCount: Int = 0
    
    // Whether shake was just detected(for animation)
    @Published var shakeDetected: Bool = false
    
    // MARK: - Private properties
    // The Core Motion manager instance
    private let motionManager = CMMotionManager()
    
    // Threshhold for shake detection (values above this = shake)
    private let shakeThreshold: Double = 2.5
    
    // Cooldown to prevent multiple shake detections
    private var lastShakeTime: Date = Date.distantPast
    
    private let shakeCooldown: TimeInterval = 0.5
    
    // Calculate acceleration magnitude (for shake detection)
    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
    
    // MARK: - Initialization
    init() {
        // Set update interval (10 updates per second)
        motionManager.accelerometerUpdateInterval = 0.1
    }
    
    // MARK: - Public Methods
    
    func startUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available")
            return
        }
        guard !isRunning else { return }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let data = data, error == nil else { return }
            
            // Update acceleration values
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            
            // Check for shake
            self.detectShake()
        }
        isRunning = true
    }
    // Stop recieving accelerometer updates
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        isRunning = false
    }
    
    // Reset shake counter
    func resetShakeCount() {
        shakeCount = 0
        playHaptic(.click)
    }
    
    // Detect if current acceleration indicates a shake
    
    private func detectShake() {
        let now = Date()
        
        // Check cooldown
        guard now.timeIntervalSince(lastShakeTime) > shakeCooldown else { return }
        
        // Check if magnitude exeeds threshold
        if magnitude > shakeThreshold {
            shakeCount += 1
            lastShakeTime = now
            
            // Trigger shake animation
            shakeDetected = true
            playHaptic(.notification)
            
            // Reset shake detected flag after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.shakeDetected = false
            }
        }
    }
    // Play haptic feedback
    private func playHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
    
    
    
    
    
}

