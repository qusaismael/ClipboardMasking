import Foundation
import SwiftUI

struct CustomPattern: Identifiable, Codable {
    var id = UUID()
    var name: String
    var pattern: String
    var replacement: String
    var isEnabled: Bool
    
    init(name: String, pattern: String, replacement: String, isEnabled: Bool = true) {
        self.id = UUID()
        self.name = name
        self.pattern = pattern
        self.replacement = replacement
        self.isEnabled = isEnabled
    }
}

class Settings: ObservableObject {
    @Published var maskIPAddresses: Bool = true
    @Published var maskEmails: Bool = true
    @Published var maskPhoneNumbers: Bool = true
    @Published var maskCreditCards: Bool = true
    @Published var maskSSN: Bool = true
    @Published var maskNames: Bool = true
    @Published var maskURLs: Bool = false
    @Published var cleanCopiedLinks: Bool = true
    @Published var customNames: [String] = []
    @Published var customPatterns: [CustomPattern] = []
    @Published var startOnLaunch: Bool = true
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        userDefaults.set(maskIPAddresses, forKey: "maskIPAddresses")
        userDefaults.set(maskEmails, forKey: "maskEmails")
        userDefaults.set(maskPhoneNumbers, forKey: "maskPhoneNumbers")
        userDefaults.set(maskCreditCards, forKey: "maskCreditCards")
        userDefaults.set(maskSSN, forKey: "maskSSN")
        userDefaults.set(maskNames, forKey: "maskNames")
        userDefaults.set(maskURLs, forKey: "maskURLs")
        userDefaults.set(cleanCopiedLinks, forKey: "cleanCopiedLinks")
        userDefaults.set(customNames, forKey: "customNames")
        userDefaults.set(startOnLaunch, forKey: "startOnLaunch")
        
        // Save custom patterns
        if let encoded = try? JSONEncoder().encode(customPatterns) {
            userDefaults.set(encoded, forKey: "customPatterns")
        }
    }
    
    private func loadSettings() {
        maskIPAddresses = userDefaults.object(forKey: "maskIPAddresses") as? Bool ?? true
        maskEmails = userDefaults.object(forKey: "maskEmails") as? Bool ?? true
        maskPhoneNumbers = userDefaults.object(forKey: "maskPhoneNumbers") as? Bool ?? true
        maskCreditCards = userDefaults.object(forKey: "maskCreditCards") as? Bool ?? true
        maskSSN = userDefaults.object(forKey: "maskSSN") as? Bool ?? true
        maskNames = userDefaults.object(forKey: "maskNames") as? Bool ?? true
        maskURLs = userDefaults.object(forKey: "maskURLs") as? Bool ?? false
        cleanCopiedLinks = userDefaults.object(forKey: "cleanCopiedLinks") as? Bool ?? true
        customNames = userDefaults.stringArray(forKey: "customNames") ?? []
        startOnLaunch = userDefaults.object(forKey: "startOnLaunch") as? Bool ?? true
        
        // Load custom patterns
        if let data = userDefaults.data(forKey: "customPatterns"),
           let decoded = try? JSONDecoder().decode([CustomPattern].self, from: data) {
            customPatterns = decoded
        }
    }
    
    func addCustomName(_ name: String) {
        if !customNames.contains(name.lowercased()) {
            customNames.append(name.lowercased())
            saveSettings()
        }
    }
    
    func removeCustomName(_ name: String) {
        customNames.removeAll { $0 == name.lowercased() }
        saveSettings()
    }
    
    func addCustomPattern(_ pattern: CustomPattern) {
        customPatterns.append(pattern)
        saveSettings()
    }
    
    func removeCustomPattern(_ pattern: CustomPattern) {
        customPatterns.removeAll { $0.id == pattern.id }
        saveSettings()
    }
    
    func updateCustomPattern(_ pattern: CustomPattern) {
        if let index = customPatterns.firstIndex(where: { $0.id == pattern.id }) {
            customPatterns[index] = pattern
            saveSettings()
        }
    }
} 