import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/info_row.dart';
import 'package:poddr/ui/components/widgets/status_message.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/sync.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
import 'package:poddr/ui/views/settings/sync/sync_settings_view_model.dart';
import 'package:poddr/ui/utils/string_converter.dart';

class SyncSection extends StatelessWidget {
  const SyncSection({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.read<SyncProvider>();

    return ChangeNotifierProvider(
      create: (_) => SyncSetupProvider(
        initialServer: sync.serverUrl,
        initialUsername: sync.username,
        initialDeviceName: sync.deviceName.isEmpty ? 'Poddr' : sync.deviceName,
      ),
      builder: (context, child) {
        final sync = context.watch<SyncProvider>();
        final setup = context.watch<SyncSetupProvider>();

        if (sync.isConfigured) {
          return _buildConfiguredView(context, sync, setup);
        } else {
          return _buildSetupView(context, sync, setup);
        }
      },
    );
  }

  Widget _buildConfiguredView(
      BuildContext context, SyncProvider sync, SyncSetupProvider setup) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primary.withAlpha(20),
                theme.primary.withAlpha(10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primary.withAlpha(50),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_done_outlined,
                  color: theme.primary,
                  size: 28,
                ),
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected',
                      style: context.theme.textTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                    ),
                    gapH4,
                    Text(
                      '${setup.username} @ ${setup.server}',
                      style: context.theme.textTheme.bodyMedium.copyWith(
                            color: theme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: sync.isLoading ? null : () => sync.syncNow(),
                tooltip: 'Sync Now',
                style: IconButton.styleFrom(
                  backgroundColor: theme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        gapH32,
        PoddrInfoRow(
          icon: Icons.devices_outlined,
          label: 'Device Name',
          value: setup.deviceName,
        ),
        gapH16,
        PoddrInfoRow(
          icon: Icons.sync_alt_outlined,
          label: 'Syncing With',
          value: sync.targetSyncDeviceName.isEmpty
              ? 'No device selected'
              : sync.targetSyncDeviceName,
          onTap:
              sync.isLoading ? null : () => _showDeviceSelection(context, sync),
          action: Icon(
            Icons.chevron_right,
            size: 18,
            color: theme.primary,
          ),
        ),
        if (sync.lastSyncTime != null) ...[
          gapH16,
          PoddrInfoRow(
            icon: Icons.access_time_outlined,
            label: 'Last Sync',
            value: convertDateToTimeAgo(sync.lastSyncTime!),
          ),
        ],
        gapH24,
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: sync.isLoading ? null : () => sync.disconnectUi(),
                icon: const Icon(Icons.link_off, size: 18),
                label: const Text('Disconnect'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        gapH12,
        OutlinedButton.icon(
          onPressed: sync.isLoading ? null : () => _showFullResyncDialog(context, sync),
          icon: const Icon(Icons.sync, size: 18),
          label: const Text('Full Re-Sync'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (sync.errorMessage != null && sync.errorMessage!.isNotEmpty) ...[
          gapH16,
          PoddrStatusMessage(message: sync.errorMessage!, isError: true),
        ],
        if (sync.statusMessage != null && sync.statusMessage!.isNotEmpty) ...[
          gapH16,
          PoddrStatusMessage(message: sync.statusMessage!),
        ],
      ],
    );
  }

  Widget _buildSetupView(
      BuildContext context, SyncProvider sync, SyncSetupProvider setup) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PoddrTextInput(
          initialValue: setup.server,
          onChanged: (value) => setup.updateServer(value),
          labelText: 'Server URL',
          hintText: 'https://gpodder.net',
          prefixIcon: Icon(Icons.link),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.username,
          onChanged: (value) => setup.updateUsername(value),
          labelText: 'Username',
          hintText: 'Enter your username',
          prefixIcon: Icon(Icons.person_outline),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.password,
          onChanged: (value) => setup.updatePassword(value),
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icon(Icons.lock_outline),
          obscure: !setup.showPassword,
          suffixIcon: IconButton(
            icon: Icon(
              setup.showPassword ? Icons.visibility_off : Icons.visibility,
              color: theme.primary,
            ),
            onPressed: () => setup.togglePasswordVisibility(),
          ),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.deviceName,
          onChanged: (value) => setup.updateDeviceName(value),
          labelText: 'Device Name',
          hintText: 'Poddr',
          prefixIcon: Icon(Icons.phone_android_outlined),
        ),
        gapH24,
        FilledButton.icon(
          onPressed: sync.isLoading
              ? null
              : () => sync.connect(
                    serverUrl: setup.server.trim(),
                    username: setup.username.trim(),
                    password: setup.password,
                    deviceName: setup.deviceName.trim().isEmpty
                        ? 'Poddr'
                        : setup.deviceName.trim(),
                  ),
          icon: sync.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.link, size: 18),
          label: Text(sync.isLoading ? 'Connecting...' : 'Connect'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (sync.errorMessage != null && sync.errorMessage!.isNotEmpty) ...[
          gapH16,
          PoddrStatusMessage(message: sync.errorMessage!, isError: true),
        ],
        if (sync.statusMessage != null && sync.statusMessage!.isNotEmpty) ...[
          gapH16,
          PoddrStatusMessage(message: sync.statusMessage!),
        ],
        gapH24,
        PoddrStatusMessage(
            message:
                'Your credentials are only stored locally on this device and securely transmitted to the sync server. Poddr does not have access to your password or sync data.'),
        gapH16,
        PoddrStatusMessage(
            message: "Supports gPodder compatible sync servers."),
      ],
    );
  }

  Future<void> _showDeviceSelection(
      BuildContext context, SyncProvider sync) async {
    await sync.loadDevices();

    if (!context.mounted) return;

    final devices = sync.devices;
    if (devices == null || devices.isEmpty) {
      sync.selectSyncDevice('');
      return;
    }

    final currentDeviceId = sync.deviceId;
    final syncGroups = sync.syncGroups;
    final synchronized = syncGroups?['synchronized'] as List? ?? [];

    final syncedDeviceIds = <String>{};
    for (final group in synchronized) {
      if (group is List) {
        syncedDeviceIds.addAll(group.map((id) => id.toString()));
      }
    }

    final groupedDevices = <List<Map<String, dynamic>>>[];
    for (final group in synchronized) {
      if (group is List) {
        final groupIds = group.map((id) => id.toString()).toList();
        final groupDevices = devices
            .where((d) => groupIds.contains(d['id']))
            .map((d) => Map<String, dynamic>.from(d))
            .toList();
        if (groupDevices.isNotEmpty) {
          groupedDevices.add(groupDevices);
        }
      }
    }

    final unsyncedDevices = devices
        .where((d) =>
            d['id'] != currentDeviceId && !syncedDeviceIds.contains(d['id']))
        .toList();

    if (groupedDevices.isEmpty && unsyncedDevices.isEmpty) {
      sync.selectSyncDevice('');
      return;
    }

    if (!context.mounted) return;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => PoddrDialog(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Sync With',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.theme.onSurface,
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: Row(
              children: [
                Icon(
                  groupedDevices.isEmpty
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off_outlined,
                  size: 20,
                  color: context.theme.primary,
                ),
                gapW12,
                const Text('None (don\'t sync)'),
              ],
            ),
          ),
          for (var i = 0; i < groupedDevices.length; i++) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Sync Group ${i + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...groupedDevices[i].map((device) => SimpleDialogOption(
                  onPressed: () =>
                      Navigator.pop(context, device['id'] as String),
                  child: Row(
                    children: [
                      Icon(
                        device['id'] == sync.targetSyncDeviceId
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off_outlined,
                        size: 20,
                        color: context.theme.primary,
                      ),
                      gapW12,
                      Text(device['caption'] ?? device['id'] ?? 'Unknown'),
                    ],
                  ),
                )),
          ],
          if (unsyncedDevices.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Unsynced Devices',
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...unsyncedDevices.map((device) => SimpleDialogOption(
                  onPressed: () =>
                      Navigator.pop(context, device['id'] as String),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radio_button_off_outlined,
                        size: 20,
                        color: context.theme.onSurfaceVariant,
                      ),
                      gapW12,
                      Text(device['caption'] ?? device['id'] ?? 'Unknown'),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );

    if (selected != null && context.mounted) {
      await sync.selectSyncDevice(selected);
    }
  }

  Future<void> _showFullResyncDialog(BuildContext context, SyncProvider sync) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PoddrDialog(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Full Re-Sync',
              style: context.theme.textTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Text(
            'This will:\n'
            '• Clear all unsynced local changes\n'
            '• Pull all current server subscriptions and episode history\n'
            '• Preserve all local subscriptions\n'
            '• Set sync timestamps to current time (only new data fetched next sync)',
          ),
          gapH20,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              gapW12,
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await sync.fullResync();
    }
  }
}
