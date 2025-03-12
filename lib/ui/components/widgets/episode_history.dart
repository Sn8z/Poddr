import 'package:flutter/material.dart';
import 'package:poddr/services/history.dart';
import 'package:provider/provider.dart';

class EpisodeHistory extends StatelessWidget {
  final String audioUrl;
  const EpisodeHistory({
    super.key,
    required this.audioUrl,
  });

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    return FutureBuilder<Map<String, dynamic>?>(
      future: historyProvider.getProgress(audioUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        } else if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          if (data['isFinished']) {
            return const Icon(Icons.done_outline_rounded);
          } else {
            final value = data['position'] / data['duration'];
            if (value != null && value >= 0 && value <= 1) {
              return SizedBox(
                height: 8,
                width: 100,
                child: LinearProgressIndicator(
                  value: value,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
