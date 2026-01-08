# Firebase Authentication Guide - EcoLoop Mart

## 📋 Daftar Isi
1. [Aktivasi Firebase Authentication](#1-aktivasi-firebase-authentication)
2. [Implementasi yang Sudah Dibuat](#2-implementasi-yang-sudah-dibuat)
3. [Cara Menggunakan](#3-cara-menggunakan)
4. [Update Firestore Rules](#4-update-firestore-rules)
5. [Testing](#5-testing)

---

## 1. Aktivasi Firebase Authentication

### Langkah di Firebase Console:

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project **EcoLoop Mart**
3. Di menu kiri, klik **Authentication**
4. Klik tab **Sign-in method**
5. Klik **Email/Password**
6. Toggle **Enable**
7. Klik **Save**

**Selesai!** Firebase Authentication sudah siap digunakan.

---

## 2. Implementasi yang Sudah Dibuat

### ✅ File yang Dibuat/Diupdate:

1. **`lib/core/services/firebase_auth_service.dart`** (NEW)
   - Service untuk handle Firebase Authentication
   - Methods: register, login, logout, password reset, dll
   - Error handling dalam Bahasa Indonesia

2. **`lib/viewmodel/auth_viewmodel.dart`** (UPDATED)
   - Integrate dengan Firebase Auth
   - Hybrid approach: Firebase Auth + Local SQLite
   - Auto-sync user ke Firestore

3. **`lib/main.dart`** (UPDATED)
   - Inject FirebaseAuthService ke AuthViewModel
   - Provider setup

4. **`pubspec.yaml`** (UPDATED)
   - Dependency: `firebase_auth: ^6.1.3`

---

## 3. Cara Menggunakan

### A. Register User Baru

**PENTING**: Email sekarang **WAJIB** untuk registrasi!

**Sebelum (Tanpa Firebase Auth):**
```dart
await authViewModel.register(name, username, password);
```

**Sekarang (Dengan Firebase Auth):**
```dart
// Email parameter WAJIB
await authViewModel.register(name, username, password, email: email);
```

**Yang Terjadi:**
1. ✅ Buat account di Firebase Auth (dengan email + password)
2. ✅ Simpan user ke SQLite local
3. ✅ Auto-sync ke Firestore
4. ❌ Jika gagal: Rollback (hapus Firebase account)

### B. Login User

**Code tetap sama:**
```dart
await authViewModel.login(username, password);
```

**Yang Terjadi:**
1. ✅ Login ke SQLite local (username + password)
2. ✅ Firebase Auth session otomatis tersimpan
3. ✅ User data sync ke Firestore

### C. Logout

**Code tetap sama:**
```dart
await authViewModel.logout();
```

**Yang Terjadi:**
1. ✅ Sign out dari Firebase Auth
2. ✅ Clear local user session

### D. Check Auth State

**Code tetap sama:**
```dart
await authViewModel.checkAuth();
```

**Yang Terjadi:**
1. ✅ Cek Firebase Auth status
2. ✅ Load user data dari local SQLite
3. ✅ Auto-login jika Firebase session masih aktif

---

## 4. Update Firestore Rules

### Sekarang Gunakan Production Rules!

Firebase Authentication sudah aktif, saatnya gunakan production Firestore rules yang aman.

**File**: `firestore.rules.production`

**Langkah:**
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. **Firestore Database** → tab **Rules**
3. **Copy** isi file `firestore.rules.production`
4. **Paste** di editor Firebase Console
5. Klik **Publish**

**Production Rules Features:**
- ✅ Hanya authenticated user yang bisa akses
- ✅ User hanya bisa lihat data mereka sendiri
- ✅ Admin punya full access
- ✅ Role-based access control
- ✅ AMAN untuk production

**Sample Production Rules:**
```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isAdmin() {
      return isSignedIn() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Users collection - hanya owner atau admin
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Transactions - user hanya lihat transaksi mereka
    match /transactions/{transactionId} {
      allow read: if isSignedIn() &&
                    (resource.data.user_id == request.auth.uid || isAdmin());
      allow create: if isSignedIn();
      allow update, delete: if isAdmin();
    }
  }
}
```

---

## 5. Testing

### Test 1: Register User Baru

1. Buka aplikasi
2. Klik **Register**
3. Isi form:
   - Nama: `Test User`
   - Username: `testuser`
   - Email: `test@example.com` **(WAJIB)**
   - Password: `password123`
4. Klik **Register**

**Expected Result:**
- ✅ User berhasil register
- ✅ Auto-login
- ✅ Redirect ke home page
- ✅ Cek di Firebase Console → Authentication → Users (user baru muncul)
- ✅ Cek di Firestore Database (user data tersimpan)

### Test 2: Login

1. Logout dari aplikasi
2. Login dengan:
   - Username: `testuser`
   - Password: `password123`

**Expected Result:**
- ✅ Berhasil login
- ✅ Firebase Auth session aktif
- ✅ Redirect ke home page

### Test 3: Persistent Login

1. Close aplikasi
2. Buka aplikasi lagi

**Expected Result:**
- ✅ Auto-login (tidak perlu login lagi)
- ✅ Langsung masuk ke home page

### Test 4: Logout

1. Klik **Logout**

**Expected Result:**
- ✅ Berhasil logout
- ✅ Firebase Auth session cleared
- ✅ Redirect ke login page

---

## 6. Error Handling

### Error Messages (Bahasa Indonesia):

| Error Code | Pesan |
|------------|-------|
| `weak-password` | Password terlalu lemah. Gunakan minimal 6 karakter. |
| `email-already-in-use` | Email sudah terdaftar. Gunakan email lain atau login. |
| `invalid-email` | Format email tidak valid. |
| `user-not-found` | User tidak ditemukan. Periksa email Anda. |
| `wrong-password` | Password salah. Coba lagi. |
| `network-request-failed` | Tidak ada koneksi internet. |

### Handling di UI:

```dart
// Listen to auth state
authViewModel.addListener(() {
  final state = authViewModel.state;

  if (state is AuthError) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message)),
    );
  } else if (state is Authenticated) {
    // Navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }
});
```

---

## 7. Migrasi dari User Lama

### Untuk user yang sudah terdaftar sebelum Firebase Auth:

**Option 1: Force Re-register (Recommended)**
- User lama harus register ulang dengan email
- Data lama tetap tersimpan di SQLite
- Buat Firebase Auth account untuk mereka

**Option 2: Manual Migration Script**
- Buat script untuk create Firebase account untuk semua user existing
- Gunakan email dari database (jika ada)
- Generate password temporary

**Sample Migration Script:**
```dart
Future<void> migrateExistingUsers() async {
  final users = await userRepository.getAllUsers();

  for (var user in users) {
    if (user.email != null && user.email!.isNotEmpty) {
      try {
        // Create Firebase account with temporary password
        await firebaseAuth.registerWithEmailPassword(
          user.email!,
          'TempPassword123!' // User harus reset password
        );

        // Send password reset email
        await firebaseAuth.sendPasswordResetEmail(user.email!);

        print('Migrated: ${user.username}');
      } catch (e) {
        print('Failed to migrate ${user.username}: $e');
      }
    }
  }
}
```

---

## 8. Best Practices

### ✅ DO:
- Selalu validate email format di UI
- Gunakan minimum 6 karakter untuk password
- Implement password strength indicator
- Show loading state saat register/login
- Handle network errors dengan graceful message
- Log user actions untuk debugging

### ❌ DON'T:
- Jangan simpan password plain text
- Jangan skip email validation
- Jangan hardcode error messages
- Jangan lupa handle edge cases (no internet, etc)

---

## 9. Troubleshooting

### Problem: "Email already in use"

**Solusi:**
1. User sudah pernah register sebelumnya
2. Arahkan user untuk login instead
3. Atau gunakan "Forgot Password" untuk reset

### Problem: "Weak password"

**Solusi:**
1. Firebase requires minimum 6 characters
2. Update UI untuk inform user
3. Add password strength indicator

### Problem: "Network request failed"

**Solusi:**
1. Check internet connection
2. Retry dengan backoff strategy
3. Queue operations untuk retry later

---

## 10. Next Steps

### Feature yang Bisa Ditambahkan:

1. **Email Verification**
   ```dart
   await user.sendEmailVerification();
   ```

2. **Password Reset**
   ```dart
   await firebaseAuth.sendPasswordResetEmail(email);
   ```

3. **Social Login** (Google, Facebook, dll)
   ```dart
   await GoogleSignIn().signIn();
   ```

4. **Phone Authentication**
   ```dart
   await firebaseAuth.verifyPhoneNumber(phoneNumber);
   ```

5. **2FA (Two-Factor Authentication)**
   - Multi-factor authentication
   - SMS verification

---

## 11. Resources

- [Firebase Auth Docs](https://firebase.google.com/docs/auth)
- [Flutter Fire Auth](https://firebase.flutter.dev/docs/auth/overview/)
- [Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Last Updated:** 2026-01-08
