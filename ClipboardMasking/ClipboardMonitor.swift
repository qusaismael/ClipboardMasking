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
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let settings = self.settings
        
        // Check if the content consists only of a single pattern
        // URL pattern
        let urlPattern = "^https?://[^\\s]+$"
        // If it's a single URL and link cleaning is enabled, clean and return it (preserving surrounding whitespace)
        if settings?.cleanCopiedLinks ?? true {
            if let _ = trimmedText.range(of: urlPattern, options: .regularExpression) {
                let cleaned = cleanLink(trimmedText)
                if cleaned == trimmedText {
                    return text
                } else {
                    let leadingWhitespace = String(text.prefix(while: { $0.isWhitespace }))
                    let trailingWhitespace = String(text.reversed().prefix(while: { $0.isWhitespace }).reversed())
                    return leadingWhitespace + cleaned + trailingWhitespace
                }
            }
        }
        if settings?.maskURLs ?? false {
            if let _ = trimmedText.range(of: urlPattern, options: .regularExpression) {
                return text // Return unmasked if it's just a URL
            }
        }
        
        // IP address pattern
        let ipPattern = "^(?:\\d{1,3}\\.){3}\\d{1,3}$"
        if settings?.maskIPAddresses ?? true {
            if let _ = trimmedText.range(of: ipPattern, options: .regularExpression) {
                return text // Return unmasked if it's just an IP address
            }
        }
        
        // Email pattern
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        if settings?.maskEmails ?? true {
            if let _ = trimmedText.range(of: emailPattern, options: .regularExpression) {
                return text // Return unmasked if it's just an email
            }
        }
        
        // Phone number pattern
        let phonePattern = "^(?:\\+?1[-.]?)?\\(?([0-9]{3})\\)?[-.]?([0-9]{3})[-.]?([0-9]{4})$"
        if settings?.maskPhoneNumbers ?? true {
            if let _ = trimmedText.range(of: phonePattern, options: .regularExpression) {
                return text // Return unmasked if it's just a phone number
            }
        }
        
        // Credit card pattern
        let cardPattern = "^(?:\\d[ -]?){13,16}$"
        if settings?.maskCreditCards ?? true {
            if let _ = trimmedText.range(of: cardPattern, options: .regularExpression) {
                return text // Return unmasked if it's just a credit card
            }
        }
        
        // SSN pattern
        let ssnPattern = "^\\d{3}-\\d{2}-\\d{4}$"
        if settings?.maskSSN ?? true {
            if let _ = trimmedText.range(of: ssnPattern, options: .regularExpression) {
                return text // Return unmasked if it's just an SSN
            }
        }
        
        // Name patterns
        if settings?.maskNames ?? true {
            let commonNames = ["mohammad", "mike", "john", "ahmad", "qusai", "lana", "ismail", "bob", "alice", "diana"]
            for name in commonNames {
                let namePattern = "^\(name)$"
                if let _ = trimmedText.range(of: namePattern, options: [.regularExpression, .caseInsensitive]) {
                    return text // Return unmasked if it's just a name
                }
            }
            
            // Custom names
            for name in settings?.customNames ?? [] {
                let namePattern = "^\(name)$"
                if let _ = trimmedText.range(of: namePattern, options: [.regularExpression, .caseInsensitive]) {
                    return text // Return unmasked if it's just a custom name
                }
            }
        }
        
        // Custom patterns
        for pattern in settings?.customPatterns ?? [] {
            if pattern.isEnabled {
                let fullPattern = "^\(pattern.pattern)$"
                if let _ = trimmedText.range(of: fullPattern, options: .regularExpression) {
                    return text // Return unmasked if it's just a custom pattern
                }
            }
        }
        
        var result = text
        
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

    // MARK: - Link Cleaning
    private func cleanLink(_ urlString: String, hopLimit: Int = 2) -> String {
        guard hopLimit >= 0 else { return urlString }
        guard let url = URL(string: urlString) else { return urlString }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return urlString }

        // 1) Unwrap common redirectors by extracting the actual link from known query keys
        let redirectorHosts: Set<String> = [
            "www.google.com", "google.com", "www.googleadservices.com",
            "l.facebook.com", "lm.facebook.com", "l.messenger.com", "l.instagram.com",
            "t.co", "lnkd.in", "link.medium.com", "news.ycombinator.com",
            "r.search.yahoo.com", "out.reddit.com", "urldefense.com", "www.urldefense.com",
            "protect-us.mimecast.com", "slack-redir.net", "away.vk.com"
        ]
        let possibleLinkKeys: [String] = ["url", "u", "q", "target", "dest", "destination", "to", "redirect", "redir", "r", "link", "l"]

        if let host = components.host, redirectorHosts.contains(host), let items = components.queryItems {
            for key in possibleLinkKeys {
                if let value = items.first(where: { $0.name.caseInsensitiveCompare(key) == .orderedSame })?.value,
                   let decoded = value.removingPercentEncoding,
                   decoded.hasPrefix("http") {
                    // Recurse to clean the extracted URL as well
                    return cleanLink(decoded, hopLimit: hopLimit - 1)
                }
            }
        }

        // 2) Remove tracking query parameters (case-insensitive)
        let trackingPrefixes: [String] = [
            "utm_", "hsa_"
        ]
        let trackingParams: Set<String> = [
            "fbclid", "gclid", "gbraid", "wbraid", "dclid", "yclid", "msclkid", "mc_cid", "mc_eid",
            "igshid", "mkt_tok", "vero_conv", "vero_id", "gclsrc", "spm", "ref", "trk", "trkCampaign",
            "oly_enc_id", "oly_anon_id", "_hsmi", "_hsenc", "si"
        ]

        if var items = components.queryItems, !items.isEmpty {
            items = items.filter { item in
                let name = item.name.lowercased()
                if trackingParams.contains(name) { return false }
                for prefix in trackingPrefixes { if name.hasPrefix(prefix) { return false } }
                return true
            }
            components.queryItems = items.isEmpty ? nil : items
        }

        // 3) Strip AMP artifacts
        if components.path.hasSuffix("/amp/") {
            components.path.removeLast(5)
        } else if components.path.hasSuffix("/amp") {
            components.path.removeLast(4)
        }
        if var items = components.queryItems, !items.isEmpty {
            items.removeAll { $0.name.caseInsensitiveCompare("amp") == .orderedSame }
            components.queryItems = items.isEmpty ? nil : items
        }

        // 4) Clean tracking fragments
        if let fragment = components.fragment, !fragment.isEmpty {
            let parts = fragment.split(separator: "&").map { String($0) }
            var kept: [String] = []
            for part in parts {
                let pair = part.split(separator: "=", maxSplits: 1).map { String($0) }
                let key = pair.first?.lowercased() ?? ""
                var isTracking = false
                if trackingParams.contains(key) { isTracking = true }
                if trackingPrefixes.contains(where: { key.hasPrefix($0) }) { isTracking = true }
                if !isTracking { kept.append(part) }
            }
            components.fragment = kept.isEmpty ? nil : kept.joined(separator: "&")
        }

        // Return rebuilt URL string
        return components.string ?? urlString
    }
}
