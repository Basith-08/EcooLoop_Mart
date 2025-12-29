import 'package:flutter/material.dart';
import 'eco_components.dart';

class EcoFormDialog extends StatelessWidget {
  const EcoFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.primaryColor = const Color(0xFF2D9F5D),
    this.secondaryLabel = 'Batal',
    this.onSecondaryPressed,
    this.maxWidth = 420,
    this.busy = false,
  });

  final String title;
  final Widget child;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final Color primaryColor;
  final String secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final double maxWidth;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2430),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Flexible(child: SingleChildScrollView(child: child)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : (onSecondaryPressed ??
                              () => Navigator.of(context).pop()),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(secondaryLabel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: EcoPrimaryButton(
                      label: primaryLabel,
                      onPressed: onPrimaryPressed,
                      color: primaryColor,
                      height: 50,
                      busy: busy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

