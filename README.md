# EcoLoop Mart - Ekosistem Tukar Sampah Jadi Sembako

![EcoLoop Mart Logo](image/login_screen/langkah-langkah.png)

Aplikasi Flutter dengan arsitektur MVVM untuk sistem tukar sampah menjadi poin yang dapat ditukar dengan sembako. Mendukung dua role: **Admin** dan **Warga**.

## 🌍 Multi-Platform Support

✅ **Android** | ✅ **iOS** | ✅ **Web** | ✅ **Windows** | ✅ **macOS** | ✅ **Linux**

EcoLoop Mart sekarang mendukung **SEMUA platform Flutter**! Lihat [MULTIPLATFORM.md](MULTIPLATFORM.md) untuk panduan lengkap build dan deployment di berbagai platform.

---

## 🐳 Development dengan Docker

Gunakan Docker untuk menjalankan lingkungan pengembangan tanpa harus memasang Flutter secara lokal.

- Prasyarat: Docker Desktop/Engine dan Docker Compose terpasang.
- Jalankan `./scripts/dev_docker.sh` untuk build image dan menjalankan `flutter run -d web-server` pada `http://localhost:8080`.
- Atau gunakan manual: `docker compose -f docker/docker-compose.yml up --build`.
- Eksekusi perintah di dalam kontainer (mis. tes): `docker compose -f docker/docker-compose.yml exec flutter_app flutter test`.
- Hot reload bekerja di dalam kontainer; edit kode di host dan gunakan shortcut Flutter di terminal yang menjalankan kontainer.
- Build Android APK tanpa install Flutter lokal: `./scripts/docker_build_apk.sh` (hasil: `build/app/outputs/flutter-apk/app-release.apk`).
- Kontainer ini ditujukan untuk build; emulator/USB passthrough tidak dikonfigurasi. Untuk menjalankan di device, gunakan Flutter lokal atau sesuaikan Compose agar `adb` dapat melihat device host.
- Jika saat `flutter run` muncul peringatan "SDK XML version ...", perbarui Android Command-line Tools ke versi terbaru (bisa lewat SDK Manager Android Studio atau rebuild Docker image yang sudah memakai tools terbaru).

## 📱 Fitur Utama

### 🔐 Autentikasi
- Login untuk Admin dan Warga
- Registrasi akun baru (Warga)
- Manajemen session dengan AuthViewModel
- Default admin account: `username: admin`, `password: admin123`

### 👨‍💼 Fitur Admin
#### Dashboard
- Statistik: Total Warga dan Barang Mart
- **Input Setoran Sampah**
  - Pilih warga dari dropdown
  - Pilih jenis sampah: Kardus Bekas (Rp 20/kg), Botol Plastik (Rp 35/kg), Kaleng Aluminium (Rp 50/kg), Minyak Jelantah (Rp 40/liter)
  - Input berat/jumlah
  - Kalkulasi otomatis estimasi poin
  - Proses setoran langsung update wallet user

#### Gudang/Warehouse
- Manajemen stok barang mart
- Tambah, Edit, Hapus produk
- Tracking stok dan poin tiap produk
- Kategori icon untuk produk

#### Manajemen Akun
- Tambah akun Warga atau Admin baru
- Edit data user
- Hapus user (dengan proteksi admin terakhir)
- Lihat daftar semua akun

### 👥 Fitur Warga/User
#### Mart (Toko)
- Browse produk yang tersedia
- Grid view dengan icon kategori
- Tambah produk ke keranjang
- Badge "PAKET LITE" untuk bundle
- Checkout dengan validasi saldo
- Update stok otomatis setelah pembelian

#### Dompet/Wallet
- Tampilan saldo EcoPoin
- Konversi ke Rupiah (1 poin = Rp 150)
- QR Code ID Member
- Info tentang EcoPoin
- Tips hemat

#### Riwayat Transaksi
- List semua transaksi (Setor Sampah & Tukar Barang)
- Color-coded: Hijau untuk deposit (+), Merah untuk pembelian (-)
- Detail jenis sampah atau produk
- Tanggal transaksi

#### Profil
- Info akun lengkap
- Tanggal bergabung
- Sisa saldo
- Status akun (ACTIVE/INACTIVE)
- Logout

#### QR Code
- Generate QR code dengan user ID
- Untuk scan di petugas loket
- Tampilkan info user dan saldo

---

## 🏗️ Arsitektur MVVM

```
lib/
├── core/
│   └── database/
│       ├── db_helper.dart           # SQLite helper
│       └── db_config.dart           # Database configuration
│
├── data/
│   ├── models/
│   │   ├── user_model.dart          # User entity
│   │   ├── product_model.dart       # Product entity
│   │   ├── transaction_model.dart   # Transaction entity
│   │   ├── wallet_model.dart        # Wallet entity
│   │   └── cart_item_model.dart     # Cart item entity
│   │
│   └── repositories/
│       ├── user_repository.dart      # User CRUD + Auth
│       ├── product_repository.dart   # Product CRUD
│       ├── transaction_repository.dart  # Transaction CRUD
│       └── wallet_repository.dart    # Wallet CRUD
│
├── state/
│   ├── auth_state.dart              # Authentication states
│   ├── user_state.dart              # User states
│   ├── product_state.dart           # Product states
│   ├── transaction_state.dart       # Transaction states
│   ├── wallet_state.dart            # Wallet states
│   └── cart_state.dart              # Cart states
│
├── viewmodel/
│   ├── auth_viewmodel.dart          # Auth business logic
│   ├── user_viewmodel.dart          # User business logic
│   ├── product_viewmodel.dart       # Product business logic
│   ├── transaction_viewmodel.dart   # Transaction business logic
│   ├── wallet_viewmodel.dart        # Wallet business logic
│   └── cart_viewmodel.dart          # Cart business logic
│
├── view/
│   ├── auth/
│   │   ├── login_page.dart          # Login UI
│   │   └── register_page.dart       # Register UI
│   │
│   ├── admin/
│   │   ├── admin_home_page.dart     # Admin navigation
│   │   ├── admin_dashboard_page.dart   # Dashboard + Input Setoran
│   │   ├── admin_warehouse_page.dart   # Product management
│   │   └── admin_account_page.dart     # User management
│   │
│   ├── warga/
│   │   ├── warga_home_page.dart     # User navigation
│   │   ├── mart_page.dart           # Shop + Cart
│   │   ├── wallet_page.dart         # Wallet + QR
│   │   ├── transaction_history_page.dart  # Transaction list
│   │   └── profile_page.dart        # User profile
│   │
│   └── widgets/
│       └── qr_code_dialog.dart      # QR code widget
│
└── main.dart                        # App entry point
```

---

## 💾 Database Schema

### Table: `users`
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'warga',        -- 'admin' or 'warga'
  email TEXT,
  phone TEXT,
  eco_points REAL NOT NULL DEFAULT 0.0,
  status TEXT NOT NULL DEFAULT 'active',      -- 'active' or 'inactive'
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

### Table: `products`
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,                        -- in EcoPoin
  stock INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  category TEXT,                              -- for icon selection
  is_eco_friendly INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

### Table: `transactions`
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  product_id INTEGER,                         -- NULL for deposit
  quantity INTEGER NOT NULL,
  total_price REAL NOT NULL,                  -- points
  transaction_date TEXT NOT NULL,
  status TEXT NOT NULL,                       -- 'completed', 'pending', 'cancelled'
  type TEXT NOT NULL,                         -- 'deposit' or 'purchase'
  waste_type TEXT,                            -- for deposit: 'Kardus Bekas', etc.
  product_name TEXT,                          -- for purchase
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (product_id) REFERENCES products (id)
)
```

### Table: `wallets`
```sql
CREATE TABLE wallets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE,
  eco_points REAL NOT NULL DEFAULT 0.0,
  rupiah_value REAL NOT NULL DEFAULT 0.0,     -- calculated: points × 150
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
```

---

## 🎨 Design System

### Color Palette
- **Primary Green**: `#2D9F5D` - Brand color, Warga theme
- **Orange**: `#FF8C42` - Admin theme, accents
- **Blue**: `#4169E1` - Info, statistics
- **Light Green**: `#F0F7F4` - Background
- **Success Green**: `#E8F5E9` - Success states
- **Error Red**: `#F44336` - Errors, negative values

### Typography
- **Material 3** default typography
- **Bold weights** for headers and buttons

### Components
- **Cards**: Rounded 12px, elevation 2
- **Buttons**: Rounded 8px, padding 16px vertical
- **Inputs**: Rounded 8px, filled white background
- **Bottom Navigation**: Fixed type, 5 items max

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.1

  # Database
  sqflite: ^2.3.0
  path: ^1.8.3

  # QR Code
  qr_flutter: ^4.1.0

  # Date Formatting
  intl: ^0.18.1

  # UI Components
  cupertino_icons: ^1.0.6
```

---

## 🚀 Installation & Setup

### Prasyarat
- Flutter SDK >= 3.0.0
- Dart SDK
- Android Studio / VS Code
- Android Emulator atau Physical Device

### Langkah Instalasi

1. **Clone atau navigasi ke project**
   ```bash
   cd "/home/asfine/Basith/Semeseter 5/pemrograman_android/EcoLoop_Mart"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**

   **Mobile:**
   ```bash
   # Android
   flutter run -d android

   # iOS (macOS only)
   flutter run -d ios
   ```

   **Web:**
   ```bash
   flutter run -d chrome
   # atau
   ./scripts/run_web.sh
   ```

   **Desktop:**
   ```bash
   # Windows
   flutter run -d windows

   # macOS
   flutter run -d macos

   # Linux
   flutter run -d linux
   ```

   **Auto-detect (default):**
   ```bash
   flutter run
   ```

### First Time Setup

Saat aplikasi pertama kali dijalankan:
1. Database akan otomatis dibuat
2. Admin default akan dibuat:
   - **Username**: `admin`
   - **Password**: `admin123`
   - **Role**: admin
3. Gunakan akun admin untuk:
   - Menambah produk ke warehouse
   - Membuat akun warga
   - Input setoran sampah

---

## 📱 User Flow

### Flow Warga
1. **Register** → Buat akun dengan nama lengkap, username, password
2. **Login** → Tab WARGA, masukkan username & password
3. **Kumpulkan Sampah** → Bawa ke petugas loket
4. **Scan QR** → Petugas scan QR code user
5. **Admin Input Setoran** → Admin input jenis & berat sampah
6. **Poin Masuk** → Wallet user otomatis bertambah
7. **Belanja di Mart** → Pilih produk, tambah ke cart, checkout
8. **Poin Berkurang** → Wallet terpotong sesuai harga

### Flow Admin
1. **Login** → Tab ADMIN, username: admin, password: admin123
2. **Dashboard** → Lihat statistik, input setoran warga
3. **Gudang** → Kelola stok produk (tambah/edit/hapus)
4. **Akun** → Kelola user (tambah/edit/hapus warga & admin)

---

## 🔄 Business Logic

### Sistem Poin
- **1 EcoPoin = Rp 150**
- **Jenis Sampah & Harga:**
  - Kardus Bekas: **Rp 20/kg** → 0.13 poin/kg
  - Botol Plastik: **Rp 35/kg** → 0.23 poin/kg
  - Kaleng Aluminium: **Rp 50/kg** → 0.33 poin/kg
  - Minyak Jelantah: **Rp 40/liter** → 0.27 poin/liter

### Transaksi Setoran (Deposit)
```dart
// Admin inputs:
- User (warga)
- Waste type (jenis sampah)
- Weight (berat dalam kg)

// System calculates:
points = (waste_price × weight) / 150

// System updates:
1. Create transaction (type: 'deposit')
2. Add points to user's wallet
3. Update user's eco_points
```

### Transaksi Pembelian (Purchase)
```dart
// User selects:
- Products → Add to cart
- Checkout

// System validates:
if (user_points >= total_cart_price) {
  // Process purchase
  1. Deduct points from wallet
  2. Decrease product stock
  3. Create transaction (type: 'purchase')
  4. Clear cart
} else {
  // Show error: insufficient balance
}
```

---

## 🧪 Testing

### Manual Testing Checklist

#### Authentication
- [ ] Login as admin
- [ ] Login as warga
- [ ] Register new warga account
- [ ] Logout

#### Admin Features
- [ ] Input setoran sampah
- [ ] Add new product
- [ ] Edit product
- [ ] Delete product
- [ ] Add new user (warga)
- [ ] Add new admin
- [ ] Edit user
- [ ] Delete user
- [ ] View statistics

#### Warga Features
- [ ] View wallet balance
- [ ] View QR code
- [ ] Browse products in Mart
- [ ] Add product to cart
- [ ] Remove from cart
- [ ] Checkout with sufficient balance
- [ ] Checkout with insufficient balance (should fail)
- [ ] View transaction history
- [ ] View profile

---

## 🛡️ Security Considerations

### Implemented
- Username uniqueness validation
- Password storage (currently plain text - **see below**)
- Role-based access control
- Account status checking (active/inactive)
- Balance validation before purchase
- Stock validation before adding to cart
- Protection against deleting last admin

### Recommendations for Production
```dart
// TODO: Implement password hashing
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

// In user_repository.dart:
// Replace plain password storage with:
'password': hashPassword(password)

// Replace login query with:
'password': hashPassword(password)
```

---

## 🐛 Known Issues & Limitations

1. **Password Security**: Passwords stored in plain text (implement hashing before production)
2. **No Image Upload**: Product images use icon categories only
3. **No Network**: Fully offline SQLite-based
4. **No Sync**: No cloud backup or multi-device sync
5. **QR Scanner**: QR code dialog shows code but no scanner implementation
6. **No Email Verification**: Email field exists but not validated
7. **No Forgot Password**: Must reset through admin

---

## 🔮 Future Enhancements

### High Priority
- [ ] Password hashing (bcrypt/SHA256)
- [ ] Email validation & verification
- [ ] Forgot password functionality
- [ ] Image picker for product photos
- [ ] QR code scanner implementation
- [ ] Push notifications for successful deposits

### Medium Priority
- [ ] Export transaction history to PDF/CSV
- [ ] Data analytics dashboard for admin
- [ ] Monthly reports
- [ ] Leaderboard (top contributors)
- [ ] Reward system/badges
- [ ] Product categories & filters
- [ ] Search functionality in Mart

### Low Priority
- [ ] Dark mode
- [ ] Multi-language support (Bahasa & English)
- [ ] Cloud sync (Firebase)
- [ ] Social sharing features
- [ ] Tutorial/onboarding flow

---

## 📄 License

Project ini dibuat untuk keperluan pembelajaran **Pemrograman Android - Semester 5**.

---

## 👥 Credits

**Developer**: Basith
**Project**: EcoLoop Mart - Sustainable Shopping App
**Institution**: Semester 5 - Pemrograman Android

### Technologies Used
- **Flutter** - UI Framework
- **Provider** - State Management
- **SQLite** - Local Database
- **QR Flutter** - QR Code Generation
- **Intl** - Date Formatting

---

## 📞 Support & Contact

Jika ada pertanyaan atau issues:
1. Check dokumentasi ini terlebih dahulu
2. Review kode di folder yang relevan
3. Test di emulator atau device
4. Check database dengan SQLite viewer

---

## 🎯 Quick Start Guide

### Untuk Dosen/Reviewer

1. **Install & Run**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Login as Admin**
   - Tab: ADMIN
   - Username: `admin`
   - Password: `admin123`

3. **Setup Initial Data**
   - Go to **Gudang** → Add products
   - Go to **Akun** → Add warga users

4. **Test User Flow**
   - Logout
   - Login as warga OR register new account
   - View wallet (should be 0 poin)

5. **Test Deposit Flow**
   - Login as admin
   - Go to **Dashboard**
   - Select warga from dropdown
   - Select waste type (e.g., Kardus Bekas)
   - Input weight (e.g., 10 kg)
   - Click **Proses Setoran**
   - Check warga's wallet (should increase)

6. **Test Purchase Flow**
   - Login as warga
   - Go to **Mart**
   - Add products to cart
   - Click **Checkout**
   - Confirm purchase
   - Check wallet (should decrease)
   - Check **Riwayat** (should show transaction)

---

**Happy Coding & Green Living!** ♻️🌱
