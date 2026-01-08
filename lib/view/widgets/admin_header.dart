import 'package:flutter/material.dart';
import 'sync_button_widget.dart';

class AdminHeader extends StatelessWidget implements PreferredSizeWidget {
  const AdminHeader({
    super.key,
    required this.adminName,
    required this.onLogout,
  });

  final String adminName;
  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2430),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Halo, $adminName',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA2AF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SyncButtonWidget(),
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.logout, color: Color(0xFFE1444B)),
                onPressed: onLogout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminTheme {
  const AdminTheme._();

  static const double pagePadding = 14;
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));
}
