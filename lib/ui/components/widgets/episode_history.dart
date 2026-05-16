import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/services/history.dart';
import 'package:provider/provider.dart';

class EpisodeHistory extends StatelessWidget {
  final double height;
  final double? width;
  final String audioUrl;

  const EpisodeHistory({
    super.key,
    required this.audioUrl,
    this.height = 6,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: StreamBuilder<ListeningHistoryData?>(
        stream: context.read<HistoryProvider>().watchProgressByAudioUrl(audioUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            if (data.isFinished) {
              return const LinearProgressIndicator(
                value: 1,
              );
            } else {
              final value = data.position / data.duration;
              if (value >= 0 && value <= 1) {
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

class EpisodeHistoryCircle extends StatelessWidget {
  final double? size;
  final String audioUrl;

  const EpisodeHistoryCircle({
    super.key,
    required this.audioUrl,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: StreamBuilder<ListeningHistoryData?>(
        stream: context.read<HistoryProvider>().watchProgressByAudioUrl(audioUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            if (data.isFinished) {
              return CircularProgressIndicator(
                value: 1,
                strokeWidth: size! / 5,
                color: context.theme.primary,
                backgroundColor: context.theme.surface,
              );
            } else {
              final value = data.position / data.duration;
              if (value >= 0 && value <= 1) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: size! / 5,
                  color: context.theme.primary,
                  backgroundColor: context.theme.surface,
                );
              } else {
                return CircularProgressIndicator(
                  value: 0,
                  strokeWidth: size! / 5,
                  color: context.theme.primary,
                  backgroundColor: context.theme.surface,
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
