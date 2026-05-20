import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';

class PoddrLicenseView extends StatefulWidget {
  const PoddrLicenseView({super.key});

  @override
  State<PoddrLicenseView> createState() => _PoddrLicenseViewState();
}

class _PoddrLicenseViewState extends State<PoddrLicenseView> {
  late final Future<List<LicenseEntry>> _licenses;

  @override
  void initState() {
    super.initState();
    _licenses = LicenseRegistry.licenses.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LicenseEntry>>(
      future: _licenses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerLoadingList();
        }

        final licenses = snapshot.data ?? [];
        if (licenses.isEmpty) {
          return Text(
            "No license information available.",
            style: context.theme.textTheme.bodyMedium.copyWith(
              color: context.theme.onSurfaceVariant,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in licenses) _LicenseCard(entry: entry),
          ],
        );
      },
    );
  }
}

class _LicenseCard extends StatelessWidget {
  final LicenseEntry entry;

  const _LicenseCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.packages.join(', '),
            style: theme.textTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          for (final paragraph in entry.paragraphs)
            Padding(
              padding: EdgeInsets.only(
                left: paragraph.indent > 0 ? 16.0 : 0,
                bottom: 6,
              ),
              child: Text(
                paragraph.text,
                textAlign: paragraph.indent == LicenseParagraph.centeredIndent
                    ? TextAlign.center
                    : TextAlign.start,
                style: theme.textTheme.bodyMedium.copyWith(
                  color: theme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
