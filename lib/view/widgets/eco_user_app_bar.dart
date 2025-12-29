import 'package:flutter/material.dart';

class EcoUserAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EcoUserAppBar({
    super.key,
    this.title = 'EcoLoop Mart',
    this.subtitle,
    this.onBack,
    this.onLogout,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: onBack == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: onBack,
            ),
      titleSpacing: onBack == null ? 16 : 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      actions: [
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: onLogout,
          ),
      ],
    );
  }
}

