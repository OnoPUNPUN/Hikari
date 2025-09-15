import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/manga.dart';
import '../../../core/providers/favourites_provider.dart';
import '../providers/home_provider.dart';
import '../../manga_detail/presentation/manga_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(homeMangaNotifierProvider.notifier).loadMoreManga();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeMangaNotifierProvider);
    final favourites = ref.watch(favouritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hikari'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search manga...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(homeMangaNotifierProvider.notifier)
                              .clearSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  ref
                      .read(homeMangaNotifierProvider.notifier)
                      .searchManga(query.trim());
                }
              },
            ),
          ),
        ),
      ),
      body: _buildBody(homeState, favourites),
    );
  }

  Widget _buildBody(HomeMangaState state, List<Manga> favourites) {
    if (state.isLoading && state.mangaList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.mangaList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(homeMangaNotifierProvider.notifier).loadPopularManga();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.mangaList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64),
            SizedBox(height: 16),
            Text('No manga found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (state.searchQuery.isEmpty) {
          ref.read(homeMangaNotifierProvider.notifier).loadPopularManga();
        } else {
          ref
              .read(homeMangaNotifierProvider.notifier)
              .searchManga(state.searchQuery);
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.mangaList.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.mangaList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final manga = state.mangaList[index];
          final isFavourite = favourites.any((fav) => fav.id == manga.id);

          return _MangaCard(
            manga: manga,
            isFavourite: isFavourite,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaDetailScreen(manga: manga),
                ),
              );
            },
            onFavouriteToggle: () {
              if (isFavourite) {
                ref.read(favouritesProvider.notifier).removeFavourite(manga.id);
              } else {
                ref.read(favouritesProvider.notifier).addFavourite(manga);
              }
            },
          );
        },
      ),
    );
  }
}

class _MangaCard extends StatelessWidget {
  final Manga manga;
  final bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onFavouriteToggle;

  const _MangaCard({
    required this.manga,
    required this.isFavourite,
    required this.onTap,
    required this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image with fixed width to prevent overflow
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: manga.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: manga.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Manga details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (manga.author != null) ...[
                      Text(
                        'by ${manga.author}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (manga.description != null) ...[
                      Text(
                        manga.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Tags
                    if (manga.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: manga.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Favourite button
              IconButton(
                onPressed: onFavouriteToggle,
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: isFavourite ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
