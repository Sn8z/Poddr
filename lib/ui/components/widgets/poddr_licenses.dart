import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/gaps.dart';
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
          return _buildShimmer();
        }

        final licenses = snapshot.data ?? [];
        if (licenses.isEmpty) {
          return Text(
            "No license information available.",
            style: TextStyle(
              color: context.theme.onSurfaceVariant,
              fontSize: 14,
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

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < 3 ? 20 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 18, width: 100.0 + (i * 20), radius: 4),
              gapH8,
              ShimmerBox(height: 13, width: double.infinity, radius: 4),
              gapH4,
              ShimmerBox(height: 13, width: double.infinity, radius: 4),
              gapH4,
              ShimmerBox(height: 13, width: 200.0, radius: 4),
            ],
          ),
        );
      }),
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.onSurface,
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
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
