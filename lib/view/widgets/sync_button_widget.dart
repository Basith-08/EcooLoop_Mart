import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/sync_viewmodel.dart';

/// Widget untuk tombol sync dengan status indicator
///
/// Usage:
/// ```dart
/// SyncButtonWidget(
///   onSyncComplete: () {
///     // Refresh data setelah sync
///   },
/// )
/// ```
class SyncButtonWidget extends StatelessWidget {
  final VoidCallback? onSyncComplete;

  const SyncButtonWidget({
    Key? key,
    this.onSyncComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncViewModel>(
      builder: (context, syncVM, child) {
        return PopupMenuButton<String>(
          icon: Stack(
            children: [
              Icon(
                syncVM.isSyncing
                    ? Icons.sync
                    : Icons.cloud_sync,
                color: syncVM.hasError
                    ? Colors.red
                    : syncVM.hasSuccess
                        ? Colors.green
                        : null,
              ),
              if (syncVM.isSyncing)
                Positioned.fill(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          tooltip: 'Sync Data',
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'upload',
              enabled: !syncVM.isSyncing,
              child: Row(
                children: const [
                  Icon(Icons.cloud_upload, size: 20),
                  SizedBox(width: 8),
                  Text('Upload ke Cloud'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'download',
              enabled: !syncVM.isSyncing,
              child: Row(
                children: const [
                  Icon(Icons.cloud_download, size: 20),
                  SizedBox(width: 8),
                  Text('Download dari Cloud'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'bidirectional',
              enabled: !syncVM.isSyncing,
              child: Row(
                children: const [
                  Icon(Icons.sync, size: 20),
                  SizedBox(width: 8),
                  Text('Sync Dua Arah'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'status',
              enabled: false,
              child: Text(
                syncVM.getSyncStatusText(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'upload':
                await _handleSync(context, syncVM, syncVM.syncToCloud);
                break;
              case 'download':
                await _handleSync(context, syncVM, syncVM.syncFromCloud);
                break;
              case 'bidirectional':
                await _handleSync(context, syncVM, syncVM.syncBidirectional);
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _handleSync(
    BuildContext context,
    SyncViewModel syncVM,
    Future<void> Function() syncFunction,
  ) async {
    // Clear previous messages
    syncVM.clearMessages();

    // Perform sync
    await syncFunction();

    // Show result
    if (!context.mounted) return;

    if (syncVM.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(syncVM.errorMessage ?? 'Sync gagal'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (syncVM.hasSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(syncVM.successMessage ?? 'Sync berhasil'),
          backgroundColor: Colors.green,
        ),
      );

      // Call callback if provided
      onSyncComplete?.call();
    }
  }
}

/// Widget untuk menampilkan sync status banner
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncViewModel>(
      builder: (context, syncVM, child) {
        if (!syncVM.isSyncing && !syncVM.hasError) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: syncVM.hasError
              ? Colors.red.shade100
              : Colors.blue.shade100,
          child: Row(
            children: [
              if (syncVM.isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  syncVM.hasError ? Icons.error_outline : Icons.info_outline,
                  size: 16,
                  color: syncVM.hasError ? Colors.red : Colors.blue,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  syncVM.isSyncing
                      ? 'Sedang sync data...'
                      : syncVM.errorMessage ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: syncVM.hasError ? Colors.red.shade900 : Colors.blue.shade900,
                  ),
                ),
              ),
              if (!syncVM.isSyncing)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => syncVM.clearMessages(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact sync button untuk list tiles
class CompactSyncButton extends StatelessWidget {
  final VoidCallback? onSyncComplete;

  const CompactSyncButton({
    Key? key,
    this.onSyncComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncViewModel>(
      builder: (context, syncVM, child) {
        return IconButton(
          icon: syncVM.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          tooltip: 'Sync Data',
          onPressed: syncVM.isSyncing
              ? null
              : () async {
                  syncVM.clearMessages();
                  await syncVM.syncBidirectional();

                  if (!context.mounted) return;

                  if (syncVM.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(syncVM.errorMessage ?? 'Sync gagal'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (syncVM.hasSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(syncVM.successMessage ?? 'Sync berhasil'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    onSyncComplete?.call();
                  }
                },
        );
      },
    );
  }
}
