import 'package:flutter/material.dart';
import 'package:poddr/components/ui/image.dart';
import 'package:provider/provider.dart';
import 'package:poddr/providers/media.dart';

class Artwork extends StatelessWidget {
  const Artwork({super.key});

  @override
  Widget build(BuildContext context) {
    Uri? artUri =
        context.select<MediaProvider, Uri?>((e) => e.mediaItem.value?.artUri);

    return PoddrImage(imageUri: artUri ?? Uri.parse(''));
  }
}
