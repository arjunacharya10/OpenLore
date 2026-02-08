import SwiftUI

@main
struct OpenLoreApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var tracker = WritingTracker()

    var body: some Scene {
        MenuBarExtra {
            Button("Toggle Overlay") {
                appDelegate.toggleOverlay()
            }
            .keyboardShortcut("t", modifiers: [.command])
            .onAppear {
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
    var isOverlayVisible = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        checkAccessibilityPermissions()
        
        // Initialize audio manager
        print("🟢 App launched - Audio manager ready")
        let _ = AmbienceAudioManager.shared
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

    private func checkAccessibilityPermissions() {
        guard !AXIsProcessTrusted() else { return }
        
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

    private func createOverlayWindow() {
        guard let tracker = tracker,
              let screen = NSScreen.main else { return }

        let windowWidth: CGFloat = 420
        let windowHeight: CGFloat = 62
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

        let visualEffectView = NSVisualEffectView(frame: window.contentView!.bounds)
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 14
        visualEffectView.layer?.masksToBounds = true

        window.contentView?.addSubview(visualEffectView)

        let contentView = ProgressBarOverlayView(tracker: tracker)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = visualEffectView.bounds
        hostingView.autoresizingMask = [.width, .height]
        visualEffectView.addSubview(hostingView)

        window.orderFrontRegardless()
        self.overlayWindow = window
    }
}

