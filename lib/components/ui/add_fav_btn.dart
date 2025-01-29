import 'package:flutter/material.dart';
import 'package:poddr/providers/favourites.dart';
import 'package:provider/provider.dart';

class PoddrAddFavBtn extends StatelessWidget {
  final String title;
  final String rss;
  final String description;
  final String author;
  final String image;
  final double size;

  const PoddrAddFavBtn({
    super.key,
    required this.title,
    required this.rss,
    required this.description,
    required this.author,
    required this.image,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final favourites = context.select((FavouritesProvider p) => p.favourites);
    final isFavourite = favourites.any((element) {
      return element['rss'] == rss;
    });

    if (isFavourite) {
      return IconButton(
        icon: Icon(
          Icons.favorite_rounded,
          size: size,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          final favourite = favourites.firstWhere((element) {
            return element['rss'] == rss;
          });
          context.read<FavouritesProvider>().removeFavourite(
                favourite['id'],
              );
        },
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.favorite_border_rounded,
          size: size,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          context.read<FavouritesProvider>().addFavourite(
                title: title,
                rss: rss,
                description: description,
                author: author,
                image: image,
              );
        },
      );
    }
  }
}
