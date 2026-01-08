# 🔥 Cara Pakai Firebase Authentication - EcoLoop Mart

## ✅ Langkah 1: Aktivasi Firebase Authentication (SUDAH SELESAI)

Anda sudah mengaktifkan Firebase Authentication di Firebase Console. Bagus!

---

## 📱 Langkah 2: Test Register User Baru

### Cara Register:

1. **Buka aplikasi** EcoLoop Mart
2. Klik **"Belum punya akun? Daftar"**
3. Isi form register:
   - **Nama Lengkap**: Contoh: `Budi Santoso`
   - **Username**: Contoh: `budi123`
   - **Email**: Contoh: `budi@example.com` ⚠️ **WAJIB!**
   - **Password**: Minimal 6 karakter, contoh: `password123`
4. Klik **"Daftar Sekarang"**

### Yang Terjadi di Belakang Layar:

1. ✅ Buat account di **Firebase Authentication** dengan email + password
2. ✅ Simpan data user ke **SQLite** local
3. ✅ Auto-sync data user ke **Firestore**
4. ✅ Auto-login dan masuk ke halaman utama

### Verifikasi Berhasil:

**A. Cek di Firebase Console:**

1. Buka https://console.firebase.google.com/
2. Pilih project **EcoLoop Mart**
3. Menu → **Authentication** → tab **Users**
4. User baru Anda akan muncul di sini!

**B. Cek di Firestore Database:**

1. Firestore Database → tab **Data**
2. Collection **users**
3. Data user Anda tersimpan di sini!

---

## 🔐 Langkah 3: Test Login

### Cara Login:

1. **Logout** dulu dari aplikasi (jika sudah login)
2. Buka aplikasi
3. Isi form login:
   - **Username**: `budi123`
   - **Password**: `password123`
4. Klik **"Masuk"**

### Yang Terjadi:

1. ✅ Login ke SQLite local (cek username + password)
2. ✅ Firebase Auth session otomatis aktif
3. ✅ Data user sync ke Firestore
4. ✅ Masuk ke halaman utama

---

## 🔄 Langkah 4: Test Persistent Login

### Test Auto-Login:

1. **Close aplikasi** (force close)
2. **Buka aplikasi lagi**

### Expected Result:

✅ **Auto-login!** Langsung masuk ke halaman utama tanpa perlu login lagi.

**Kenapa?** Firebase Auth menyimpan session, jadi user tidak perlu login setiap kali buka aplikasi.

---

## 🛡️ Langkah 5: Update Firestore Rules (PENTING!)

Sekarang Anda sudah punya Firebase Authentication, saatnya gunakan **Production Firestore Rules** yang aman!

### Cara Update:

1. Buka https://console.firebase.google.com/
2. **Firestore Database** → tab **Rules**
3. **Hapus semua** isi yang lama
4. **Copy** isi dari file `firestore.rules.production` di project
5. **Paste** di editor Firebase Console
6. Klik **Publish**

### Apa Bedanya?

**Sebelum (Development Rules):**
```javascript
// TIDAK AMAN - Siapa saja bisa akses!
match /{document=**} {
  allow read, write: true;
}
```

**Sekarang (Production Rules):**
```javascript
// AMAN - Hanya authenticated user yang bisa akses
function isSignedIn() {
  return request.auth != null;
}

match /users/{userId} {
  allow read: if isSignedIn();
  allow update: if isOwner(userId) || isAdmin();
}
```

### Keamanan Production Rules:

- ✅ Hanya **authenticated user** yang bisa baca/tulis data
- ✅ User hanya bisa **edit data mereka sendiri**
- ✅ Admin punya **full access**
- ✅ **Role-based** access control
- ✅ **AMAN** untuk production

---

## 🎯 Langkah 6: Test Sync ke Firestore

### Cara Test Sync:

1. **Login** sebagai user (budi123)
2. Lakukan beberapa aksi:
   - Setor sampah (akan buat transaksi)
   - Tukar poin (akan update wallet)
3. **Klik tombol Sync** di kanan atas (⋮ menu)
4. Pilih **"Bidirectional Sync"**

### Verifikasi:

1. Buka Firebase Console → **Firestore Database**
2. Collection yang tersync:
   - ✅ `users` - Data user
   - ✅ `transactions` - Transaksi setor/tukar
   - ✅ `wallets` - Saldo poin user
   - ✅ `products` - Produk katalog
   - ✅ `partners` - Partner pengrajin/grosir
   - ✅ `waste_rates` - Harga sampah

---

## ❌ Error yang Mungkin Muncul

### Error 1: "Email already in use"

**Penyebab:** Email sudah pernah didaftarkan sebelumnya.

**Solusi:**
- Gunakan email lain
- Atau login dengan email tersebut

### Error 2: "Format email tidak valid"

**Penyebab:** Email tidak sesuai format (contoh: salah ketik, tidak ada @, dll).

**Solusi:**
- Pastikan format: `nama@domain.com`
- Contoh valid: `budi@gmail.com`, `test@example.com`

### Error 3: "Password terlalu lemah"

**Penyebab:** Password kurang dari 6 karakter.

**Solusi:**
- Gunakan minimal **6 karakter**
- Contoh: `password123`, `mypass456`

### Error 4: "Tidak ada koneksi internet"

**Penyebab:** Tidak ada internet saat register/login.

**Solusi:**
- Pastikan internet aktif
- Firebase Auth butuh internet untuk register/login

### Error 5: "Permission Denied" di Firestore

**Penyebab:** Firestore rules belum di-update.

**Solusi:**
- Update Firestore rules ke production (Langkah 5 di atas)

---

## 🧪 Test Checklist

Cek semua ini untuk memastikan Firebase Auth berfungsi:

- [ ] Register user baru dengan email berhasil
- [ ] User muncul di Firebase Console → Authentication
- [ ] User data tersimpan di Firestore → users collection
- [ ] Login dengan username + password berhasil
- [ ] Auto-login bekerja (close app, buka lagi → langsung masuk)
- [ ] Logout berhasil (kembali ke login page)
- [ ] Sync to Firestore berhasil (data muncul di Firestore)
- [ ] Firestore rules sudah di-update ke production

---

## 💡 Tips & Best Practices

### ✅ DO:

1. **Selalu gunakan email valid** untuk register
2. **Password minimal 6 karakter** (Firebase requirement)
3. **Test di device asli** (bukan emulator) untuk hasil terbaik
4. **Update Firestore rules** ke production sebelum deploy
5. **Backup data** sebelum test sync

### ❌ DON'T:

1. **Jangan gunakan email palsu** (contoh: `test@test`)
2. **Jangan share password** user ke public
3. **Jangan skip update Firestore rules** (security risk!)
4. **Jangan lupa logout** setelah test

---

## 🚀 Next Steps

### Feature yang Bisa Ditambahkan:

1. **Email Verification**
   - User harus verify email sebelum bisa login
   - Kirim link verifikasi ke email

2. **Forgot Password**
   - User bisa reset password via email
   - Firebase kirim link reset password

3. **Social Login**
   - Login dengan Google
   - Login dengan Facebook

4. **Profile Picture**
   - Upload foto profil ke Firebase Storage
   - Tampilkan foto di aplikasi

5. **2FA (Two-Factor Authentication)**
   - Keamanan tambahan dengan SMS verification

---

## 📞 Troubleshooting

### Masalah: Aplikasi crash saat register

**Solusi:**
1. Cek log error di console
2. Pastikan Firebase sudah di-init dengan benar
3. Pastikan internet aktif

### Masalah: Data tidak sync ke Firestore

**Solusi:**
1. Cek Firestore rules (harus allow read/write)
2. Cek internet connection
3. Cek Firebase Console → Usage untuk quota

### Masalah: User tidak bisa login setelah register

**Solusi:**
1. Cek apakah email sudah di-verify (jika pakai email verification)
2. Cek password minimal 6 karakter
3. Cek Firebase Console → Authentication → Users (user ada?)

---

## 📚 Resources

- **Firebase Auth Docs**: https://firebase.google.com/docs/auth
- **Firestore Rules**: https://firebase.google.com/docs/firestore/security/get-started
- **Flutter Fire**: https://firebase.flutter.dev/docs/auth/overview/

---

## ✨ Selamat!

Anda sudah berhasil mengintegrasikan Firebase Authentication ke aplikasi EcoLoop Mart! 🎉

**Status Aplikasi Sekarang:**
- ✅ Firebase Authentication (Email/Password) aktif
- ✅ Offline-first (SQLite + Firestore)
- ✅ Real-time sync
- ✅ Production-ready security rules
- ✅ Auto-login & persistent session

**Aplikasi siap untuk testing dan deployment!** 🚀

---

**Last Updated:** 2026-01-08
