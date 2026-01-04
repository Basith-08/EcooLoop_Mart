# Pre-Push Checklist untuk GitHub Public Repository

Checklist ini harus diselesaikan sebelum push ke GitHub public repository.

## ✅ Yang Sudah Dilakukan

- [x] Firebase Firestore integration (hybrid SQLite + Firestore)
- [x] Update `.gitignore` untuk exclude `google-services.json`
- [x] Update README.md dengan Firebase documentation
- [x] Create SECURITY.md dengan security warnings
- [x] Create FIRESTORE_USAGE_GUIDE.md
- [x] Create HYBRID_SYNC_GUIDE.md

## 🔒 Security Checklist (CRITICAL)

### 1. File Sensitif

**⚠️ PASTIKAN file ini TIDAK di-commit:**

```bash
# Check apakah file sensitif ada di staging
git status

# Yang TIDAK boleh muncul di git status:
# ❌ android/app/google-services.json
# ❌ .env atau .env.local
# ❌ ios/Runner/GoogleService-Info.plist
```

**Jika file tersebut sudah di-commit sebelumnya:**

```bash
# Remove dari git history (BAHAYA: rewrite history)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch android/app/google-services.json" \
  --prune-empty --tag-name-filter cat -- --all

# Atau gunakan BFG Repo-Cleaner (recommended):
# https://rtyley.github.io/bfg-repo-cleaner/
```

### 2. Firebase Security Rules

- [ ] Login ke [Firebase Console](https://console.firebase.google.com/)
- [ ] Go to Firestore Database → Rules
- [ ] **Pastikan masih TEST MODE jika untuk development**
- [ ] **JANGAN lupa update ke Production Rules sebelum deploy produksi**

### 3. Kode Review

- [ ] Tidak ada password hardcoded di code
- [ ] Tidak ada API keys selain Firebase client keys
- [ ] Tidak ada print() statements yang menampilkan data sensitif
- [ ] Comment out atau hapus debug logs

## 📦 File yang Aman untuk Di-Push

File-file ini **aman** untuk di-push ke public repo:

- [x] `lib/firebase_options.dart` - Client API keys (aman, tapi harus setup Security Rules)
- [x] `pubspec.yaml` - Dependencies
- [x] `README.md` - Documentation
- [x] `SECURITY.md` - Security guidelines
- [x] `*.md` files - Documentation
- [x] Source code di `lib/`
- [x] Assets di `assets/`
- [x] `android/app/build.gradle` - Build configuration
- [x] `.gitignore` - Git ignore rules

## ⚠️ File yang TIDAK Boleh Di-Push

- [ ] ❌ `android/app/google-services.json`
- [ ] ❌ `ios/Runner/GoogleService-Info.plist`
- [ ] ❌ `.env` atau `.env.local`
- [ ] ❌ Any private keys atau certificates
- [ ] ❌ `firebase-debug.log`
- [ ] ❌ `.firebase/` directory

## 🧹 Clean Up Code

### Fix Minor Warnings (Optional tapi disarankan)

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Warnings yang bisa diabaikan untuk sekarang:

- `prefer_const_constructors` - Performance optimization (minor)
- `use_build_context_synchronously` - Sudah ada mounted check
- `avoid_print` - Untuk development OK, hapus saat production
- `unnecessary_import` - Bisa di-fix nanti

## 📝 Documentation Review

- [ ] README.md up to date dengan features terbaru
- [ ] Setup instructions jelas
- [ ] Firebase setup instructions lengkap
- [ ] SECURITY.md warning jelas
- [ ] Contributors tahu bahwa `google-services.json` tidak ada di repo

## 🚀 Pre-Push Commands

```bash
# 1. Pastikan di branch yang benar
git branch

# 2. Check status - PASTIKAN google-services.json TIDAK muncul
git status

# 3. Check apa yang akan di-commit
git diff --cached

# 4. Add semua file (kecuali yang di .gitignore)
git add .

# 5. Review sekali lagi
git status

# 6. Commit dengan message yang jelas
git commit -m "feat: add Firebase Firestore hybrid sync system

- Add Firebase Firestore integration
- Implement hybrid SQLite + Firestore sync
- Add sync service and ViewModels
- Update documentation with Firebase setup
- Add SECURITY.md with critical warnings

⚠️ Note: Developers need to download google-services.json from Firebase Console"

# 7. Push ke GitHub
git push origin feat/firebase
# atau
git push origin main  # jika sudah di main branch
```

## 🔍 Final Verification

Setelah push, check di GitHub:

1. **Go to repository di GitHub**
2. **Verify files:**
   - [ ] `android/app/google-services.json` - TIDAK ADA di repo ✅
   - [ ] `lib/firebase_options.dart` - ADA (ini OK) ✅
   - [ ] `README.md` - Ada dan up-to-date ✅
   - [ ] `SECURITY.md` - Ada dengan warnings ✅
   - [ ] `.gitignore` - Ada dan mencakup sensitive files ✅

3. **Check README rendering:**
   - [ ] Firebase setup instructions clear
   - [ ] Links to guides work
   - [ ] Images/badges display correctly

## 📋 Post-Push TODO

Setelah berhasil push ke GitHub:

1. **Create README di GitHub** tentang setup untuk contributor:
   ```markdown
   ## Setup untuk Developer Lain

   1. Clone repository
   2. Download `google-services.json` dari Firebase Console
   3. Place di `android/app/google-services.json`
   4. Run `flutter pub get`
   5. Run `flutter run`
   ```

2. **Add .github/PULL_REQUEST_TEMPLATE.md** (optional):
   ```markdown
   ## Checklist
   - [ ] Tidak ada sensitive files yang di-commit
   - [ ] Code sudah di-test
   - [ ] Documentation updated
   ```

3. **Consider adding GitHub Actions** untuk:
   - Auto-check apakah ada sensitive files
   - Run flutter analyze
   - Run tests

## ❗ Jika Ada Masalah

### "google-services.json sudah ter-commit!"

```bash
# Remove dari staging (belum di-commit)
git reset android/app/google-services.json

# Remove dari commit terakhir (sudah di-commit tapi belum push)
git reset --soft HEAD~1
git reset android/app/google-services.json
git commit -m "your message"

# Sudah ter-push ke GitHub (NUCLEAR OPTION - hati-hati!)
# Hubungi team dulu sebelum force push
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch android/app/google-services.json" \
  --prune-empty --tag-name-filter cat -- --all
git push origin --force --all
```

### "Security Rules tidak configured"

1. Login ke Firebase Console
2. Firestore Database → Rules
3. Update rules sesuai SECURITY.md

### "Contributor tidak bisa run app"

Tambahkan di README:
```markdown
## Troubleshooting

**Error: google-services.json not found**
- Download dari Firebase Console
- Place di android/app/google-services.json
- Contact maintainer untuk Firebase project access
```

## ✅ Final Check Before Push

**Run this command dan verify output:**

```bash
# Check git status
git status | grep google-services.json

# Expected output: NOTHING (file should be ignored)
# If you see google-services.json, DO NOT PUSH!
```

**If all checks pass:**

```bash
# You are safe to push! 🎉
git push
```

---

## 📞 Need Help?

Jika ragu, **JANGAN push dulu!** Better safe than sorry.

Checklist ini dibuat untuk melindungi:
- ✅ Firebase project dari unauthorized access
- ✅ User data dari security breaches
- ✅ API quota dari abuse
- ✅ Repository dari sensitive data leaks

**Remember: Once pushed to public GitHub, it's public forever (even if deleted later!)**

---

**Last Updated**: 2026-01-04
