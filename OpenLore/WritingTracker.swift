import SwiftUI
import Combine
import ApplicationServices
import AppKit

class WritingTracker: ObservableObject {
    @Published var wordCount: Int = 0
    @Published var pageCount: Double = 0.0
    @Published var focusMinutes: Int = 0
    @Published var goalWords: Int = 2000
    @Published var progress: Double = 0.0
    @Published var hasAccessibilityPermission: Bool = false

    private var wordCountTimer: Timer?
    private var focusTimer: Timer?
    private let wordsPerPage: Double = 300.0

    init() {
        hasAccessibilityPermission = AXIsProcessTrusted()
        startTimers()
    }

    func startTimers() {
        // Word count polling every 1 second
        wordCountTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateWordCount()
        }

        // Focus timer every 60 seconds
        focusTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.focusMinutes += 1
        }
    }

    func updateWordCount() {
        hasAccessibilityPermission = AXIsProcessTrusted()

        guard hasAccessibilityPermission else {
            wordCount = 0
            updateDerivedValues()
            return
        }

        let count = getWordCountFromFrontmostApp()

        // Only update if changed to reduce UI refresh
        if count != wordCount {
            DispatchQueue.main.async {
                self.wordCount = count
                self.updateDerivedValues()
            }
        }
    }

    private func updateDerivedValues() {
        pageCount = Double(wordCount) / wordsPerPage
        progress = min(Double(wordCount) / Double(goalWords), 1.0)
    }

    func resetTimer() {
        focusMinutes = 0
    }

    func updateGoal(_ newGoal: Int) {
        goalWords = max(100, min(newGoal, 10000))
        updateDerivedValues()
    }

    private func getWordCountFromFrontmostApp() -> Int {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let pid = frontmostApp.processIdentifier as pid_t? else {
            return 0
        }

        let appElement = AXUIElementCreateApplication(pid)
        var focusedElement: CFTypeRef?

        // Get focused UI element
        let result = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )

        guard result == .success, let focused = focusedElement else {
            return 0
        }

        // Try to get text value
        var textValue: CFTypeRef?
        let textResult = AXUIElementCopyAttributeValue(
            focused as! AXUIElement,
            kAXValueAttribute as CFString,
            &textValue
        )

        guard textResult == .success, let text = textValue as? String else {
            // Try alternative: get selected text
            var selectedText: CFTypeRef?
            let selectedResult = AXUIElementCopyAttributeValue(
                focused as! AXUIElement,
                kAXSelectedTextAttribute as CFString,
                &selectedText
            )

            if selectedResult == .success, let selected = selectedText as? String {
                return countWords(in: selected)
            }

            return 0
        }

        return countWords(in: text)
    }

    private func countWords(in text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }

        let words = trimmed.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        return words.count
    }

    deinit {
        wordCountTimer?.invalidate()
        focusTimer?.invalidate()
    }
}
