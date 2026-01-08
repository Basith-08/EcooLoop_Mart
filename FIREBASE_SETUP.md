# Firebase Setup Guide - EcoLoop Mart

## 📋 Daftar Isi
1. [Konfigurasi Dasar](#konfigurasi-dasar)
2. [Firestore Security Rules](#firestore-security-rules)
3. [Firebase App Check](#firebase-app-check)
4. [Troubleshooting](#troubleshooting)

---

## 🔧 Konfigurasi Dasar

### 1. Tambahkan SHA-256 Fingerprint

**SHA-256 Debug Key:**
```
93:0C:64:4C:F0:87:F3:0F:B9:C7:74:13:65:0D:D4:21:35:0F:3D:69:21:4A:07:3B:CD:67:8B:D6:B4:E8:7B:B1
```

**Langkah:**
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project **EcoLoop Mart**
3. Klik ⚙️ **Settings** → **Project settings**
4. Scroll ke **"Your apps"** → Pilih Android app
5. Di **"SHA certificate fingerprints"**, klik **"Add fingerprint"**
6. Paste SHA-256 di atas
7. Klik **Save**
8. **Download** file `google-services.json` yang baru
9. Replace file di `android/app/google-services.json`

---

## 🔒 Firestore Security Rules

### Development Mode (Sekarang)

Gunakan rules dari file `firestore.rules` untuk development/testing.

**Cara Update di Firebase Console:**
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. **Firestore Database** → tab **Rules**
3. Copy isi dari file `firestore.rules`
4. Paste di editor
5. Klik **Publish**

**Karakteristik:**
- ✅ Semua collection bisa di-read
- ✅ Semua collection bisa di-write (untuk testing sync)
- ⚠️ **TIDAK AMAN** untuk production
- ⚠️ Data bisa diubah siapa saja

### Production Mode (Nanti)

Gunakan rules dari file `firestore.rules.production` untuk production.

**Prasyarat:**
- Harus implement Firebase Authentication di aplikasi
- Setiap user harus login dengan Firebase Auth
- User data harus punya field `role` (admin/warga)

**Karakteristik:**
- ✅ Hanya authenticated user yang bisa akses
- ✅ User hanya bisa lihat data mereka sendiri
- ✅ Admin punya full access
- ✅ AMAN untuk production

---

## 🛡️ Firebase App Check

### Status: AKTIF

Firebase App Check diaktifkan di `lib/main.dart` untuk keamanan tambahan.

### Requirements:
1. ✅ SHA-256 fingerprint harus terdaftar di Firebase Console
2. ✅ Play Integrity API aktif di Google Play Console (untuk production)

### Jika Masih Error:

**Error:** `Unknown calling package name 'com.google.android.gms'`

**Solusi:**
1. Pastikan SHA-256 sudah ditambahkan (lihat di atas)
2. Download `google-services.json` yang baru
3. Replace file `android/app/google-services.json`
4. Restart aplikasi

**Temporary Disable (untuk testing):**

Jika masih bermasalah, comment kode di `lib/main.dart`:

```dart
// await FirebaseAppCheck.instance.activate(
//   // Use Play Integrity for Android (requires SHA-256 in Firebase Console)
//   // Use debug provider for development/testing
// );
```

---

## 🐛 Troubleshooting

### Error: PERMISSION_DENIED

```
W/Firestore: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions.
```

**Solusi:**
- Update Firestore rules di Firebase Console dengan isi dari `firestore.rules`

### Error: Unknown calling package name

```
E/GoogleApiManager: java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'.
```

**Solusi:**
1. Tambahkan SHA-256 fingerprint di Firebase Console
2. Download `google-services.json` baru
3. Replace file di `android/app/google-services.json`

### Error: minSdkVersion

```
uses-sdk:minSdkVersion 21 cannot be smaller than version 23
```

**Solusi:**
- Sudah diperbaiki di `android/app/build.gradle`
- minSdk sekarang = 23

---

## 📱 Testing Sync Feature

### 1. Login ke aplikasi sebagai Admin

### 2. Cek Tombol Sync di AppBar
- Tombol sync ada di kanan atas (sebelah tombol logout)
- Icon: 3 titik vertikal (⋮)

### 3. Pilih Sync Mode:
- **Sync to Cloud** - Upload data local ke Firestore
- **Sync from Cloud** - Download data dari Firestore ke local
- **Bidirectional Sync** - Sync 2 arah (recommended)

### 4. Monitor Status:
- Loading indicator akan muncul
- Progress sync ditampilkan (Users, Products, Transactions, dll)
- Success/error message akan muncul

---

## 🔄 Workflow Development → Production

### Development (Sekarang):
1. ✅ Firebase initialized
2. ✅ App Check aktif (requires SHA-256)
3. ✅ Firestore rules: OPEN (semua bisa akses)
4. ✅ SQLite + Firestore hybrid sync

### Production (Nanti):
1. Implement Firebase Authentication
2. Update Firestore rules → `firestore.rules.production`
3. Update App Check dengan release SHA-256
4. Enable Firebase Analytics (optional)
5. Enable Cloud Functions untuk validasi server-side (optional)

---

## 📚 Resources

- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Security Rules Docs](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase App Check Docs](https://firebase.google.com/docs/app-check)
- [Play Integrity API](https://developer.android.com/google/play/integrity)

---

## ✅ Checklist Setup

- [ ] SHA-256 ditambahkan di Firebase Console
- [ ] `google-services.json` di-download dan di-replace
- [ ] Firestore rules di-update di Firebase Console
- [ ] Test sync feature (Sync to Cloud)
- [ ] Test sync feature (Sync from Cloud)
- [ ] Test sync feature (Bidirectional)
- [ ] Verify data di Firebase Console → Firestore Database

---

**Last Updated:** 2026-01-08
