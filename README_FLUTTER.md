# UPRM Professional Portfolio - Flutter Development Setup

A Tinder-style matching platform connecting UPRM students with recruiters and job opportunities.

## 🎯 Team Development Workflow

This repository serves as the main development hub for all teams working on different features. Follow this guide to set up your development environment and start contributing to your assigned feature branch.

## 🚀 Initial Setup (All Developers)

### Prerequisites
- **Flutter SDK** (3.1.0 or higher) - [Install Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** with Flutter/Dart plugins
- **Git** for version control
- **VS Code** (optional but recommended) with Flutter extensions

### Recommended Development Environment
- **Android Studio** with built-in emulator
- **Emulator**: `sdk gphone64 x86 64` (Android 16, API 36) - *Recommended by team lead*
- **IDE**: Android Studio or VS Code with Flutter extensions

### Step-by-Step Setup

#### 1. **Clone the Repository**
   ```bash
   git clone https://github.com/uprm-inso4116-2025-2026-s1/semester-project-uprm_professional_portfolio.git
   cd semester-project-uprm_professional_portfolio
   ```

#### 2. **Verify Flutter Installation**
   ```bash
   flutter doctor
   ```
   Ensure all checkmarks are green. Fix any issues before proceeding.

#### 3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

#### 4. **Set Up Android Emulator** (Recommended)
   - Open Android Studio → AVD Manager
   - Create Virtual Device → Phone → Pixel 7 Pro (or similar)
   - System Image: Android 16 (API 36) - x86_64
   - Name: `sdk gphone64 x86 64` (recommended by team lead)
   - Start the emulator

#### 5. **Verify Setup**
   ```bash
   flutter devices
   ```
   You should see your emulator listed as `emulator-5554`.

#### 6. **Run the App**
   ```bash
   flutter run -d emulator-5554
   ```

### 🚨 Common Issues & Fixes

#### Android NDK Version Mismatch
If you see NDK version errors during build:
1. Open `android/app/build.gradle.kts`
2. Find the `android` block
3. Update: `ndkVersion = "27.0.12077973"`
4. Restart: `flutter run`

#### First Build Takes Long
- Initial build: 3-5 minutes (normal)
- Subsequent builds: 15-30 seconds
- Hot reload: Instant changes

## 🏗️ Strategic Design Architecture (Domain-Driven Design)

### Bounded Contexts
- **Authentication Context** (`lib/features/auth/`)
  - Domain: User identity, access control, role management
  - Team: Accounts Team
  - Responsibilities: Login/signup flows, user sessions, profile setup

- **Matching Context** (`lib/features/matching/`)
  - Domain: Preference algorithms, compatibility scoring
  - Team: Matching Team  
  - Responsibilities: Swipe logic, recommendation engine

- **Communication Context** (`lib/features/communications/`)
  - Domain: Messaging, notifications, real-time updates
  - Team: Communications Team
  - Responsibilities: Chat APIs, push notifications, email alerts

- **Search & Filters Context** (`lib/features/searchFilters/`)
  - Domain: Job search, filtering, and sorting
  - Team: Search Team
  - Responsibilities: Search algorithms, filter settings, saved searches

- **Notifications Context** (`lib/features/notifications/`)
  - Domain: System alerts, user notifications
  - Team: Notifications Team
  - Responsibilities: Notification settings, push notification integration

### Context Map
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Authentication │    │    Matching     │    │ Communication   │
│    Context      │    │    Context      │    │    Context      │
│ (Accounts Team) │    │ (Matching Team) │    │  (Comms Team)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌────────▼────────┐              │
         └──────────────▶│  Shared Kernel  │◀─────────────┘
                         │   (lib/core/)   │
                         │ • Theme/Styling │
                         │ • Auth Services │
                         │ • Base Models   │
                         └─────────────────┘
                                  ▲
         ┌────────────────────────┼────────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Search/Filters  │    │  UI Components  │    │  Notifications  │
│    Context      │    │ (Enabling Team) │    │    Context      │
│ (Search Team)   │    │   (UI/UX Team)  │    │ (Notify Team)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘

Relationships:
• Shared Kernel: All contexts depend on lib/core/
• Customer/Supplier: UI Components → Feature Teams
• Published Language: API contracts in lib/models/
• Conformist: All teams follow established patterns
```

### Integration Patterns
- **Shared Kernel**: `lib/core/` (theme, constants, base services)
- **Customer/Supplier**: UI components → Feature teams
- **Published Language**: API contracts in `lib/models/`
- **Anti-Corruption Layer**: Service abstractions

### Conway's Law Application

**"Organizations design systems that mirror their communication structures"** - Melvin Conway

**Our Implementation:**

| Team Structure | Architecture Reflection | Communication Pattern |
|----------------|------------------------|----------------------|
| **Accounts Team** | `lib/features/auth/` bounded context | Direct ownership, independent development |
| **Matching Team** | `lib/features/matching/` bounded context | Algorithm focus, data science collaboration |
| **Communications Team** | `lib/features/communications/` context | Real-time systems, backend integration |
| **Search Team** | `lib/features/searchFilters/` context | Database queries, performance optimization |
| **Notifications Team** | `lib/features/notifications/` context | Cross-cutting concerns, all-team integration |
| **UI/UX Team** | `lib/components/` enabling services | Design system, supports all feature teams |
| **Backend Team** | `lib/core/services/` platform services | Infrastructure, API contracts |

**Benefits of This Alignment:**
- **Autonomous Development**: Each team can work independently on their bounded context
- **Clear Ownership**: No confusion about who owns which code areas
- **Reduced Conflicts**: Git merge conflicts minimized by clear boundaries
- **Scalable Communication**: Teams only need to coordinate on shared interfaces
- **Faster Delivery**: Parallel development without blocking dependencies

**Git Workflow Reflects Team Structure:**
- Each team has their own branch (`Accounts`, `Matching`, `Communication`, etc.)
- Shared components managed through controlled integration
- Code review process follows team boundaries

## 📁 Project Structure

```
lib/
├── main.dart                   # Entry point
├── core/                       # Core utilities and configuration
│   ├── constants/              # App constants (colors, strings, etc.)
│   ├── theme/                  # App theme and styling
│   ├── utils/                  # Helper functions (validators, formatters)
│   └── services/               # API services, authentication
├── models/                     # Data models (User, Profile, etc.)
├── components/                 # Reusable UI components
├── features/                   # Feature-based modules
│   ├── auth/                   # Authentication (login, signup)
│   ├── profiles/               # User profiles (recruiter, jobseeker)
    ├── matching/               # Matching Team
│   ├── communications/         # Comunnications Team
│   ├── notifications/          # Notifications Team
│   └── searchFilters/          # Shared features
│   └── common/                 # Shared features
└── routes/                     # App navigation and routing
```

## 🛠️ Development Guidelines

### Code Style
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Run `flutter analyze` before committing

## 🌿 Git Workflow for All Teams

### Branch Structure
```
main                # Production-ready code
├── Accounts        # Authentication & User Management
├── Matching        # Swipe & Matching Algorithm  
├── Communication   # Communication System
├── Search Filters  # Filter Functionlity
└── Notifications   # Notifications Implementation
```

### Development Workflow

#### 1. **Start Working on Your Feature**
   ```bash
   # Switch to your team's branch
   git checkout [your-team-branch]  # e.g., Accounts, Matching, Chat, etc.
   
   # Pull latest changes
   git pull origin [your-team-branch]
   

#### 2. **Daily Development**
   ```bash
   # Make your changes
   # Test thoroughly with: flutter run
   
   # Commit your work
   git add .
   git commit -m "feat: implement [specific feature]"
   
   # Push to your branch
   git push origin feature-branch/your-issue-name
   ```

#### 3. **Code Review & Integration**
   ```bash
   # Create Pull Request to your team branch (not main!)
   # Request review from team members
   # Merge after approval
   ```

## �️ Development Guidelines (All Teams)

### Code Quality Standards
- **Dart Style**: Follow the [official Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Naming**: Use meaningful variable and function names
- **Comments**: Document complex logic and public APIs
- **Analysis**: Run `flutter analyze` before committing (zero warnings goal)
- **Formatting**: Use `flutter format .` to maintain consistent code style

### Testing Requirements
- **Unit Tests**: Write tests for business logic and services
- **Widget Tests**: Test UI components and user interactions  
- **Integration Tests**: Test complete user flows
- **Coverage**: Aim for 80%+ test coverage on your team's code
- **Command**: `flutter test` to run all tests

### Performance Guidelines
- **Hot Reload**: Use for quick UI changes during development
- **Build Time**: Keep dependencies minimal to maintain fast builds
- **Memory**: Profile app performance with Flutter DevTools
- **Images**: Optimize assets and use appropriate image formats

### Security Best Practices
- **API Keys**: Never commit secrets to version control
- **Validation**: Always validate user input on both client and server
- **Authentication**: Follow OAuth 2.0 and JWT best practices
- **Data**: Encrypt sensitive data and use HTTPS for all communications

## 📁 Key Project Files & Directories

### Core Architecture
```
lib/
├── main.dart                   # App entry point
├── core/                       # Shared utilities
│   ├── constants/              # App-wide constants
│   ├── theme/                  # UPRM branding & Material 3
│   ├── utils/                  # Helper functions
│   └── services/               # API & authentication services
├── models/                     # Data models (User, Job, etc.)
├── components/                 # Reusable UI components
├── features/                   # Feature-based modules
│   ├── auth/                   # Accounts Team
│   ├── matching/               # Matching Team
│   ├── communications/         # Comunnications Team
│   ├── notifications/          # Notifications Team
│   └── searchFilters/          # Shared features
└── routes/                     # Navigation & routing
```


## 🔧 Essential Commands

### Daily Development
```bash
# Get/update dependencies
flutter pub get

# Run on emulator (recommended)
flutter run -d emulator-5554

# Run with hot reload (default)
flutter run

# Run tests
flutter test

# Code analysis
flutter analyze

# Format code
flutter format .

# Clean build (if issues)
flutter clean && flutter pub get
```

### Build Commands
```bash
# Debug build (development)
flutter run --debug

# Release build (testing)
flutter run --release

# Build APK (Android)
flutter build apk

# Build for iOS
flutter build ios

# Build for web (testing)
flutter build web
```

## 📱 Supported Platforms
- **Android** (API 21+) - Primary target
- **iOS** (11.0+) - Secondary target  
- **Web** (for development/testing only)
- **Windows/macOS/Linux** (future consideration)

## 👥 Team Communication & Support

### Code Reviews
- **Required**: All PRs need at least one team member review
- **Focus**: Code quality, functionality, and team standards
- **Tools**: GitHub PR review system
- **Timeline**: Aim for 24-48 hour review turnaround

### Getting Help
1. **GitHub Issues**: Create issues for bugs or feature discussions
2. **Team Channels**: Use your team's communication channel
3. **Documentation**: Check `functionality_files/` for project specs
4. **Code Examples**: Look at existing implementations in other features

### Reporting Issues
- **Bugs**: Use GitHub issues with reproduction steps
- **Feature Requests**: Discuss with your team lead first
- **Build Issues**: Check this README's troubleshooting section
- **Git Issues**: Coordinate with team members to resolve conflicts

### Learning Objectives
- Modern Flutter development practices
- Team-based software engineering
- Agile development methodologies  
- Real-world application architecture
- Professional code review processes
- Cross-platform mobile development

### Project Scope
This application demonstrates a complete end-to-end development process, from initial setup through feature implementation, testing, and deployment preparation.

---

## 🚀 Ready to Start?

1. **Set up your environment** following the setup guide above
2. **Join your team's branch** and review team-specific documentation
3. **Run the app** to see the current state
4. **Start coding** your assigned features
5. **Follow the workflow** for commits and code reviews

**Welcome to the UPRM Professional Portfolio development team!** 🎯

*Last updated: October 1, 2025*
