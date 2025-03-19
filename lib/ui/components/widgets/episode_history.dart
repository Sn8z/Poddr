import 'package:flutter/material.dart';
import 'package:poddr/services/history.dart';
import 'package:provider/provider.dart';

class EpisodeHistory extends StatelessWidget {
  final double height;
  final double? width;
  final String audioUrl;

  const EpisodeHistory({
    super.key,
    required this.audioUrl,
    this.height = 8,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: FutureBuilder<Map<String, dynamic>?>(
        future: historyProvider.getProgress(audioUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            if (data['isFinished']) {
              return const LinearProgressIndicator(
                value: 1,
              );
            } else {
              final value = data['position'] / data['duration'];
              if (value != null && value >= 0 && value <= 1) {
                return LinearProgressIndicator(
                  value: value,
                );
              } else {
                return const LinearProgressIndicator(
                  value: 0,
                );
              }
            }
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
