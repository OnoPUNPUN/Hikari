import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/manga.dart';
import '../../../../core/providers/favourites_provider.dart';

class FavoriteButton extends ConsumerWidget {
  final Manga manga;

  const FavoriteButton({super.key, required this.manga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favouritesProvider);
    final notifier = ref.read(favouritesProvider.notifier);

    final isFav = favorites.any((fav) => fav.id == manga.id);

    return IconButton(
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        if (isFav) {
          notifier.removeFavourite(manga.id);
        } else {
          notifier.addFavourite(manga);
        }
      },
    );
  }
}
