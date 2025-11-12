# Contributing Guide

## 🎯 Quick Start

### Setup (3 commands)
```bash
git clone <repository-url>
cd semester-project-uprm_professional_portfolio
flutter pub get
flutter run
```

## 🔒 Security Rules

### ⚠️ NEVER Commit
- `.env` files
- API keys or passwords

### ✅ ALWAYS Commit
- Code changes
- Documentation updates

## 🌿 Branch Strategy

### Branch Naming
- `feature/name` - New features
- `fix/name` - Bug fixes
- `docs/name` - Documentation
- `refactor/name` - Code refactoring

### Current Branches
- `main` - Production
- `Accounts` - Milestone 2 (active)

## 📝 Commit Format

```
type(scope): description

Examples:
feat(auth): add password reset
fix(profile): resolve loading crash
docs(readme): update setup guide
```

## 🔄 Workflow

1. Create branch: `git checkout -b feature/your-feature`
2. Make changes & test locally
3. Commit: `git commit -m "feat: description"`
4. Push: `git push origin feature/your-feature`
5. Create Pull Request on GitHub

## 🐛 Common Issues

**Build errors after pull:**
```bash
flutter clean && flutter pub get && flutter run
```

**Hot reload not working:** Press `R` (capital R)

## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Bloc Docs](https://bloclibrary.dev/)


