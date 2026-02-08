# Contributing to OpenLore

First off, thank you for considering contributing to OpenLore! It's people like you that make OpenLore such a great tool for writers.

## Code of Conduct

This project and everyone participating in it is governed by respect, kindness, and collaboration. By participating, you are expected to uphold these values.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

**Bug Report Template:**

```
**Description**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected Behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
- macOS Version: [e.g., Sonoma 14.2]
- OpenLore Version: [e.g., 1.0.0]
- Application where issue occurred: [e.g., TextEdit, VS Code]

**Additional Context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description** of the suggested enhancement
- **Use cases** explaining why this would be useful
- **Possible implementation** if you have ideas
- **Mockups or examples** if applicable

### Pull Requests

1. **Fork the repo** and create your branch from `main`:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Follow the coding style** used throughout the project:
   - Use SwiftUI best practices
   - Follow Swift naming conventions
   - Use meaningful variable and function names
   - Add comments for complex logic

3. **Write or update tests** if applicable

4. **Ensure the app builds and runs** without errors

5. **Update documentation** if you changed functionality

6. **Commit your changes** with clear, descriptive messages:
   ```bash
   git commit -m "Add feature: customizable overlay position"
   ```

7. **Push to your fork** and submit a pull request

8. **Respond to feedback** during code review

## Development Setup

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 6.0

### Getting Started

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/OpenLore.git
   cd OpenLore
   ```

2. Open the project in Xcode:
   ```bash
   open OpenLore.xcodeproj
   ```

3. Enable Accessibility permissions for development

4. Build and run (⌘R)

## Coding Guidelines

### Swift Style

- Use Swift 6.0 features and syntax
- Prefer `let` over `var` when possible
- Use type inference when the type is obvious
- Use guard statements for early returns
- Avoid force unwrapping (`!`) when possible

### SwiftUI Best Practices

- Keep views small and composable
- Extract complex views into separate components
- Use `@StateObject` for owned objects, `@ObservedObject` for passed objects
- Prefer `onChange(of:)` over manual observation

### Code Organization

```swift
// MARK: - Properties
// Group properties by type (state, binding, observed, etc.)

// MARK: - Initialization
// Initializers and setup

// MARK: - Body
// Main view body

// MARK: - Private Methods
// Helper methods

// MARK: - Subviews
// Private view components
```

### Comments

- Use comments to explain **why**, not **what**
- Document complex algorithms
- Use `// MARK:` to organize code sections
- Add documentation comments for public APIs:

```swift
/// Tracks writing progress across applications
/// - Parameter text: The text content to analyze
/// - Returns: The word count
func countWords(in text: String) -> Int {
    // Implementation
}
```

## Project Structure

```
OpenLore/
├── OpenLoreApp.swift              # App entry and menu bar
├── WritingTracker.swift           # Core tracking logic
├── ProgressBarOverlayView.swift   # UI components
├── OpenLoreTests/                 # Unit tests
└── OpenLoreUITests/               # UI tests
```

## Testing

- Write unit tests for business logic
- Write UI tests for critical user flows
- Run tests before submitting PR: ⌘U
- Ensure all tests pass

### Testing Tips

```swift
import Testing

@Suite("Writing Tracker Tests")
struct WritingTrackerTests {
    
    @Test("Word count calculation")
    func testWordCount() async throws {
        let tracker = WritingTracker()
        let text = "Hello world this is a test"
        
        #expect(tracker.countWords(in: text) == 6)
    }
}
```

## Commit Messages

Use clear and meaningful commit messages:

**Good:**
```
Add customizable overlay position
Fix word count accuracy for multi-line text
Update README with installation instructions
```

**Bad:**
```
Fixed stuff
Update
WIP
```

### Commit Message Format

```
<type>: <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## Review Process

1. A maintainer will review your PR
2. Address any requested changes
3. Once approved, your PR will be merged
4. Your contribution will be credited

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes (for significant contributions)
- Future CONTRIBUTORS.md file

## Questions?

Feel free to open an issue with the `question` label if you need help or clarification.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to OpenLore! 🎉📝
