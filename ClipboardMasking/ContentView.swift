import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardMonitor: ClipboardMonitor
    @EnvironmentObject var settings: Settings
    @State private var showingSettings = false
    @State private var newCustomName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                SettingsView(showingSettings: $showingSettings)
                    .environmentObject(settings)
            } else {
                mainView
            }
        }
        .frame(width: showingSettings ? 400 : 280, height: showingSettings ? 500 : nil)
        .animation(.easeInOut(duration: 0.2), value: showingSettings)
    }
    
    private var mainView: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            statusSection
            Divider()
            controlsSection
            Divider()
            quickSettingsSection
            Divider()
            footerSection
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "eye.slash.fill")
                .foregroundColor(.blue)
            Text("Clipboard Masking")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var statusSection: some View {
        HStack {
            Circle()
                .fill(clipboardMonitor.isMonitoring ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(clipboardMonitor.isMonitoring ? "Active" : "Inactive")
                .font(.subheadline)
                .foregroundColor(clipboardMonitor.isMonitoring ? .green : .red)
            Spacer()
            if clipboardMonitor.maskCount > 0 {
                Text("Masked: \(clipboardMonitor.maskCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var controlsSection: some View {
        VStack(spacing: 8) {
            Button(action: clipboardMonitor.toggleMonitoring) {
                HStack {
                    Image(systemName: clipboardMonitor.isMonitoring ? "pause.fill" : "play.fill")
                    Text(clipboardMonitor.isMonitoring ? "Pause Monitoring" : "Start Monitoring")
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(clipboardMonitor.isMonitoring ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
            .cornerRadius(6)
            
            if !clipboardMonitor.lastMaskedContent.isEmpty {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(clipboardMonitor.lastMaskedContent, forType: .string)
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Restore Last Content")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var quickSettingsSection: some View {
        VStack(spacing: 4) {
            Toggle("IP Addresses", isOn: $settings.maskIPAddresses)
            Toggle("Emails", isOn: $settings.maskEmails)
            Toggle("Phone Numbers", isOn: $settings.maskPhoneNumbers)
            Toggle("Credit Cards", isOn: $settings.maskCreditCards)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onChange(of: settings.maskIPAddresses) { settings.saveSettings() }
        .onChange(of: settings.maskEmails) { settings.saveSettings() }
        .onChange(of: settings.maskPhoneNumbers) { settings.saveSettings() }
        .onChange(of: settings.maskCreditCards) { settings.saveSettings() }
    }
    
    private var footerSection: some View {
        HStack {
            Button("Settings") {
                showingSettings = true
            }
            .buttonStyle(.plain)
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    @Binding var showingSettings: Bool
    @State private var newCustomName = ""
    @State private var showingCustomPatternSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("← Back") {
                    showingSettings = false
                }
                .buttonStyle(.plain)
                Spacer()
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    showingSettings = false
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Masking Options")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        VStack(spacing: 4) {
                            Toggle("IP Addresses", isOn: $settings.maskIPAddresses)
                            Toggle("Email Addresses", isOn: $settings.maskEmails)
                            Toggle("Phone Numbers", isOn: $settings.maskPhoneNumbers)
                            Toggle("Credit Card Numbers", isOn: $settings.maskCreditCards)
                            Toggle("Social Security Numbers", isOn: $settings.maskSSN)
                            Toggle("Common Names", isOn: $settings.maskNames)
                            Toggle("Mask URLs", isOn: $settings.maskURLs)
                            Toggle("Clean copied links", isOn: $settings.cleanCopiedLinks)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Names")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        HStack {
                            TextField("Add custom name", text: $newCustomName)
                            Button("Add") {
                                if !newCustomName.isEmpty {
                                    settings.addCustomName(newCustomName)
                                    newCustomName = ""
                                }
                            }
                            .disabled(newCustomName.isEmpty)
                        }
                        .padding(.horizontal, 16)
                        
                        ForEach(settings.customNames, id: \.self) { name in
                            HStack {
                                Text(name)
                                Spacer()
                                Button("Remove") {
                                    settings.removeCustomName(name)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.red)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Patterns")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        Button("Add Custom Pattern") {
                            showingCustomPatternSheet = true
                        }
                        .padding(.horizontal, 16)
                        
                        ForEach(settings.customPatterns) { pattern in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Toggle("", isOn: Binding(
                                        get: { pattern.isEnabled },
                                        set: { newValue in
                                            var updatedPattern = pattern
                                            updatedPattern.isEnabled = newValue
                                            settings.updateCustomPattern(updatedPattern)
                                        }
                                    ))
                                    .labelsHidden()
                                    Text(pattern.name)
                                        .font(.headline)
                                    Spacer()
                                    Button("Remove") {
                                        settings.removeCustomPattern(pattern)
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(.red)
                                }
                                Text("Pattern: \(pattern.pattern)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Replacement: \(pattern.replacement)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("General")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        Toggle("Start monitoring on launch", isOn: $settings.startOnLaunch)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .onChange(of: settings.maskIPAddresses) { settings.saveSettings() }
        .onChange(of: settings.maskEmails) { settings.saveSettings() }
        .onChange(of: settings.maskPhoneNumbers) { settings.saveSettings() }
        .onChange(of: settings.maskCreditCards) { settings.saveSettings() }
        .onChange(of: settings.maskSSN) { settings.saveSettings() }
        .onChange(of: settings.maskNames) { settings.saveSettings() }
        .onChange(of: settings.maskURLs) { settings.saveSettings() }
        .onChange(of: settings.cleanCopiedLinks) { settings.saveSettings() }
        .onChange(of: settings.startOnLaunch) { settings.saveSettings() }
        .sheet(isPresented: $showingCustomPatternSheet) {
            CustomPatternView()
                .environmentObject(settings)
        }
    }
}

struct CustomPatternView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var pattern = ""
    @State private var replacement = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Custom Pattern")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pattern Details")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        VStack(spacing: 8) {
                            TextField("Name (e.g., Username)", text: $name)
                            TextField("Regex Pattern (e.g., \\busername\\b)", text: $pattern)
                            TextField("Replacement (e.g., [USERNAME])", text: $replacement)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Examples")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Name: Username")
                            Text("• Pattern: \\bmyusername\\b")
                            Text("• Replacement: [USERNAME]")
                            Divider()
                            Text("• Name: Company")
                            Text("• Pattern: \\bMyCompany\\b")
                            Text("• Replacement: [COMPANY]")
                            Divider()
                            Text("• Name: API Key")
                            Text("• Pattern: sk-[a-zA-Z0-9]{32}")
                            Text("• Replacement: [API_KEY]")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Add") {
                    if !name.isEmpty && !pattern.isEmpty && !replacement.isEmpty {
                        let customPattern = CustomPattern(
                            name: name,
                            pattern: pattern,
                            replacement: replacement
                        )
                        settings.addCustomPattern(customPattern)
                        dismiss()
                    }
                }
                .disabled(name.isEmpty || pattern.isEmpty || replacement.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 400, height: 400)
    }
}
