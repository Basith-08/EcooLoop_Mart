import '../data/models/user_model.dart';

/// Base class for all user states
abstract class UserState {
  const UserState();
}

/// Initial state when no action has been performed
class UserInitial extends UserState {
  const UserInitial();
}

/// Loading state while performing operations
class UserLoading extends UserState {
  const UserLoading();
}

/// Success state when users are loaded
class UserLoaded extends UserState {
  final List<UserModel> users;

  const UserLoaded(this.users);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserLoaded &&
           other.users.length == users.length &&
           _listEquals(other.users, users);
  }

  bool _listEquals(List<UserModel> list1, List<UserModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => users.hashCode;
}

/// Success state when a single user is loaded
class UserDetailLoaded extends UserState {
  final UserModel user;

  const UserDetailLoaded(this.user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDetailLoaded && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

/// Success state when user is created
class UserCreated extends UserState {
  final UserModel user;
  final String message;

  const UserCreated(this.user, {this.message = 'User created successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserCreated &&
           other.user == user &&
           other.message == message;
  }

  @override
  int get hashCode => user.hashCode ^ message.hashCode;
}

/// Success state when user is updated
class UserUpdated extends UserState {
  final UserModel user;
  final String message;

  const UserUpdated(this.user, {this.message = 'User updated successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserUpdated &&
           other.user == user &&
           other.message == message;
  }

  @override
  int get hashCode => user.hashCode ^ message.hashCode;
}

/// Success state when user is deleted
class UserDeleted extends UserState {
  final String message;

  const UserDeleted({this.message = 'User deleted successfully'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDeleted && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Error state when an operation fails
class UserError extends UserState {
  final String message;
  final Exception? exception;

  const UserError(this.message, {this.exception});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserError &&
           other.message == message &&
           other.exception == exception;
  }

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// Empty state when no users found
class UserEmpty extends UserState {
  final String message;

  const UserEmpty({this.message = 'No users found'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEmpty && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
