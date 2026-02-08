import SwiftUI

enum OverlayTab: Int, CaseIterable {
    case progress = 0
    case ambience = 1
}

struct ProgressBarOverlayView: View {
    @ObservedObject var tracker: WritingTracker
    @State private var isHovered = false
    @State private var showSettings = false
    @State private var scrollPosition: Int? = 0
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ProgressTabView(tracker: tracker, isHovered: $isHovered, showSettings: $showSettings)
                        .containerRelativeFrame(.horizontal)
                        .id(0)
                    
                    AmbienceTabView()
                        .containerRelativeFrame(.horizontal)
                        .id(1)
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPosition)
            
            // Scroll indicator overlay
            VStack {
                Spacer()
                ScrollIndicator(
                    currentIndex: scrollPosition ?? 0,
                    totalPages: 2
                )
                .opacity(isHovered ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
            }
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                isHovered = hovering
            }
            
            // When hover ends, scroll back to progress view if on ambience view
            if !hovering && scrollPosition == 1 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    scrollPosition = 0
                }
            }
        }
    }
}

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Custom view to handle scroll wheel events
enum ScrollDirection {
    case left, right
}

struct ScrollWheelHandler: NSViewRepresentable {
    let onScroll: (ScrollDirection) -> Void
    
    func makeNSView(context: Context) -> ScrollWheelView {
        let view = ScrollWheelView()
        view.onScroll = onScroll
        return view
    }
    
    func updateNSView(_ nsView: ScrollWheelView, context: Context) {
        nsView.onScroll = onScroll
    }
}

class ScrollWheelView: NSView {
    var onScroll: ((ScrollDirection) -> Void)?
    private var accumulatedDelta: CGFloat = 0
    private let threshold: CGFloat = 30
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollWheel(with event: NSEvent) {
        // Handle horizontal scroll from trackpad or shift+scroll
        let delta: CGFloat
        
        if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) {
            // Horizontal scroll (trackpad horizontal swipe)
            delta = event.scrollingDeltaX
        } else if event.modifierFlags.contains(.shift) {
            // Shift + vertical scroll (converted to horizontal)
            delta = event.scrollingDeltaY
        } else {
            // Regular vertical scroll - ignore
            super.scrollWheel(with: event)
            return
        }
        
        if event.phase == .began {
            accumulatedDelta = 0
        }
        
        accumulatedDelta += delta
        
        // Trigger page change when threshold is reached
        if abs(accumulatedDelta) >= threshold {
            onScroll?(accumulatedDelta > 0 ? .right : .left)
            accumulatedDelta = 0
        }
        
        // When scrolling ends, reset
        if event.phase == .ended || event.phase == .cancelled {
            accumulatedDelta = 0
        }
    }
}

// Page indicator dots
struct ScrollIndicator: View {
    let currentIndex: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(currentIndex == index ? Color.white.opacity(0.9) : Color.white.opacity(0.3))
                    .frame(width: currentIndex == index ? 6 : 5, height: currentIndex == index ? 6 : 5)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
            }
        }
        .padding(.bottom, 8)
    }
}

struct ProgressTabView: View {
    @ObservedObject var tracker: WritingTracker
    @Binding var isHovered: Bool
    @Binding var showSettings: Bool
    @State private var isProgressBarHovered = false
    
    var body: some View {
        
        
        VStack(spacing: 6) {
            
            
            // First row: Info
            HStack {
                // Word count
                HStack(spacing: 4) {
                    Text("\(tracker.wordCount)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text("/ \(tracker.goalWords)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Progress percentage and page count (center)
                HStack(spacing: 6) {
                    Text("\(min(Int(tracker.progress * 100), 100))%")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("•")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("\(tracker.pageCount, specifier: "%.1f") pg")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Timer with controls
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(tracker.focusMinutes)m")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Play/Stop button
                    Button(action: {
                        tracker.toggleTimer()
                    }) {
                        Image(systemName: tracker.isTimerRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                    .help(tracker.isTimerRunning ? "Stop timer" : "Start timer")
                    
                    // Reset button (only show when timer is stopped)
                    if !tracker.isTimerRunning {
                        Button(action: {
                            tracker.resetTimer()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.plain)
                        .help("Reset timer")
                    }
                }
            }
            .padding(.horizontal, 14)
            
            // Second row: Clickable Progress bar
            GeometryReader { geometry in
                Button(action: {
                    showSettings.toggle()
                }) {
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)

                        // Progress fill - changes to green when complete
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: tracker.progress >= 1.0 
                                        ? [.green.opacity(0.8), .mint.opacity(0.8)]
                                        : [.blue.opacity(0.8), .cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geometry.size.width * min(tracker.progress, 1.0)), height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: tracker.progress)
                    }
                    .padding(.horizontal, 14)
                    .opacity(isProgressBarHovered ? 0.6 : 1.0)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    isProgressBarHovered = hovering
                }
                .help("Click to adjust goal")
                .popover(isPresented: $showSettings, arrowEdge: .top) {
                    SettingsPopover(tracker: tracker)
                }
            }
            .frame(height: 15)
            .shadow(color: tracker.progress >= 1.0 ? .green.opacity(isHovered ? 0.3 : 0.0) : .blue.opacity(isHovered ? 0.3 : 0.0), radius: 6)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .padding(.vertical, 4)
        
    }
}

struct AmbienceTabView: View {
    @StateObject private var audioManager = AmbienceAudioManager.shared
    
    var body: some View {
        VStack(spacing: 6) {
            // Header
            HStack {
                Text("Ambience")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Sound wave icon - changes when playing
                Image(systemName: audioManager.isPlaying ? "waveform" : "waveform.slash")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .animation(.easeInOut(duration: 0.2), value: audioManager.isPlaying)
            }
            .padding(.horizontal, 14)
            
            // Sound selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AmbienceSound.allCases, id: \.self) { sound in
                        SoundButton(sound: sound, isSelected: audioManager.currentSound == sound) {
                            print("🔵 Button tapped: \(sound.name)")
                            audioManager.toggleSound(sound)
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
            .frame(height: 26)
        }
        .padding(.vertical, 4)
        .onAppear {
            print("🟢 AmbienceTabView appeared")
        }
    }
}

struct SoundButton: View {
    let sound: AmbienceSound
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: sound.icon)
                    .font(.system(size: 9))
                
                Text(sound.name)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.6) : Color.white.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }
}

enum AmbienceSound: String, CaseIterable {
    case rain
    case ocean
    case forest
    case dreams
    
    var name: String {
        switch self {
        case .rain: return "Rain"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .dreams: return "Dreams"
        }
    }
    
    var icon: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .ocean: return "water.waves"
        case .forest: return "leaf.fill"
        case .dreams: return "moon.stars.fill"
        }
    }
    
    var fileName: String {
        switch self {
        case .rain: return "rain"
        case .ocean: return "ocean"
        case .forest: return "forest"
        case .dreams: return "dreams"
        }
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
            Text("Word Goal")
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
                    Text("\(min(Int(tracker.progress * 100), 100))%")
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
