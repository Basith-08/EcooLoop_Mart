# Security Policy

## ⚠️ IMPORTANT Security Warnings

### For Public Repository

**This repository is public. Please follow these security guidelines:**

### 1. Firebase Configuration Files (CRITICAL)

**❌ NEVER commit these files:**

- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
- Any `.env` files with API keys
- Private keys or certificates

**✅ These files are already in .gitignore:**

```gitignore
# Firebase sensitive files (DO NOT COMMIT TO PUBLIC REPO)
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
firebase-debug.log
.firebase/
```

**How to setup for new clones:**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `ecoloop-mart`
3. Download `google-services.json` for Android
4. Place it in `android/app/google-services.json`
5. **DO NOT commit this file**

### 2. Firebase API Keys in Code

The file `lib/firebase_options.dart` contains Firebase API keys. **This is SAFE for public repos** because:

- These are **client-side API keys** designed to be public
- Security is handled by **Firebase Security Rules**, not API key secrecy
- These keys are restricted by Firebase Console settings

**However, you MUST:**

- ✅ Setup proper **Firestore Security Rules** (see below)
- ✅ Enable **Firebase App Check** in production
- ✅ Configure **API restrictions** in Firebase Console

### 3. Firestore Security Rules

**⚠️ CRITICAL: Current rules are in TEST MODE (insecure)**

**Current rules (development only):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 2, 4);
    }
  }
}
```

**Production-ready rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users collection
    match /users/{username} {
      // Anyone authenticated can read
      allow read: if request.auth != null;

      // Only the user or admin can write
      allow write: if request.auth != null && (
        request.auth.token.username == username ||
        request.auth.token.role == 'admin'
      );
    }

    // Products collection
    match /products/{productId} {
      // Public read
      allow read: if true;

      // Only authenticated users (admin) can write
      allow write: if request.auth != null &&
                   request.auth.token.role == 'admin';
    }

    // Transactions collection
    match /transactions/{transactionId} {
      // Users can read their own transactions
      allow read: if request.auth != null && (
        resource.data.user_id == request.auth.uid ||
        request.auth.token.role == 'admin'
      );

      // Only authenticated users can create
      allow create: if request.auth != null;

      // No updates or deletes
      allow update, delete: if request.auth.token.role == 'admin';
    }

    // Wallets collection
    match /wallets/{walletId} {
      // Users can read their own wallet
      allow read: if request.auth != null && (
        resource.data.user_id == request.auth.uid ||
        request.auth.token.role == 'admin'
      );

      // Only system/admin can write
      allow write: if request.auth.token.role == 'admin';
    }
  }
}
```

### 4. Password Security

**⚠️ CURRENT ISSUE: Passwords are stored in PLAIN TEXT**

This is **INSECURE** and must be fixed before production!

**Recommended fix:**

```dart
// Add to pubspec.yaml
dependencies:
  crypto: ^3.0.3

// In user_repository.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  var bytes = utf8.encode(password + 'salt_here'); // Add proper salt
  var digest = sha256.convert(bytes);
  return digest.toString();
}

// Use when creating/checking passwords
'password': hashPassword(password)
```

**Better solution:**

Use **Firebase Authentication** instead of custom auth:
- Built-in password hashing
- Secure session management
- Email verification
- Password reset
- Multi-factor authentication

### 5. Environment Variables

**For additional sensitive data:**

Create `.env` file (already in .gitignore):

```env
# .env (DO NOT COMMIT)
FIREBASE_API_KEY=your_key_here
ADMIN_DEFAULT_PASSWORD=change_in_production
```

Load with `flutter_dotenv`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
String apiKey = dotenv.env['FIREBASE_API_KEY']!;
```

## Security Checklist

Before deploying to production:

### Firebase

- [ ] Update Firestore Security Rules to production rules
- [ ] Enable Firebase App Check
- [ ] Configure API restrictions in Firebase Console
- [ ] Review Firebase Authentication settings
- [ ] Enable Firebase Cloud Messaging (if using push notifications)
- [ ] Setup Firebase Crashlytics for error tracking

### Authentication

- [ ] Implement password hashing (or migrate to Firebase Auth)
- [ ] Add email verification
- [ ] Implement forgot password functionality
- [ ] Add rate limiting for login attempts
- [ ] Implement session timeout
- [ ] Add multi-factor authentication (optional)

### Data Protection

- [ ] Encrypt sensitive data at rest
- [ ] Use HTTPS for all network calls
- [ ] Implement data backup strategy
- [ ] Add audit logging for sensitive operations
- [ ] Implement data retention policies

### Code Security

- [ ] Remove debug logs in production builds
- [ ] Obfuscate Flutter code
- [ ] Enable ProGuard/R8 for Android
- [ ] Code signing for iOS
- [ ] Regular dependency updates
- [ ] Security audit of third-party packages

### Testing

- [ ] Penetration testing
- [ ] SQL injection testing (if applicable)
- [ ] XSS testing (for web version)
- [ ] Authentication bypass testing
- [ ] Data access control testing

## Reporting Security Issues

If you discover a security vulnerability:

1. **DO NOT** create a public GitHub issue
2. Email: [your-email@example.com]
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Best Practices for Contributors

1. **Never commit secrets** - Use .gitignore and environment variables
2. **Review changes** - Always review your commits before pushing
3. **Update dependencies** - Keep packages up to date
4. **Follow principle of least privilege** - Only grant necessary permissions
5. **Validate all inputs** - Never trust user input
6. **Use prepared statements** - Prevent SQL injection
7. **Implement CSRF protection** - For web version
8. **Enable HTTPS** - Always use secure connections

## Third-Party Dependencies Security

Regularly audit dependencies for vulnerabilities:

```bash
# Check for outdated packages
flutter pub outdated

# Update dependencies
flutter pub upgrade

# Check for security advisories
dart pub audit
```

## Production Deployment Checklist

### Before Publishing

- [ ] All sensitive files excluded from git
- [ ] Firebase Security Rules updated
- [ ] Password hashing implemented
- [ ] Debug logs removed
- [ ] Code obfuscated
- [ ] SSL/TLS certificates configured
- [ ] Privacy policy added
- [ ] Terms of service added
- [ ] App store security requirements met

### Monitoring

- [ ] Setup error tracking (Firebase Crashlytics)
- [ ] Enable logging for security events
- [ ] Monitor authentication failures
- [ ] Track suspicious activities
- [ ] Regular security audits

## Additional Resources

- [Firebase Security](https://firebase.google.com/docs/rules)
- [Flutter Security](https://docs.flutter.dev/security)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

---

**Last Updated**: 2026-01-04

**Remember: Security is an ongoing process, not a one-time setup!**
