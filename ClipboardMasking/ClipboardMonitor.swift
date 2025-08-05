import Foundation
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var isMonitoring: Bool = false
    @Published var lastMaskedContent: String = ""
    @Published var maskCount: Int = 0
    
    private var changeCount: Int = NSPasteboard.general.changeCount
    private var timer: Timer?
    private var settings: Settings?
    
    func setSettings(_ settings: Settings) {
        self.settings = settings
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        changeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.checkClipboard()
        }
        isMonitoring = true
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }
    
    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != self.changeCount {
            self.changeCount = pasteboard.changeCount
            if let content = pasteboard.string(forType: .string) {
                let anonymized = self.anonymize(content)
                if anonymized != content {
                    pasteboard.clearContents()
                    pasteboard.setString(anonymized, forType: .string)
                    DispatchQueue.main.async {
                        self.lastMaskedContent = content
                        self.maskCount += 1
                    }
                }
            }
        }
    }
    
    private func anonymize(_ text: String) -> String {
        var result = text
        let settings = self.settings
        
        // IP Address Masking
        if settings?.maskIPAddresses ?? true {
            result = result.replacingOccurrences(
                of: "\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b",
                with: "[IP_ADDRESS]",
                options: .regularExpression
            )
        }
        
        // Email Masking
        if settings?.maskEmails ?? true {
            result = result.replacingOccurrences(
                of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                with: "[EMAIL]",
                options: .regularExpression
            )
        }
        
        // Phone Number Masking
        if settings?.maskPhoneNumbers ?? true {
            result = result.replacingOccurrences(
                of: "\\b(?:\\+?1[-.]?)?\\(?([0-9]{3})\\)?[-.]?([0-9]{3})[-.]?([0-9]{4})\\b",
                with: "[PHONE]",
                options: .regularExpression
            )
        }
        
        // Credit Card Masking
        if settings?.maskCreditCards ?? true {
            result = result.replacingOccurrences(
                of: "\\b(?:\\d[ -]?){13,16}\\b",
                with: "[CARD_NUMBER]",
                options: .regularExpression
            )
        }
        
        // Social Security Number
        if settings?.maskSSN ?? true {
            result = result.replacingOccurrences(
                of: "\\b\\d{3}-\\d{2}-\\d{4}\\b",
                with: "[SSN]",
                options: .regularExpression
            )
        }
        
        // Common names
        if settings?.maskNames ?? true {
            let commonNames = ["mohammad", "mike", "john", "ahmad", "qusai", "lana", "ismail", "bob", "alice", "diana"] // TODO: add more name, i just added some names that i know.
            for name in commonNames {
                result = result.replacingOccurrences(
                    of: "\\b\(name)\\b",
                    with: "[NAME]",
                    options: [.regularExpression, .caseInsensitive]
                )
            }
            
            // Custom names
            for name in settings?.customNames ?? [] {
                result = result.replacingOccurrences(
                    of: "\\b\(name)\\b",
                    with: "[NAME]",
                    options: [.regularExpression, .caseInsensitive]
                )
            }
        }
        
        // URLs
        if settings?.maskURLs ?? false {
            result = result.replacingOccurrences(
                of: "https?://[^\\s]+",
                with: "[URL]",
                options: .regularExpression
            )
        }
        
        // Custom patterns
        for pattern in settings?.customPatterns ?? [] {
            if pattern.isEnabled {
                result = result.replacingOccurrences(
                    of: pattern.pattern,
                    with: pattern.replacement,
                    options: .regularExpression
                )
            }
        }
        
        return result
    }
}
