# Firebase Firestore Usage Guide for EcoLoop Mart

## What's Been Set Up

1. **Firebase Configuration** (`lib/firebase_options.dart`)
   - Auto-generated configuration for Android, iOS, Web, Windows, and macOS
   - Project ID: `ecoloop-mart`

2. **Dependencies** (in `pubspec.yaml`)
   - `firebase_core: ^3.8.1` - Core Firebase SDK
   - `cloud_firestore: ^5.5.1` - Cloud Firestore database

3. **Firebase Initialization** (in `lib/main.dart:40-42`)
   - Firebase is initialized before the app starts

## Using Firestore in Your App

### Option 1: Use the Firestore Repository Example

I've created `lib/data/repositories/user_firestore_repository.dart` as an example of how to use Firestore instead of SQLite.

**Key Features:**
- CRUD operations (Create, Read, Update, Delete)
- Real-time data streaming with `Stream<List<UserModel>>`
- Querying and filtering
- Transactions for atomic operations (e.g., updating points)
- Batch operations

**Example Usage:**

```dart
// In your ViewModel or Service
final userFirestoreRepo = UserFirestoreRepository();

// Create a user
final userId = await userFirestoreRepo.register(newUser);

// Get all users (one-time)
final users = await userFirestoreRepo.getAllUsers();

// Get all users (real-time stream)
userFirestoreRepo.getAllUsersStream().listen((users) {
  // This will update automatically when data changes
  print('Users updated: ${users.length}');
});

// Update eco points atomically
await userFirestoreRepo.addEcoPoints(userId, 100.0);

// Query users by role
final admins = await userFirestoreRepo.getUsersByRole('admin');
```

### Option 2: Direct Firestore Usage

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

// Create
await firestore.collection('products').add({
  'name': 'Organic Bottle',
  'price': 5000,
  'created_at': FieldValue.serverTimestamp(),
});

// Read
final snapshot = await firestore.collection('products').get();
for (var doc in snapshot.docs) {
  print('${doc.id}: ${doc.data()}');
}

// Update
await firestore.collection('products').doc(productId).update({
  'price': 6000,
  'updated_at': FieldValue.serverTimestamp(),
});

// Delete
await firestore.collection('products').doc(productId).delete();

// Real-time listening
firestore.collection('products').snapshots().listen((snapshot) {
  for (var change in snapshot.docChanges) {
    print('Type: ${change.type}, Data: ${change.doc.data()}');
  }
});
```

## Firebase Console Setup

To fully use Firestore, you need to set up your database in the Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `ecoloop-mart`
3. Navigate to **Firestore Database** in the left menu
4. Click **Create Database**
5. Choose **Start in test mode** (for development)
   - **Note:** Test mode allows unrestricted access. Update security rules before production!
6. Select a location (choose the closest to your users)

## Firestore Security Rules (Important!)

Initially, use test mode rules for development:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 2, 4);
    }
  }
}
```

**For production**, implement proper security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Products collection (example)
    match /products/{productId} {
      allow read: if true; // Public read
      allow write: if request.auth != null; // Authenticated users can write
    }
  }
}
```

## Firestore vs SQLite in This Project

**Current Setup:**
- Uses SQLite for local storage
- Data is stored on the device

**With Firestore:**
- Cloud-based storage
- Real-time synchronization across devices
- Automatic offline support
- Scalable for multiple users

**You can use both:**
- SQLite for offline-first features
- Firestore for cloud sync and multi-user features

## Common Firestore Patterns

### 1. Real-time Updates with StreamBuilder

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('products').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();

    final products = snapshot.data!.docs;
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text(product['name']),
          subtitle: Text('Rp ${product['price']}'),
        );
      },
    );
  },
)
```

### 2. Pagination

```dart
Query query = firestore.collection('products').limit(20);

// Get first page
final firstPage = await query.get();

// Get next page
if (firstPage.docs.isNotEmpty) {
  final lastDoc = firstPage.docs.last;
  final nextPage = await query.startAfterDocument(lastDoc).get();
}
```

### 3. Compound Queries

```dart
final results = await firestore
    .collection('products')
    .where('category', isEqualTo: 'plastic')
    .where('price', isLessThan: 10000)
    .orderBy('price')
    .get();
```

## Next Steps

1. **Set up Firestore in Firebase Console** (see instructions above)
2. **Create collections** for your data (users, products, transactions, etc.)
3. **Choose your approach:**
   - Migrate existing repositories to Firestore
   - Use both SQLite (local) and Firestore (sync)
   - Create new Firestore-based features
4. **Implement security rules** before going to production
5. **Consider using Firebase Authentication** instead of storing passwords

## Additional Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
