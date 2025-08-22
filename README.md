# ClipboardMasking 🔒
<img width="632" height="590" alt="image" src="https://github.com/user-attachments/assets/04fa2601-d529-4424-9593-f19168954676" />

A privacy-focused macOS menu bar application that automatically masks sensitive information in your clipboard content. Protect your personal data by automatically replacing sensitive information like emails, phone numbers, credit cards, and more with placeholder text.


## Features

- **🔍 Real-time Monitoring**: Continuously monitors clipboard changes and automatically masks sensitive data
- **🛡️ Privacy Protection**: Masks multiple types of sensitive information:
  - Email addresses
  - IP addresses
  - Phone numbers
  - Credit card numbers
  - Social Security Numbers
  - URLs
- **🔗 Clean Copied Links**: Optionally cleans copied links (when the clipboard contains a single URL) by removing common tracking parameters (e.g., `utm_*`, `fbclid`, `gclid`, etc.), stripping AMP artifacts, and unwrapping common redirectors (e.g., Google/Facebook redirect links) without any network requests
- **⚙️ Customizable**: Add custom names and regex patterns for specific masking needs
- **🎯 Smart Detection**: Only masks content when it's part of larger text, not when it's the entire clipboard content
- **🔄 Restore Functionality**: Easily restore the original content if needed
- **🚀 Menu Bar Integration**: Lightweight menu bar app that doesn't interfere with your workflow
- **💾 Persistent Settings**: Remembers your preferences across app launches

## 🚀 Installation

### Prerequisites
- macOS 13.0 or later
- Xcode 14.0 or later (for building from source)

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/qusaismael/ClipboardMasking.git
cd ClipboardMasking
```

2. Open the project in Xcode:
```bash
open ClipboardMasking.xcodeproj
```

3. Build and run the project (⌘+R)

4. The app will appear in your menu bar with an eye-slash icon

## 📖 Usage

### Basic Operation

1. **Start Monitoring**: Click the menu bar icon and press "Start Monitoring"
2. **Copy Sensitive Data**: Copy any text containing sensitive information
3. **Automatic Masking**: The app automatically replaces sensitive data with placeholders
4. **Restore if Needed**: Use "Restore Last Content" to get back the original text

### Menu Bar Icon States

- **Gray eye-slash**: Monitoring is inactive
- **Green eye-slash**: Monitoring is active

### Quick Settings

Access common masking options directly from the main menu:
- ✅ IP Addresses
- ✅ Emails  
- ✅ Phone Numbers
- ✅ Credit Cards

### Advanced Settings

Click "Settings" to access advanced configuration:

#### Masking Options
- **IP Addresses**: Masks IPv4 addresses (e.g., `192.168.1.1` → `[IP_ADDRESS]`)
- **Email Addresses**: Masks email formats (e.g., `user@example.com` → `[EMAIL]`)
- **Phone Numbers**: Masks US phone number formats (e.g., `(555) 123-4567` → `[PHONE]`)
- **Credit Card Numbers**: Masks 13-16 digit card numbers (e.g., `1234 5678 9012 3456` → `[CARD_NUMBER]`)
- **Social Security Numbers**: Masks SSN format (e.g., `123-45-6789` → `[SSN]`)
- **Mask URLs**: Masks web addresses embedded in text (e.g., `https://example.com` → `[URL]`)
- **Clean Copied Links**: When enabled, if the clipboard contains only a URL, the app will rewrite it to a privacy-friendly version by removing tracking query params (like `utm_*`, `fbclid`, `gclid`, etc.), cleaning fragments, stripping AMP, and unwrapping common redirector URLs using only local parsing

#### Custom Names
Add specific names you want to mask:
- Click "Add" next to the custom name field
- Enter the name you want to mask
- The app will replace it with `[NAME]`

#### Custom Patterns
Create custom regex patterns for specific masking needs:

**Example Patterns:**
- **Username**: Pattern `\bmyusername\b` → Replacement `[USERNAME]`
- **Company**: Pattern `\bMyCompany\b` → Replacement `[COMPANY]`
- **API Key**: Pattern `sk-[a-zA-Z0-9]{32}` → Replacement `[API_KEY]`

## 🔧 Configuration

### Auto-Start
Enable "Start monitoring on launch" to automatically begin monitoring when the app starts.

### Smart Content Detection
The app intelligently detects when sensitive content is the entire clipboard content vs. part of larger text. It only masks content when it's embedded within other text, preserving intentional copying of specific data types.

When "Clean Copied Links" is enabled, an exception is made for single-URL clipboard content: the URL is cleaned and replaced in the clipboard to minimize tracking.

## 🛠️ Development

### Project Structure
```
ClipboardMasking/
├── ClipboardMaskingApp.swift      # Main app entry point
├── ClipboardMonitor.swift         # Core monitoring and masking logic
├── ContentView.swift              # Main UI components
├── Settings.swift                 # Settings management
└── Assets.xcassets/              # App icons and assets
```

### Key Components

- **ClipboardMonitor**: Handles clipboard monitoring and content masking
- **Settings**: Manages user preferences and custom patterns
- **ContentView**: Provides the menu bar interface and settings UI

### Adding New Masking Types

To add a new type of sensitive data to mask:

1. Add a new boolean property to `Settings.swift`
2. Add the masking logic in `ClipboardMonitor.anonymize()`
3. Add UI controls in `ContentView.swift`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines

- Follow Swift coding conventions
- Add comments for complex logic
- Test your changes thoroughly
- Update documentation if needed

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔒 Privacy

ClipboardMasking operates entirely on your local machine. No data is sent to external servers. All masking rules and settings are stored locally using UserDefaults.

## Known Issues

- The app only monitors text content (not images or other data types)
- Some complex regex patterns may need fine-tuning for specific use cases


## Acknowledgments

- Built with SwiftUI and AppKit
- Inspired by the need for better clipboard privacy
- Thanks to the macOS development community

---

**Note**: This app is designed for privacy-conscious users who want to prevent accidental sharing of sensitive information. It's not a replacement for proper security practices and should be used as part of a broader privacy strategy. 
