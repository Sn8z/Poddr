import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/info_row.dart';
import 'package:poddr/ui/components/widgets/status_message.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/sync.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';
import 'package:poddr/ui/components/widgets/poddr_list.dart';
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
                  LucideIcons.cloud,
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
              PoddrIconButton(
                icon: const Icon(LucideIcons.refreshCw, size: 20),
                onPressed: sync.isLoading ? null : () => sync.syncNow(),
              ),
            ],
          ),
        ),
        gapH32,
        PoddrInfoRow(
          icon: LucideIcons.monitor,
          label: 'Device Name',
          value: setup.deviceName,
        ),
        gapH16,
        PoddrInfoRow(
          icon: LucideIcons.arrowLeftRight,
          label: 'Syncing With',
          value: sync.targetSyncDeviceName.isEmpty
              ? 'No device selected'
              : sync.targetSyncDeviceName,
          onTap:
              sync.isLoading ? null : () => _showDeviceSelection(context, sync),
          action: Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: theme.primary,
          ),
        ),
        if (sync.lastSyncTime != null) ...[
          gapH16,
          PoddrInfoRow(
            icon: LucideIcons.clock,
            label: 'Last Sync',
            value: convertDateToTimeAgo(sync.lastSyncTime!),
          ),
        ],
        gapH24,
        Row(
          children: [
            Expanded(
              child: PoddrOutlinedButton(
                onPressed: sync.isLoading ? null : () => sync.disconnectUi(),
                borderColor: context.theme.error,
                foregroundColor: context.theme.error,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.link2Off, size: 18),
                    SizedBox(width: 8),
                    Text('Disconnect'),
                  ],
                ),
              ),
            ),
          ],
        ),
        gapH12,
        PoddrOutlinedButton(
          onPressed: sync.isLoading ? null : () => _showFullResyncDialog(context, sync),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.refreshCw, size: 18),
              SizedBox(width: 8),
              Text('Full Re-Sync'),
            ],
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
          prefixIcon: Icon(LucideIcons.link, color: theme.onSurfaceVariant),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.username,
          onChanged: (value) => setup.updateUsername(value),
          labelText: 'Username',
          hintText: 'Enter your username',
          prefixIcon: Icon(LucideIcons.user, color: theme.onSurfaceVariant),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.password,
          onChanged: (value) => setup.updatePassword(value),
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icon(LucideIcons.lock, color: theme.onSurfaceVariant),
          obscure: !setup.showPassword,
          suffixIcon: PoddrIconButton(
            icon: Icon(
              setup.showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
              color: theme.primary,
            ),
            onPressed: () => setup.togglePasswordVisibility(),
            padding: 2.0,
          ),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.deviceName,
          onChanged: (value) => setup.updateDeviceName(value),
          labelText: 'Device Name',
          hintText: 'Poddr',
          prefixIcon: Icon(LucideIcons.smartphone, color: theme.onSurfaceVariant),
        ),
        gapH24,
        PoddrFilledButton(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sync.isLoading) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: PoddrSpinner(
                    size: 18,
                    strokeWidth: 2,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                const Icon(LucideIcons.link, size: 18),
              if (sync.isLoading) const SizedBox(width: 8),
              Text(sync.isLoading ? 'Connecting...' : 'Connect'),
            ],
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

    final selected = await showPoddrDialog<String>(
      context: context,
      builder: (dialogContext) => PoddrDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Sync With',
                style: context.theme.textTheme.titleMedium,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(dialogContext, ''),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      groupedDevices.isEmpty
                          ? LucideIcons.checkCircle
                          : LucideIcons.circle,
                      size: 20,
                      color: context.theme.primary,
                    ),
                    gapW12,
                    const Text('None (don\'t sync)'),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < groupedDevices.length; i++) ...[
              const PoddrDivider(),
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
              ...groupedDevices[i].map((device) => GestureDetector(
                    onTap: () =>
                        Navigator.pop(dialogContext, device['id'] as String),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            device['id'] == sync.targetSyncDeviceId
                                ? LucideIcons.checkCircle
                                : LucideIcons.circle,
                            size: 20,
                            color: context.theme.primary,
                          ),
                          gapW12,
                          Text(device['caption'] ?? device['id'] ?? 'Unknown'),
                        ],
                      ),
                    ),
                  )),
            ],
            if (unsyncedDevices.isNotEmpty) ...[
              const PoddrDivider(),
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
              ...unsyncedDevices.map((device) => GestureDetector(
                    onTap: () =>
                        Navigator.pop(dialogContext, device['id'] as String),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.circle,
                            size: 20,
                            color: context.theme.onSurfaceVariant,
                          ),
                          gapW12,
                          Text(device['caption'] ?? device['id'] ?? 'Unknown'),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );

    if (selected != null && context.mounted) {
      await sync.selectSyncDevice(selected);
    }
  }

  Future<void> _showFullResyncDialog(BuildContext context, SyncProvider sync) async {
    final confirmed = await showPoddrDialog<bool>(
      context: context,
      builder: (dialogContext) => PoddrDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Re-Sync',
              style: context.theme.textTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            gapH16,
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
                  child: PoddrOutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                ),
                gapW12,
                Expanded(
                  child: PoddrFilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      await sync.fullResync();
    }
  }
}
