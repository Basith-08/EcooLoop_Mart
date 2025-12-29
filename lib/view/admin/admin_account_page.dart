import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../state/user_state.dart';
import '../../data/models/user_model.dart';
import '../widgets/admin_header.dart';
import '../widgets/eco_components.dart';
import '../widgets/eco_dialog.dart';
import '../widgets/logout_action.dart';

class AdminAccountPage extends StatefulWidget {
  const AdminAccountPage({super.key});

  @override
  State<AdminAccountPage> createState() => _AdminAccountPageState();
}

class _AdminAccountPageState extends State<AdminAccountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadData() {
    Future.microtask(() {
      context.read<UserViewModel>().loadUsers();
    });
  }

  String get _selectedRole {
    return _tabController.index == 0 ? 'warga' : 'admin';
  }

  Future<void> _createAccount() async {
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      await showEcoDialog(
        context,
        title: 'Data belum lengkap',
        message: 'Semua field harus diisi sebelum menyimpan akun.',
        type: EcoDialogType.warning,
      );
      return;
    }

    await context.read<UserViewModel>().createUser(
          name: _nameController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          role: _selectedRole,
        );

    if (!mounted) return;

    await showEcoDialog(
      context,
      title: 'Akun berhasil dibuat',
      message: 'Akun ${_selectedRole} berhasil ditambahkan.',
      type: EcoDialogType.success,
    );

    // Clear form
    _nameController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  void _showEditUserDialog(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController(text: user.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        titlePadding: EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Adjusted for better mobile spacing
        actionsPadding: EdgeInsets.zero,
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Edit Akun',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nama Lengkap',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      usernameController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    await showEcoDialog(
                      context,
                      title: 'Data belum lengkap',
                      message:
                          'Semua field harus diisi sebelum menyimpan perubahan.',
                      type: EcoDialogType.warning,
                    );
                    return;
                  }

                  final updatedUser = user.copyWith(
                    name: nameController.text,
                    username: usernameController.text,
                    password: passwordController.text,
                  );

                  await context.read<UserViewModel>().updateUser(updatedUser);

                  if (!mounted) return;
                  Navigator.pop(context);
                  await showEcoDialog(
                    context,
                    title: 'Akun diperbarui',
                    message: 'Perubahan data akun berhasil disimpan.',
                    type: EcoDialogType.success,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4169E1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(UserModel user, int activeAdminCount) async {
    if (user.id == null) return;

    final isDeactivating = user.isActive;

    if (isDeactivating && user.isAdmin && activeAdminCount <= 1) {
      await showEcoDialog(
        context,
        title: 'Aksi dibatasi',
        message: 'Minimal harus ada satu admin aktif.',
        type: EcoDialogType.warning,
      );
      return;
    }

    final newStatus = isDeactivating ? 'inactive' : 'active';

    await context.read<UserViewModel>().updateUserStatus(user.id!, newStatus);

    if (!mounted) return;
    await showEcoDialog(
      context,
      title: isDeactivating ? 'Akun dinonaktifkan' : 'Akun diaktifkan',
      message: isDeactivating
          ? 'Pengguna tidak dapat login hingga diaktifkan kembali.'
          : 'Pengguna kini dapat login kembali.',
      type: EcoDialogType.success,
    );
  }

  void _handleLogout() async {
    await confirmLogoutAndNavigate(context);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userViewModel = context.watch<UserViewModel>();
    final adminName = authViewModel.currentUser?.name ?? 'Admin';

    // Get list of users
    List<UserModel> users = [];
    if (userViewModel.state is UserLoaded) {
      users = (userViewModel.state as UserLoaded).users;
    }

    final activeAdminCount =
        users.where((u) => u.role == 'admin' && u.isActive).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AdminHeader(
        adminName: adminName,
        onLogout: _handleLogout,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AdminTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Account Section
              EcoCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.add_circle_outline,
                            color: Color(0xFF2D9F5D)),
                        SizedBox(width: 6),
                        Text(
                          'Tambah Akun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Role Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: _tabController.index == 0
                              ? const Color(0xFF2D9F5D)
                              : const Color(0xFFFF8C42),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF8A93A5),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                        tabs: const [
                          Tab(text: 'Warga'),
                          Tab(text: 'Admin'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Form Fields
                    EcoInputField(
                      controller: _nameController,
                      hint: 'Nama Lengkap',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    const SizedBox(height: 8),
                    EcoInputField(
                      controller: _usernameController,
                      hint: 'Username',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    const SizedBox(height: 8),
                    EcoInputField(
                      controller: _passwordController,
                      hint: 'Password',
                      obscure: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    const SizedBox(height: 10),

                    // Save Button
                    EcoPrimaryButton(
                      label: 'Simpan',
                      onPressed: _createAccount,
                      color: const Color(0xFF2E86FF),
                      height: 42,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // User List Section
              const Text(
                'DAFTAR AKUN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9AA2AF),
                ),
              ),
              const SizedBox(height: 10),

              if (userViewModel.state is UserLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (users.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Belum ada akun'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isAdmin = user.role == 'admin';
                    final isActive = user.isActive;
                    final canDeactivateAdmin =
                        !(isAdmin && isActive && activeAdminCount <= 1);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isAdmin
                                ? const Color(0xFFFFE8DC)
                                : const Color(0xFFE8F5E9),
                            child: Icon(
                              isAdmin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: isAdmin
                                  ? const Color(0xFFFF8C42)
                                  : const Color(0xFF2D9F5D),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFF2F4F7),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: isActive
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFF98A2B3),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '@${user.username} • ${user.ecoPoints.toInt()} pts',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _showEditUserDialog(user),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9F1FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    size: 15,
                                    color: Color(0xFF2E86FF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: canDeactivateAdmin
                                    ? () => _toggleUserStatus(
                                          user,
                                          activeAdminCount,
                                        )
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: canDeactivateAdmin
                                        ? (isActive
                                            ? const Color(0xFFFFE9E7)
                                            : const Color(0xFFE8F5E9))
                                        : const Color(0xFFF2F4F7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isActive
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    size: 15,
                                    color: canDeactivateAdmin
                                        ? (isActive
                                            ? const Color(0xFFE1444B)
                                            : const Color(0xFF2D9F5D))
                                        : const Color(0xFFB0B8C4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
