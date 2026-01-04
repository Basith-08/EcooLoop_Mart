# Panduan untuk Tim EcoLoop Mart

Selamat datang di tim EcoLoop Mart! Dokumen ini berisi semua yang perlu kamu tahu untuk mulai berkontribusi.

## 📋 Quick Info

- **Project**: EcoLoop Mart - Aplikasi Tukar Sampah
- **Tech**: Flutter + SQLite + Firebase Firestore
- **Architecture**: MVVM
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

## 🚀 Setup Pertama Kali (PENTING!)

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/EcoLoop_Mart.git
cd EcoLoop_Mart
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. **CRITICAL: Setup Firebase** 🔥

**⚠️ File `google-services.json` TIDAK ada di repository (untuk keamanan)**

Kamu harus download sendiri:

#### Cara Mendapatkan `google-services.json`:

**Opsi A: Minta ke Basith (Project Lead)**
1. Hubungi Basith via WhatsApp/Telegram
2. Minta file `google-services.json`
3. Simpan di `android/app/google-services.json`

**Opsi B: Akses Firebase Console Langsung**
1. Minta Basith untuk menambahkan email kamu sebagai member di Firebase Console
2. Login ke [Firebase Console](https://console.firebase.google.com/)
3. Pilih project **ecoloop-mart**
4. Go to Project Settings → Your apps → Android app
5. Download `google-services.json`
6. Simpan di `android/app/google-services.json`

**Path yang benar:**
```
EcoLoop_Mart/
  android/
    app/
      google-services.json  ← TARUH DI SINI
```

### 4. Verify Setup

```bash
# Cek apakah file sudah ada
ls android/app/google-services.json

# Expected output: android/app/google-services.json
# Jika "No such file", berarti belum setup!
```

### 5. Run the App

```bash
flutter run
```

**Default Login:**
- Username: `admin`
- Password: `admin123`

## 🔒 ATURAN KEAMANAN (WAJIB DIBACA!)

### ❌ JANGAN PERNAH:

1. **Commit `google-services.json` ke Git**
   ```bash
   # File ini sudah di .gitignore
   # JANGAN hapus dari .gitignore!
   ```

2. **Share `google-services.json` di group chat publik**
   - Kirim via private message atau secure file sharing

3. **Push API keys atau passwords ke GitHub**

4. **Force push ke main/master branch**
   ```bash
   # JANGAN: git push --force origin main
   ```

### ✅ SELALU:

1. **Check git status sebelum commit**
   ```bash
   git status
   # Pastikan google-services.json TIDAK muncul
   ```

2. **Pull sebelum mulai coding**
   ```bash
   git pull origin main
   ```

3. **Commit dengan message yang jelas**
   ```bash
   # BAD: git commit -m "update"
   # GOOD: git commit -m "feat: add user profile edit feature"
   ```

## 👥 Workflow Tim

### Git Workflow (Feature Branch)

```bash
# 1. Update main branch
git checkout main
git pull origin main

# 2. Buat branch baru untuk feature
git checkout -b feature/nama-fitur
# Contoh: git checkout -b feature/wallet-history

# 3. Coding di branch tersebut
# ... edit files ...

# 4. Commit changes
git add .
git commit -m "feat: add wallet transaction history"

# 5. Push ke GitHub
git push origin feature/nama-fitur

# 6. Create Pull Request di GitHub
# 7. Wait for review dari Basith atau tim
# 8. Merge setelah approved
```

### Naming Convention

**Branch Names:**
- `feature/nama-fitur` - Untuk fitur baru
- `fix/nama-bug` - Untuk bug fixes
- `docs/update-readme` - Untuk dokumentasi
- `refactor/clean-code` - Untuk refactoring

**Commit Messages:**
- `feat: add new feature` - Fitur baru
- `fix: resolve bug in wallet` - Bug fix
- `docs: update README` - Dokumentasi
- `refactor: clean up user repository` - Refactoring
- `style: format code` - Formatting

## 📂 Struktur Project

```
lib/
├── core/
│   ├── database/          # SQLite database
│   └── services/          # Firebase sync service
├── data/
│   ├── models/            # Data models (User, Product, dll)
│   └── repositories/      # Database operations
├── viewmodel/             # Business logic
└── view/                  # UI
    ├── admin/             # Halaman admin
    ├── warga/             # Halaman warga
    ├── auth/              # Login/Register
    └── widgets/           # Reusable widgets
```

## 🔧 Fitur yang Sudah Ada

- ✅ Login/Register
- ✅ Admin Dashboard
- ✅ Input Setoran Sampah
- ✅ Warehouse Management
- ✅ User Management
- ✅ Warga Mart (Shopping)
- ✅ Wallet & QR Code
- ✅ Transaction History
- ✅ **Firebase Firestore Sync** (NEW!)

## 🚧 Fitur yang Bisa Dikembangkan

### High Priority
- [ ] Password hashing (security!)
- [ ] Email verification
- [ ] Forgot password
- [ ] Product image upload
- [ ] QR code scanner

### Medium Priority
- [ ] Export transaction to PDF/CSV
- [ ] Analytics dashboard
- [ ] Leaderboard
- [ ] Search functionality
- [ ] Product categories & filters

### Low Priority
- [ ] Dark mode
- [ ] Multi-language (ID/EN)
- [ ] Push notifications
- [ ] Social sharing

**Mau ambil fitur?** Diskusikan dengan tim dulu!

## 🗣️ Komunikasi Tim

### Sebelum Mulai Coding

1. **Pilih fitur** dari list di atas atau usulkan fitur baru
2. **Diskusi dengan tim** di group
3. **Buat GitHub Issue** untuk track progress
4. **Assign ke diri sendiri** di GitHub

### Saat Coding

- Update progress di group jika stuck
- Ask for help jika ada masalah
- Commit dan push regularly (jangan tunggu selesai semua)

### Setelah Selesai

- Create Pull Request
- Tag Basith atau reviewer lain
- Respond to feedback
- Merge setelah approved

## 🐛 Troubleshooting

### "google-services.json not found"

```bash
# Solusi: Download dari Firebase atau minta ke Basith
# Taruh di: android/app/google-services.json
```

### "Firebase not initialized"

```bash
# Clean dan rebuild
flutter clean
flutter pub get
flutter run
```

### "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### "Database error"

```bash
# Hapus database dan restart app
# Database akan auto-recreate dengan schema terbaru
```

### "Merge conflict"

```bash
# 1. Pull latest changes
git pull origin main

# 2. Resolve conflicts di editor
# VS Code akan show conflict markers

# 3. Add dan commit
git add .
git commit -m "resolve merge conflicts"
```

## 📱 Testing

### Manual Testing

1. **Login sebagai Admin**
   - Username: admin / Password: admin123
   - Test semua fitur admin

2. **Register user baru** (Warga)
   - Test registration flow
   - Test login sebagai warga

3. **Test CRUD operations**
   - Create: Add product, add user
   - Read: View lists
   - Update: Edit product/user
   - Delete: Delete product/user

4. **Test Transactions**
   - Admin input setoran sampah
   - Check wallet increase
   - Warga buy product
   - Check wallet decrease

### Firebase Sync Testing

```dart
// Test sync functionality
final syncVM = context.read<SyncViewModel>();
await syncVM.syncBidirectional();

// Check di Firebase Console apakah data ter-sync
```

## 🔗 Resources & Links

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Docs](https://firebase.google.com/docs)
- [Provider Docs](https://pub.dev/packages/provider)

### Project Docs
- [README.md](README.md) - Main documentation
- [SECURITY.md](SECURITY.md) - Security guidelines
- [HYBRID_SYNC_GUIDE.md](HYBRID_SYNC_GUIDE.md) - Firebase sync guide
- [FIRESTORE_USAGE_GUIDE.md](FIRESTORE_USAGE_GUIDE.md) - Firestore basics

### Tools
- [Firebase Console](https://console.firebase.google.com/) - Project: ecoloop-mart
- [GitHub Repository](https://github.com/YOUR_USERNAME/EcoLoop_Mart)

## 👨‍💻 Roles & Responsibilities

### Basith (Project Lead)
- Project architecture
- Firebase admin
- Code review
- Final decisions

### Team Members
- Feature development
- Bug fixes
- Testing
- Documentation

## ✅ Checklist untuk Contributor Baru

Pastikan sudah:

- [ ] Clone repository
- [ ] Setup Flutter environment
- [ ] Download & install `google-services.json`
- [ ] Run `flutter pub get`
- [ ] Successfully run app
- [ ] Login dengan admin account
- [ ] Read SECURITY.md
- [ ] Understand git workflow
- [ ] Join team communication (WhatsApp/Telegram/Discord)
- [ ] Added to Firebase project (optional)

## 💡 Tips untuk Coding

1. **Follow existing patterns**
   - Lihat code yang sudah ada sebagai contoh
   - Ikuti struktur MVVM

2. **Don't repeat yourself (DRY)**
   - Buat widget/function reusable
   - Avoid copy-paste code

3. **Comment your code**
   ```dart
   // BAD: No comments for complex logic

   // GOOD: Explain why, not what
   /// Calculates eco points based on waste type and weight
   /// Returns points in double format (1 point = Rp 150)
   double calculatePoints(String wasteType, double weight) {
     // ...
   }
   ```

4. **Test before commit**
   - Run app dan test fitur yang kamu buat
   - Check di different screen sizes (web, mobile)

5. **Keep commits small**
   - 1 commit = 1 logical change
   - Easier to review dan rollback jika perlu

## 🎓 Learning Resources

Jika belum familiar dengan:

### Flutter
- [Flutter Codelabs](https://docs.flutter.dev/codelabs)
- [Flutter Widget of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)

### MVVM Pattern
- [MVVM in Flutter](https://medium.com/@business_24980/mvvm-architecture-in-flutter-a-comprehensive-guide-with-example-7c5c3c8e7e8a)

### Provider
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)

### Firebase
- [FlutterFire Docs](https://firebase.flutter.dev/)
- [Firestore Basics](https://firebase.google.com/docs/firestore/quickstart)

### Git
- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)

## 📞 Need Help?

### Stuck di coding?
1. Check documentation dulu
2. Google error message
3. Ask di group chat
4. Create GitHub issue

### Firebase access issues?
- Contact Basith untuk add email kamu ke Firebase project

### Git issues?
- Ask di group sebelum force push!
- Better ask than break the repo

## 🎯 Goals

**Short term:**
- Selesaikan password hashing
- Implement QR scanner
- Add image upload untuk products

**Long term:**
- Deploy ke production
- 100+ users
- Expand features

---

## ✨ Final Words

**Remember:**
- 🔒 Security first - JANGAN commit sensitive files
- 💬 Communication is key - Ask jika ragu
- 🤝 Help each other - We're a team!
- 🎉 Have fun coding!

**Welcome to the team! Happy coding! 🚀**

---

**Last Updated**: 2026-01-04
**Maintained by**: Basith & Team
