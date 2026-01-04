# Panduan Hybrid SQLite + Firestore Sync

## Konsep Hybrid System

Sistem hybrid menggunakan **SQLite sebagai database utama (offline-first)** dan **Firestore untuk cloud sync dan backup**:

- **SQLite**: Data lokal di device, berfungsi offline
- **Firestore**: Backup di cloud, sync antar device, real-time updates
- **Sync Service**: Mengelola sinkronisasi antara SQLite dan Firestore

### Keuntungan Hybrid Approach

1. **Offline-First**: App tetap berfungsi tanpa internet
2. **Fast Performance**: Data dibaca dari SQLite (lebih cepat)
3. **Cloud Backup**: Data aman tersimpan di cloud
4. **Multi-Device Sync**: Data sync antar device
5. **Real-time Updates**: Perubahan langsung terlihat di semua device

## File-file yang Sudah Dibuat

### 1. Firebase Sync Service
**File**: `lib/core/services/firebase_sync_service.dart`

Service ini menangani:
- Sync Up (upload local → cloud)
- Sync Down (download cloud → local)
- Bidirectional Sync (upload & download)
- Real-time listeners
- Connection checking

### 2. User Hybrid Repository
**File**: `lib/data/repositories/user_hybrid_repository.dart`

Repository hybrid yang:
- Semua CRUD operation ke SQLite dulu
- Auto-sync ke Firestore di background (jika ada internet)
- Support manual sync
- Real-time updates dari cloud

### 3. Sync ViewModel
**File**: `lib/viewmodel/sync_viewmodel.dart`

ViewModel untuk UI yang menyediakan:
- Sync status tracking
- Manual sync trigger
- Error handling
- Success messages

### 4. Sync UI Widgets
**File**: `lib/view/widgets/sync_button_widget.dart`

Widget-widget untuk UI:
- `SyncButtonWidget`: Menu button dengan opsi sync
- `SyncStatusBanner`: Banner untuk menampilkan sync status
- `CompactSyncButton`: Tombol sync compact untuk list

## Cara Implementasi

### Step 1: Tambahkan SyncViewModel ke Provider

Edit `lib/main.dart` dan tambahkan `SyncViewModel` ke provider list:

```dart
import 'viewmodel/sync_viewmodel.dart';

// Di dalam MultiProvider
MultiProvider(
  providers: [
    // ... providers yang sudah ada ...

    // Tambahkan SyncViewModel
    ChangeNotifierProvider<SyncViewModel>(
      create: (_) => SyncViewModel(),
    ),
  ],
  // ...
)
```

### Step 2: Gunakan UserHybridRepository

Anda punya 2 pilihan:

#### Pilihan A: Replace UserRepository dengan UserHybridRepository (Recommended)

Edit `lib/main.dart`:

```dart
// SEBELUM
import 'data/repositories/user_repository.dart';

Provider<UserRepository>(
  create: (_) => UserRepository(),
),

// SESUDAH
import 'data/repositories/user_hybrid_repository.dart';

Provider<UserHybridRepository>(
  create: (_) => UserHybridRepository(),
),
```

Lalu update semua ViewModel yang menggunakan UserRepository:

```dart
// SEBELUM
class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  AuthViewModel(this._userRepo);
}

// SESUDAH
class AuthViewModel extends ChangeNotifier {
  final UserHybridRepository _userRepo;
  AuthViewModel(this._userRepo);
}
```

#### Pilihan B: Gunakan Kedua-duanya (SQLite + Hybrid)

Tambahkan sebagai repository terpisah:

```dart
// Di providers
Provider<UserRepository>(
  create: (_) => UserRepository(),
),
Provider<UserHybridRepository>(
  create: (_) => UserHybridRepository(),
),
```

Gunakan `UserRepository` untuk operasi normal, dan `UserHybridRepository` untuk fitur yang butuh sync.

### Step 3: Tambahkan Sync Button ke UI

#### Tambahkan di AppBar

```dart
import '../widgets/sync_button_widget.dart';

AppBar(
  title: const Text('Dashboard'),
  actions: [
    // Sync button
    SyncButtonWidget(
      onSyncComplete: () {
        // Refresh data setelah sync
        setState(() {});
      },
    ),
  ],
),
```

#### Tambahkan Sync Status Banner

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('My Page'),
    ),
    body: Column(
      children: [
        // Sync status banner
        const SyncStatusBanner(),

        // Content
        Expanded(
          child: YourContentWidget(),
        ),
      ],
    ),
  );
}
```

### Step 4: Manual Sync dari Code

```dart
import 'package:provider/provider.dart';
import '../viewmodel/sync_viewmodel.dart';

// Di dalam widget/function
final syncVM = context.read<SyncViewModel>();

// Upload ke cloud
await syncVM.syncToCloud();

// Download dari cloud
await syncVM.syncFromCloud();

// Bidirectional sync (recommended)
await syncVM.syncBidirectional();

// Check hasil
if (syncVM.hasError) {
  print('Error: ${syncVM.errorMessage}');
} else if (syncVM.hasSuccess) {
  print('Success: ${syncVM.successMessage}');
  print('Items synced: ${syncVM.lastSyncedItems}');
}
```

### Step 5: Real-time Updates (Optional)

Jika ingin data auto-update dari cloud:

```dart
import '../data/repositories/user_hybrid_repository.dart';

final userHybridRepo = UserHybridRepository();

// Listen to real-time updates
StreamBuilder<List<UserModel>>(
  stream: userHybridRepo.watchUsersFromCloud(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    final users = snapshot.data!;
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text('Points: ${user.ecoPoints}'),
        );
      },
    );
  },
)
```

## Contoh Usage dalam AuthViewModel

```dart
class AuthViewModel extends ChangeNotifier {
  final UserHybridRepository _userRepo;

  AuthViewModel(this._userRepo);

  Future<bool> register(UserModel user) async {
    try {
      // Data akan disimpan ke SQLite dulu,
      // lalu auto-sync ke Firestore di background
      await _userRepo.register(user);
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<UserModel?> login(String username, String password) async {
    // Login dari SQLite (offline-first)
    return await _userRepo.login(username, password);
  }
}
```

## Fitur-fitur Penting

### 1. Offline-First
- Semua operasi disimpan ke SQLite dulu
- App tetap berfungsi tanpa internet
- Data sync otomatis saat ada koneksi

### 2. Auto Background Sync
```dart
// Ketika insert/update user
await userHybridRepo.insertUser(user);
// ↑ Otomatis disimpan ke SQLite
// ↓ Background sync ke Firestore (tidak blocking)
```

### 3. Manual Sync
```dart
// Sync semua data ke cloud
await userHybridRepo.syncToCloud();

// Download data dari cloud
await userHybridRepo.syncFromCloud();

// Bidirectional (recommended)
await userHybridRepo.syncBidirectional();
```

### 4. Connection Check
```dart
final hasConnection = await userHybridRepo.checkConnection();
if (hasConnection) {
  // Lakukan sync
}
```

### 5. Sync Status Monitoring
```dart
final syncVM = context.watch<SyncViewModel>();

// Status
if (syncVM.isSyncing) {
  // Show loading
}

// Last sync time
if (syncVM.lastSyncTime != null) {
  print('Last sync: ${syncVM.lastSyncTime}');
}

// Status text
print(syncVM.getSyncStatusText());
// Output: "Sync 5 menit yang lalu"
```

## Best Practices

### 1. Sync Saat Login
```dart
Future<void> login(String username, String password) async {
  final user = await _userRepo.login(username, password);

  if (user != null) {
    // Sync setelah login berhasil
    final syncVM = context.read<SyncViewModel>();
    await syncVM.syncBidirectional();
  }
}
```

### 2. Periodic Sync
```dart
// Di initState atau main screen
Timer.periodic(Duration(minutes: 15), (timer) async {
  final syncVM = context.read<SyncViewModel>();
  await syncVM.syncBidirectional();
});
```

### 3. Sync Before Important Actions
```dart
Future<void> processTransaction() async {
  // Sync dulu untuk ensure data terbaru
  await syncVM.syncBidirectional();

  // Lakukan transaction
  await transactionRepo.createTransaction(transaction);

  // Sync lagi untuk backup
  await syncVM.syncToCloud();
}
```

### 4. Error Handling
```dart
await syncVM.syncBidirectional();

if (syncVM.hasError) {
  // Log error atau tampilkan ke user
  print('Sync failed: ${syncVM.errorMessage}');

  // Retry logic
  if (syncVM.errorMessage?.contains('internet') == true) {
    // Akan auto-sync saat koneksi kembali
  }
}
```

## Membuat Hybrid Repository untuk Model Lain

Untuk membuat hybrid repository untuk Product, Transaction, dll:

```dart
class ProductHybridRepository {
  final ProductRepository _localRepo = ProductRepository();
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final String _collectionName = 'products';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Helper methods
  Map<String, dynamic> _toFirestoreMap(ProductModel product) {
    return product.toMap();
  }

  ProductModel _fromFirestoreMap(Map<String, dynamic> map) {
    return ProductModel.fromMap(map);
  }

  String _getDocumentId(ProductModel product) {
    return product.id.toString();
  }

  // CRUD with auto-sync
  Future<int> insertProduct(ProductModel product) async {
    final localId = await _localRepo.insertProduct(product);
    _trySyncToCloud(product);
    return localId;
  }

  Future<void> _trySyncToCloud(ProductModel product) async {
    try {
      final hasConnection = await _syncService.checkConnection();
      if (!hasConnection) return;

      await _firestore
          .collection(_collectionName)
          .doc(_getDocumentId(product))
          .set(_toFirestoreMap(product), SetOptions(merge: true));
    } catch (e) {
      print('Background sync failed: $e');
    }
  }

  // Manual sync methods
  Future<SyncResult> syncToCloud() async {
    final products = await _localRepo.getAllProducts();
    return await _syncService.syncUp(
      collectionName: _collectionName,
      localData: products,
      toFirestoreMap: _toFirestoreMap,
      getDocumentId: _getDocumentId,
    );
  }

  // ... dst
}
```

## Troubleshooting

### 1. Sync Tidak Jalan
- Check koneksi internet
- Pastikan Firestore sudah di-setup di Firebase Console
- Check security rules di Firestore

### 2. Data Tidak Muncul Setelah Sync
- Check mapping function (fromFirestoreMap)
- Pastikan document ID konsisten
- Check Firestore console untuk data

### 3. Conflict Resolution
- Sistem menggunakan last-write-wins
- Data terbaru akan menimpa data lama
- Untuk custom conflict resolution, edit `syncBidirectional` method

### 4. Performance Issues
- Gunakan incremental sync (lastSyncTime parameter)
- Batasi jumlah data yang di-sync sekaligus
- Gunakan pagination untuk data besar

## Next Steps

1. **Setup Firestore Security Rules** (PENTING!)
   - Go to Firebase Console
   - Firestore Database → Rules
   - Update rules untuk production

2. **Test Offline Mode**
   - Matikan internet
   - Lakukan CRUD operations
   - Nyalakan internet
   - Trigger sync

3. **Implement untuk Model Lain**
   - Buat hybrid repository untuk Product, Transaction, dll
   - Tambahkan sync methods

4. **Monitor Sync Status**
   - Tambahkan sync indicators di UI
   - Log sync activities
   - Handle errors gracefully

5. **Consider Firebase Auth**
   - Replace manual authentication dengan Firebase Auth
   - Lebih secure
   - Built-in user management

## Firestore Security Rules Example

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users collection
    match /users/{username} {
      // Semua user bisa baca
      allow read: if request.auth != null;

      // Hanya owner yang bisa update
      allow write: if request.auth != null
                   && request.auth.token.username == username;
    }

    // Products collection
    match /products/{productId} {
      allow read: if true; // Public read
      allow write: if request.auth != null; // Authenticated write
    }
  }
}
```

## Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
