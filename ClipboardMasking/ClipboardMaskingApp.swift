import SwiftUI

@main
struct ClipboardMaskingApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @StateObject private var settings = Settings()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(clipboardMonitor)
                .environmentObject(settings)
                .onAppear {
                    clipboardMonitor.setSettings(settings)
                    if settings.startOnLaunch {
                        clipboardMonitor.startMonitoring()
                    }
                }
        } label: {
            Image(systemName: clipboardMonitor.isMonitoring ? "eye.slash.fill" : "eye.slash")
                .foregroundColor(clipboardMonitor.isMonitoring ? .green : .gray)
        }
        .menuBarExtraStyle(.window)
    }
}
