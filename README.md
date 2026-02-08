# OpenLore

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="Platform: macOS">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0">
  <img src="https://img.shields.io/badge/SwiftUI-Yes-blue.svg" alt="SwiftUI">
</p>

A lightweight, unobtrusive writing tracker for macOS that helps you stay motivated and focused on your writing goals.

## Features

- 📊 **Real-time Word Tracking** - Automatically tracks word count from any text editor
- 🎯 **Daily Goals** - Set customizable daily word goals (1,000 - 10,000 words)
- 📄 **Page Counter** - Displays page count (based on 300 words per page)
- ⏱️ **Focus Timer** - Tracks how long you've been writing
- 🎨 **Clean Overlay** - Beautiful, translucent progress bar overlay that stays out of your way
- 📍 **Always Available** - Menu bar app that works across all spaces
- 🔒 **Privacy First** - All tracking happens locally on your device

## Screenshots

The overlay displays your progress at the bottom of your screen with:
- Current word count vs. daily goal
- Progress percentage
- Page count
- Focus time tracker
- Interactive progress bar

## Requirements

- macOS 13.0 (Ventura) or later
- Accessibility permissions (required for word tracking)

## Installation

### Building from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/OpenLore.git
   cd OpenLore
   ```

2. Open `OpenLore.xcodeproj` in Xcode

3. Build and run the project (⌘R)

### First Launch

On first launch, OpenLore will request Accessibility permissions:

1. Click "Open System Settings" when prompted
2. Navigate to **Privacy & Security → Accessibility**
3. Enable the toggle for OpenLore
4. Restart the app

## Usage

### Menu Bar

OpenLore runs as a menu bar application with a book icon. Click it to access:

- **Toggle Overlay** (⌘T) - Show/hide the progress overlay
- **Settings** (⌘,) - Open settings window
- **Quit** (⌘Q) - Exit the application

### Progress Overlay

The overlay appears at the bottom center of your screen and displays:

- **Word Count**: Current words vs. daily goal
- **Progress**: Percentage toward your goal
- **Pages**: Number of pages written
- **Focus Timer**: Minutes spent writing
- **Reset Button**: Reset the focus timer

Click the progress bar to adjust your daily word goal.

### Customizing Goals

1. Click on the progress bar overlay, or
2. Open Settings from the menu bar

Use the slider to set your daily word goal (1,000 - 10,000 words).

## How It Works

OpenLore uses macOS Accessibility APIs to monitor the active text field in your frontmost application. It:

1. Detects the currently focused text element
2. Reads the text content
3. Counts words by splitting on whitespace
4. Updates the display in real-time

**Note**: OpenLore only reads text from the active window and does not store or transmit any of your writing.

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘T | Toggle overlay visibility |
| ⌘, | Open settings |
| ⌘Q | Quit OpenLore |

## Privacy

OpenLore is designed with privacy in mind:

- ✅ All processing happens locally on your device
- ✅ No data is stored or transmitted
- ✅ No analytics or tracking
- ✅ Open source - verify the code yourself

## Supported Applications

OpenLore works with any text editor or application that exposes text through Accessibility APIs, including:

- TextEdit
- Pages
- Microsoft Word
- BBEdit
- Sublime Text
- VS Code
- Xcode
- And many more!

## Architecture

OpenLore is built with modern Swift technologies:

- **SwiftUI** - For the user interface
- **AppKit** - For window management and menu bar integration
- **Accessibility APIs** - For reading text from other applications
- **Combine** - For reactive state management

### Key Components

- `OpenLoreApp.swift` - Main app structure and menu bar setup
- `WritingTracker.swift` - Core tracking logic and accessibility integration
- `ProgressBarOverlayView.swift` - SwiftUI views for the overlay and settings
- `AppDelegate` - Window management and system integration

## Development

### Project Structure

```
OpenLore/
├── OpenLoreApp.swift              # App entry point and menu bar
├── WritingTracker.swift           # Word tracking logic
├── ProgressBarOverlayView.swift   # UI components
├── OpenLoreTests/                 # Unit tests
└── OpenLoreUITests/               # UI tests
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Roadmap

Future features under consideration:

- [ ] Historical tracking and statistics
- [ ] Writing streaks
- [ ] Multiple goal presets
- [ ] Export writing statistics
- [ ] Customizable overlay appearance
- [ ] Writing session notes
- [ ] Integration with writing apps

## Known Issues

- Some applications may not expose their text through Accessibility APIs
- The tracker resets when switching between different documents
- Focus timer continues even when not actively typing

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by writers who need gentle motivation to reach their daily goals
- Built with ❤️ using Swift and SwiftUI

## Support

If you encounter any issues or have suggestions:

1. Check the [Issues](https://github.com/yourusername/OpenLore/issues) page
2. Open a new issue with details about your problem
3. Include your macOS version and steps to reproduce

---

**Happy Writing!** 📝✨
