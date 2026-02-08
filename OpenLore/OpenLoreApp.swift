import SwiftUI

@main
struct OpenLoreApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var tracker = WritingTracker()

    init() {
        // Pass tracker to app delegate during initialization
        // Note: appDelegate is not yet available here, so we'll use a different approach
    }

    var body: some Scene {
        MenuBarExtra {
            Button("Toggle Overlay") {
                appDelegate.toggleOverlay()
            }
            .keyboardShortcut("t", modifiers: [.command])
            .onAppear {
                // Pass the tracker to the AppDelegate when menu appears
                appDelegate.setTracker(tracker)
            }
            
            Divider()
            
            SettingsLink {
                Text("Settings...")
            }
            .keyboardShortcut(",", modifiers: [.command])
            
            Divider()
            
            Button("Quit OpenLore") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        } label: {
            Image(systemName: "book.pages")
        }

        // Hidden main window (required for menu bar apps)
        Window("OpenLore Settings", id: "settings") {
            SettingsView(tracker: tracker)
                .frame(width: 400, height: 300)
        }
        .defaultPosition(.center)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow?
    var tracker: WritingTracker?
    var isOverlayVisible: Bool = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Check accessibility permissions
        checkAccessibilityPermissions()
    }

    func setTracker(_ tracker: WritingTracker) {
        self.tracker = tracker
        createOverlayWindow()
    }
    
    func toggleOverlay() {
        isOverlayVisible.toggle()
        
        if isOverlayVisible {
            overlayWindow?.orderFrontRegardless()
        } else {
            overlayWindow?.orderOut(nil)
        }
    }

    func checkAccessibilityPermissions() {
        if !AXIsProcessTrusted() {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "OpenLore needs Accessibility permissions to track your writing. Please grant access in System Settings > Privacy & Security > Accessibility."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Cancel")

                if alert.runModal() == .alertFirstButtonReturn {
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }

    func createOverlayWindow() {
        guard let screen = NSScreen.main else { return }

        let windowWidth: CGFloat = 420
        let windowHeight: CGFloat = 50
        let margin: CGFloat = 16

        let windowRect = NSRect(
            x: screen.frame.midX - windowWidth / 2,
            y: screen.frame.minY + margin,
            width: windowWidth,
            height: windowHeight
        )

        let window = NSPanel(
            contentRect: windowRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        window.isFloatingPanel = true
        window.level = .statusBar
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        // Create visual effect view for a cleaner look
        let visualEffectView = NSVisualEffectView(frame: window.contentView!.bounds)
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 14
        visualEffectView.layer?.masksToBounds = true

        window.contentView?.addSubview(visualEffectView)

        // Add SwiftUI content
        let contentView = ProgressBarOverlayView(tracker: tracker!)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = visualEffectView.bounds
        hostingView.autoresizingMask = [.width, .height]
        visualEffectView.addSubview(hostingView)

        window.orderFrontRegardless()

        self.overlayWindow = window
    }
}
