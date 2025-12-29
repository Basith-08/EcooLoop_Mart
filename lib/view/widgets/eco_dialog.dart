import 'package:flutter/material.dart';

enum EcoDialogType { info, success, error, warning }

class EcoDialogAction {
  EcoDialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
}

Future<T?> showEcoDialog<T>(
  BuildContext context, {
  required String title,
  required String message,
  EcoDialogType type = EcoDialogType.info,
  List<EcoDialogAction>? actions,
  bool barrierDismissible = true,
}) {
  Color resolveColor() {
    switch (type) {
      case EcoDialogType.success:
        return const Color(0xFF2D9F5D);
      case EcoDialogType.error:
        return const Color(0xFFE1444B);
      case EcoDialogType.warning:
        return const Color(0xFFFF8C42);
      case EcoDialogType.info:
      default:
        return const Color(0xFF2D9F5D);
    }
  }

  final color = resolveColor();
  final dialogActions = actions ??
      [
        EcoDialogAction(
          label: 'Tutup',
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ];

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4F5968),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: dialogActions.map((action) {
                  final button = action.isPrimary
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onPressed:
                              action.onPressed ?? () => Navigator.of(ctx).pop(),
                          child: Text(
                            action.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color.withOpacity(0.6)),
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed:
                              action.onPressed ?? () => Navigator.of(ctx).pop(),
                          child: Text(action.label),
                        );
                  return button;
                }).toList(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showEcoPopup(
  BuildContext context, {
  required String message,
  EcoDialogType type = EcoDialogType.info,
  Duration duration = const Duration(seconds: 1),
}) async {
  Color resolveColor() {
    switch (type) {
      case EcoDialogType.success:
        return const Color(0xFF2D9F5D);
      case EcoDialogType.error:
        return const Color(0xFFE1444B);
      case EcoDialogType.warning:
        return const Color(0xFFFF8C42);
      case EcoDialogType.info:
      default:
        return const Color(0xFF2D9F5D);
    }
  }

  final color = resolveColor();

  bool dismissed = false;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (ctx) {
      Future.delayed(duration, () {
        if (dismissed) return;
        if (Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }
      });

      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  ).whenComplete(() {
    dismissed = true;
  });
}
