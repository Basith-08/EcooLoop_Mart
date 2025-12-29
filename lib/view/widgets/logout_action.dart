import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../auth/login_page.dart';
import 'eco_dialog.dart';

Future<void> confirmLogoutAndNavigate(BuildContext context) async {
  final confirmed = await showEcoDialog<bool>(
    context,
    title: 'Konfirmasi Logout',
    message: 'Apakah Anda yakin ingin keluar?',
    type: EcoDialogType.warning,
    actions: [
      EcoDialogAction(
        label: 'Batal',
        onPressed: () => Navigator.of(context).pop(false),
      ),
      EcoDialogAction(
        label: 'Keluar',
        isPrimary: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );

  if (confirmed != true || !context.mounted) return;

  await context.read<AuthViewModel>().logout();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

