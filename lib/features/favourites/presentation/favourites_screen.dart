import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/manga.dart';
import '../../../core/providers/favourites_provider.dart';
import '../../manga_detail/presentation/manga_detail_screen.dart';
import 'widgets/favourite_manga_card.dart';
import 'widgets/favourites_empty_state.dart';
import 'widgets/favourites_dialogs.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        elevation: 0,
        actions: [
          if (favourites.isNotEmpty)
            IconButton(
              onPressed: () => FavouritesDialogs.showClearAllDialog(
                context,
                ref,
                favourites,
              ),
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all favourites',
            ),
        ],
      ),
      body: favourites.isEmpty
          ? const FavouritesEmptyState()
          : _buildFavouritesList(context, ref, favourites),
    );
  }

  Widget _buildFavouritesList(
    BuildContext context,
    WidgetRef ref,
    List<Manga> favourites,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh favourites from storage
        ref.invalidate(favouritesProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favourites.length,
        itemBuilder: (context, index) {
          final manga = favourites[index];
          return FavouriteMangaCard(
            manga: manga,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaDetailScreen(manga: manga),
                ),
              );
            },
            onRemove: () {
              ref.read(favouritesProvider.notifier).removeFavourite(manga.id);
              FavouritesDialogs.showRemoveSnackBar(context, ref, manga);
            },
          );
        },
      ),
    );
  }
}
