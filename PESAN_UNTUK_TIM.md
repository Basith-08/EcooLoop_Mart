# Template Pesan untuk Rekan Tim

Copy-paste pesan ini ke group chat tim kamu:

---

## 📱 Pesan untuk Group Chat

```
Halo Tim! 👋

Project EcoLoop Mart sudah ready untuk kolaborasi. Berikut info penting:

🔗 REPOSITORY
https://github.com/YOUR_USERNAME/EcoLoop_Mart

📋 SETUP (WAJIB BACA!)
Baca file TEAM_GUIDE.md untuk panduan lengkap setup.

⚠️ PENTING BANGET:
1. File google-services.json TIDAK ada di repo (security)
2. Kalian perlu download sendiri dari saya
3. JANGAN COMMIT google-services.json ke Git!

📦 QUICK SETUP:
1. git clone <repo-url>
2. flutter pub get
3. Minta google-services.json ke saya
4. Taruh di: android/app/google-services.json
5. flutter run

🔑 DEFAULT LOGIN:
Username: admin
Password: admin123

📚 BACA INI:
- TEAM_GUIDE.md → Panduan lengkap untuk tim
- SECURITY.md → Aturan keamanan
- README.md → Dokumentasi project

🤝 GIT WORKFLOW:
- Jangan push langsung ke main
- Bikin branch: feature/nama-fitur
- Push & buat Pull Request
- Wait approval sebelum merge

💬 Ada pertanyaan? Tanya di sini!

Happy coding! 🚀
```

---

## 📧 Pesan untuk Email Individual

Subject: Setup EcoLoop Mart Project

```
Hi [Nama],

Kamu sudah ditambahkan ke project EcoLoop Mart. Berikut langkah setupnya:

1. CLONE REPOSITORY
   git clone https://github.com/YOUR_USERNAME/EcoLoop_Mart.git
   cd EcoLoop_Mart
   flutter pub get

2. FIREBASE SETUP (PENTING!)
   - Aku attach file google-services.json
   - Simpan di: android/app/google-services.json
   - JANGAN commit file ini ke Git!

3. RUN APP
   flutter run
   Login: admin / admin123

4. BACA DOKUMENTASI
   - TEAM_GUIDE.md untuk panduan tim
   - SECURITY.md untuk aturan keamanan

5. GIT WORKFLOW
   - Bikin branch baru untuk setiap fitur
   - Push & buat Pull Request
   - Jangan force push ke main

Kalau ada masalah setup, kabari ya!

Thanks,
Basith
```

---

## 💬 Pesan untuk WhatsApp/Telegram

```
🚀 EcoLoop Mart - Setup Info

Repo: [link]

Setup Steps:
1. Clone repo
2. flutter pub get
3. Download google-services.json (aku kirim terpisah)
4. Taruh di android/app/google-services.json
5. flutter run

⚠️ PENTING:
- JANGAN commit google-services.json
- Baca TEAM_GUIDE.md dulu
- Pakai feature branch, jangan langsung ke main

Login default:
👤 admin
🔑 admin123

Ada yang bingung? Tanya aja!
```

---

## 🎥 Cara Share google-services.json

**JANGAN:**
- ❌ Post di group chat publik
- ❌ Commit ke Git
- ❌ Share via screenshot

**LAKUKAN:**
- ✅ Send via WhatsApp/Telegram private message
- ✅ Send via email individual
- ✅ Use secure file sharing (Google Drive private link)
- ✅ Add to Firebase Console directly (give team member access)

**Template Pesan Saat Kirim File:**

```
File google-services.json untuk EcoLoop Mart

⚠️ File ini RAHASIA, jangan:
- Share ke orang lain
- Commit ke Git
- Post di public

Simpan di: android/app/google-services.json

Kalau sudah setup, delete file dari chat untuk keamanan.
```

---

## 📋 Checklist Onboarding Tim

Untuk setiap anggota tim baru, pastikan:

**Sebelum Mulai:**
- [ ] Sudah punya akses ke GitHub repository
- [ ] Sudah dapat file google-services.json
- [ ] Sudah read TEAM_GUIDE.md
- [ ] Sudah read SECURITY.md
- [ ] Understand git workflow

**Setup Teknis:**
- [ ] Flutter environment installed
- [ ] Git configured
- [ ] Repository cloned
- [ ] google-services.json di tempat yang benar
- [ ] Dependencies installed (flutter pub get)
- [ ] App successfully running
- [ ] Bisa login dengan admin account

**Optional (Recommended):**
- [ ] Added ke Firebase Console sebagai member
- [ ] Added ke project management tool (Trello/Notion)
- [ ] Join communication channel (Discord/Slack)

---

## 🎓 First Task untuk New Member

Biar new member langsung familiar dengan codebase:

```
FIRST TASK - Easy Onboarding

Goal: Kenalan dengan codebase

Tasks:
1. ✅ Setup & run app successfully
2. 📱 Explore semua fitur:
   - Login sebagai admin
   - Input setoran sampah
   - Add product di warehouse
   - Logout & register sebagai warga
   - Browse Mart & checkout
   - Check wallet & transaction history

3. 📖 Baca code:
   - Buka lib/main.dart - lihat app structure
   - Buka lib/viewmodel/auth_viewmodel.dart - lihat business logic
   - Buka lib/view/admin/admin_dashboard_page.dart - lihat UI

4. 🐛 Fix a simple issue:
   - Pick dari GitHub Issues dengan label "good first issue"
   - Atau: tambah comment di code yang kurang jelas
   - Create branch & Pull Request

Expected time: 2-3 jam
Purpose: Familiar dengan workflow & codebase

Questions? Ask di group!
```

---

## 🗓️ Weekly Sync Meeting Template

```
📅 EcoLoop Mart - Weekly Sync

Date: [tanggal]

AGENDA:
1. Progress Update (setiap orang)
   - What did you do this week?
   - Blockers/challenges?

2. Code Review
   - Open PRs yang perlu review
   - Feedback & approval

3. Planning
   - What to work on next week?
   - Assign tasks

4. Technical Discussion
   - Architecture decisions
   - New libraries/tools
   - Improvements

5. AOB (Any Other Business)

NEXT MEETING: [tanggal & waktu]
```

---

## 🎯 Task Assignment Template

```
TASK: [Nama Fitur]

📝 Description:
[Detail fitur yang mau dibuat]

✅ Acceptance Criteria:
- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Criteria 3

🔧 Technical Notes:
- Files to modify: [list files]
- New files needed: [list]
- Dependencies: [if any]

📚 Resources:
- [Link ke reference/docs]

👤 Assigned to: [Nama]
⏰ Deadline: [Tanggal]
🏷️ Priority: High/Medium/Low

Questions? Tag @Basith
```

---

## 🚨 Emergency Contacts

Jika ada masalah urgent:

**Firebase Issues:**
- Contact: Basith (Project Owner)
- Can reset API keys, manage access, etc.

**Git Issues (force push, deleted files, etc):**
- STOP & ask in group first
- Contact: Basith or Git expert in team

**App Crash di Production:**
- Check Firebase Crashlytics
- Create GitHub Issue dengan label "critical"
- Notify in group immediately

---

## ✨ Closing Message

```
Selamat datang di tim EcoLoop Mart!

Kita bikin app yang bermanfaat untuk lingkungan 🌱

Prinsip kita:
- 🤝 Teamwork - help each other
- 💬 Communication - always ask if unsure
- 🔒 Security - protect sensitive data
- 📚 Documentation - write clear code & docs
- 🎉 Fun - enjoy the coding!

Let's build something awesome together! 💪

Questions? Ping @Basith or ask in group!

Happy coding! 🚀
```

---

**File ini berisi template yang bisa langsung di-copy-paste.**
**Customize sesuai kebutuhan tim kamu!**
