import SwiftUI

struct ProgressBarOverlayView: View {
    @ObservedObject var tracker: WritingTracker
    @State private var isHovered = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 6) {
            // First row: Info
            HStack(spacing: 10) {
                // Word count
                HStack(spacing: 4) {
                    Text("\(tracker.wordCount)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text("/ \(tracker.goalWords)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Progress percentage
                Text("\(Int(tracker.progress * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Pages
                Text("\(tracker.pageCount, specifier: "%.1f") pg")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                // Timer
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 10))
                    Text("\(tracker.focusMinutes)m")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.8))
                
                // Reset button
                Button(action: {
                    tracker.resetTimer()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.plain)
                .help("Reset timer")
            }
            
            // Second row: Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)

                    // Progress fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), .cyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geometry.size.width * tracker.progress), height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: tracker.progress)
                }
            }
            .frame(height: 8)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .shadow(color: .blue.opacity(isHovered ? 0.3 : 0.0), radius: 6)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onTapGesture {
                showSettings.toggle()
            }
            .onHover { hovering in
                isHovered = hovering
            }
            .popover(isPresented: $showSettings, arrowEdge: .top) {
                SettingsPopover(tracker: tracker)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsPopover: View {
    @ObservedObject var tracker: WritingTracker
    @State private var tempGoal: Double

    init(tracker: WritingTracker) {
        self.tracker = tracker
        self._tempGoal = State(initialValue: Double(tracker.goalWords))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Daily Word Goal")
                .font(.headline)

            HStack {
                Text("\(Int(tempGoal))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                Text("words")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Slider(value: $tempGoal, in: 1000...10000, step: 100)
                .onChange(of: tempGoal) { oldValue, newValue in
                    tracker.updateGoal(Int(newValue))
                }

            HStack {
                Text("1,000")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("10,000")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(tracker.progress * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(max(0, tracker.goalWords - tracker.wordCount))")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(20)
        .frame(width: 280)
    }
}

struct SettingsView: View {
    @ObservedObject var tracker: WritingTracker

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.pages")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("OpenLore")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Writing Tracker")
                .font(.headline)
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Current Words:")
                    Spacer()
                    Text("\(tracker.wordCount)")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Daily Goal:")
                    Spacer()
                    Text("\(tracker.goalWords)")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Focus Time:")
                    Spacer()
                    Text("\(tracker.focusMinutes) minutes")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Accessibility:")
                    Spacer()
                    Text(tracker.hasAccessibilityPermission ? "Enabled" : "Disabled")
                        .foregroundColor(tracker.hasAccessibilityPermission ? .green : .red)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            if !tracker.hasAccessibilityPermission {
                Button("Grant Accessibility Permission") {
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                    NSWorkspace.shared.open(url)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()

            Text("Click the menu bar icon to access this window")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ProgressBarOverlayView(tracker: WritingTracker())
        .frame(width: 450, height: 36)
}
