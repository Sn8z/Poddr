import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/info_row.dart';
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
import 'package:poddr/ui/components/widgets/status_banner.dart';
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
        }
        return _buildSetupView(context, sync, setup);
      },
    );
  }

  StatusSeverity _severityFor(SyncProvider sync) {
    if (sync.statusIsError) return StatusSeverity.error;
    if (sync.statusIsWarning) return StatusSeverity.warning;
    return StatusSeverity.info;
  }

  Widget _buildConnectedHeader(BuildContext context, SyncProvider sync) {
    final theme = context.theme;
    final status = sync.status;
    final isSyncing = status == SyncStatus.syncing;
    final isError = sync.statusIsError;
    final isWarning = sync.statusIsWarning;

    final headerColor = isError
        ? theme.error
        : (isWarning || isSyncing)
            ? theme.tertiary
            : theme.primary;

    final String headerLabel;
    if (isSyncing) {
      headerLabel = 'Syncing...';
    } else if (status == SyncStatus.credentialsInvalid) {
      headerLabel = 'Sign-in required';
    } else if (isError) {
      headerLabel = 'Sync error';
    } else if (isWarning) {
      headerLabel = 'Sync needs attention';
    } else {
      headerLabel = 'Connected';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            headerColor.withAlpha(20),
            headerColor.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: headerColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: headerColor.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isSyncing
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: PoddrSpinner(
                      size: 24,
                      strokeWidth: 2.5,
                      color: headerColor,
                    ),
                  )
                : HugeIcon(
                    icon: isError
                        ? HugeIcons.strokeRoundedAlertSquare
                        : HugeIcons.strokeRoundedCloud,
                    color: headerColor,
                  ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerLabel,
                  style: context.theme.textTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
                gapH4,
                Text(
                  '${sync.username} @ ${sync.serverUrl}',
                  style: context.theme.textTheme.bodyMedium.copyWith(
                    color: theme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isSyncing)
            PoddrIconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
              ),
              onPressed: sync.isLoading ? null : () => sync.syncNow(),
            ),
        ],
      ),
    );
  }

  Widget _buildConfiguredView(
      BuildContext context, SyncProvider sync, SyncSetupProvider setup) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildConnectedHeader(context, sync),
        gapH32,
        PoddrInfoRow(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedComputerPhoneSync,
          ),
          label: 'Device Name',
          value: setup.deviceName,
        ),
        gapH16,
        PoddrInfoRow(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedDatabaseSync,
          ),
          label: 'Syncing With',
          value: sync.targetSyncDeviceName.isEmpty
              ? 'No device selected'
              : sync.targetSyncDeviceName,
          onTap:
              sync.isLoading ? null : () => _showDeviceSelection(context, sync),
          action: HugeIcon(
            icon: HugeIcons.strokeRoundedEdit01,
            size: 18,
            color: theme.primary,
          ),
        ),
        if (sync.lastSyncTime != null) ...[
          gapH16,
          PoddrInfoRow(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
            ),
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
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedUnlink01,
                    ),
                    gapW8,
                    Text('Disconnect'),
                  ],
                ),
              ),
            ),
          ],
        ),
        gapH12,
        PoddrOutlinedButton(
          onPressed: sync.isLoading
              ? null
              : () => _showFullResyncDialog(context, sync),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
              ),
              gapW8,
              Text('Full Re-Sync'),
            ],
          ),
        ),
        if (sync.statusDescription != null &&
            sync.statusDescription!.isNotEmpty) ...[
          gapH16,
          StatusBanner(
            message: sync.statusDescription!,
            severity: _severityFor(sync),
          ),
        ],
      ],
    );
  }

  Widget _buildSetupView(
      BuildContext context, SyncProvider sync, SyncSetupProvider setup) {
    final theme = context.theme;
    final isWorking = sync.isLoading;
    final String? statusMessage;

    if (sync.status == SyncStatus.connecting) {
      statusMessage = sync.statusDescription ?? 'Connecting to sync server...';
    } else if (sync.status == SyncStatus.retrying) {
      statusMessage = sync.statusDescription ?? 'Retrying...';
    } else if (sync.status == SyncStatus.credentialsInvalid) {
      statusMessage = sync.statusDescription ?? 'Invalid username or password';
    } else if (sync.status == SyncStatus.warning ||
        sync.status == SyncStatus.error) {
      statusMessage = sync.statusDescription;
    } else if (sync.status == SyncStatus.disconnected) {
      statusMessage = sync.statusDescription;
    } else {
      statusMessage = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PoddrTextInput(
          initialValue: setup.server,
          onChanged: (value) => setup.updateServer(value),
          labelText: 'Server URL',
          hintText: 'https://gpodder.net',
          prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedLink01,
              color: theme.onSurfaceVariant),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.username,
          onChanged: (value) => setup.updateUsername(value),
          labelText: 'Username',
          hintText: 'Enter your username',
          prefixIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedUser,
            color: theme.onSurfaceVariant,
          ),
        ),
        gapH24,
        PoddrTextInput(
          initialValue: setup.password,
          onChanged: (value) => setup.updatePassword(value),
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedSquareLockPassword,
            color: theme.onSurfaceVariant,
          ),
          obscure: !setup.showPassword,
          suffixIcon: PoddrIconButton(
            icon: HugeIcon(
              icon: setup.showPassword
                  ? HugeIcons.strokeRoundedView
                  : HugeIcons.strokeRoundedViewOff,
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
          prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedComputerPhoneSync,
              color: theme.onSurfaceVariant),
        ),
        gapH24,
        PoddrFilledButton(
          onPressed: isWorking
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
              if (isWorking) ...[
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
                HugeIcon(icon: HugeIcons.strokeRoundedLink01),
              if (isWorking) const SizedBox(width: 8),
              Text(isWorking ? 'Connecting...' : 'Connect'),
            ],
          ),
        ),
        if (statusMessage != null) ...[
          gapH16,
          StatusBanner(
            message: statusMessage,
            severity: _severityFor(sync),
          ),
        ],
        gapH24,
        const StatusBanner(
          message:
              'Your credentials are only stored locally on this device and securely transmitted to the sync server. Poddr does not have access to your password or sync data.',
        ),
        gapH16,
        const StatusBanner(
          message: 'Supports gPodder compatible sync servers.',
        ),
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
        header: Text(
          'Sync With',
          style: context.theme.textTheme.titleMedium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(dialogContext, ''),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: groupedDevices.isEmpty
                          ? HugeIcons.strokeRoundedCheckmarkCircle01
                          : HugeIcons.strokeRoundedCircle,
                      size: 20,
                      color: context.theme.primary,
                    ),
                    gapW12,
                    Text('None (don\'t sync)',
                        style: context.theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < groupedDevices.length; i++) ...[
              const PoddrDivider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Sync Group ${i + 1}',
                  style: context.theme.textTheme.labelMedium.copyWith(
                    color: context.theme.primary,
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
                          HugeIcon(
                            icon: device['id'] == sync.targetSyncDeviceId
                                ? HugeIcons.strokeRoundedCheckmarkCircle01
                                : HugeIcons.strokeRoundedCircle,
                            size: 20,
                            color: context.theme.primary,
                          ),
                          gapW12,
                          Text(device['caption'] ?? device['id'] ?? 'Unknown',
                              style: context.theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  )),
            ],
            if (unsyncedDevices.isNotEmpty) ...[
              const PoddrDivider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCircle,
                            size: 20,
                            color: context.theme.onSurfaceVariant,
                          ),
                          gapW12,
                          Text(device['caption'] ?? device['id'] ?? 'Unknown',
                              style: context.theme.textTheme.bodyMedium),
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

  Future<void> _showFullResyncDialog(
      BuildContext context, SyncProvider sync) async {
    final confirmed = await showPoddrDialog<bool>(
      context: context,
      builder: (dialogContext) => PoddrDialog(
        header: Text(
          'Full Re-Sync',
          style: context.theme.textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
        child: Text(
          'This will:\n'
          '• Clear all unsynced local changes\n'
          '• Pull all current server subscriptions and episode history\n'
          '• Preserve all local subscriptions\n'
          '• Set sync timestamps to current time (only new data fetched next sync)',
          style: context.theme.textTheme.bodyMedium,
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      await sync.fullResync();
    }
  }
}
