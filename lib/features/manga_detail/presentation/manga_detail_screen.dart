import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/manga.dart';
import '../../../core/models/chapter.dart';
import '../../../core/providers/favourites_provider.dart';
import '../providers/detail_provider.dart';
import '../../reader/presentation/reader_screen.dart';

class MangaDetailScreen extends ConsumerWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(mangaDetailNotifierProvider(manga.id));
    final favourites = ref.watch(favouritesProvider);
    final isFavourite = favourites.any((fav) => fav.id == manga.id);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref, isFavourite),
              SliverToBoxAdapter(child: _buildMangaInfo(context, detailState)),
              _buildChaptersList(context, ref, detailState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isFavourite,
  ) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: manga.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: manga.coverUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(Icons.image_not_supported, size: 64),
              ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (isFavourite) {
              ref.read(favouritesProvider.notifier).removeFavourite(manga.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed from favourites')),
              );
            } else {
              ref.read(favouritesProvider.notifier).addFavourite(manga);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favourites')),
              );
            }
          },
          icon: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            color: isFavourite ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMangaInfo(BuildContext context, MangaDetailState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            manga.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 8),

          if (manga.author != null || manga.artist != null) ...[
            Row(
              children: [
                if (manga.author != null) ...[
                  Expanded(
                    child: Text(
                      'Author: ${manga.author}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (manga.artist != null) const SizedBox(width: 16),
                ],
                if (manga.artist != null)
                  Expanded(
                    child: Text(
                      'Artist: ${manga.artist}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (manga.year != null) ...[
            Text(
              'Year: ${manga.year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
          ],

          Text(
            'Status: ${manga.status.toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: manga.status == 'completed'
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          if (manga.description != null) ...[
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              manga.description!,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.fade,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
          ],

          if (manga.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: manga.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          const Divider(),

          Text(
            'Chapters',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildChaptersList(
    BuildContext context,
    WidgetRef ref,
    MangaDetailState state,
  ) {
    if (state.isLoadingChapters) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state.error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
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
                    ref
                        .read(mangaDetailNotifierProvider(manga.id).notifier)
                        .refresh();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.chapters.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.menu_book, size: 64),
                SizedBox(height: 16),
                Text('No chapters available'),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final chapter = state.chapters[index];
        return _ChapterTile(
          chapter: chapter,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReaderScreen(chapter: chapter, manga: manga),
              ),
            );
          },
        );
      }, childCount: state.chapters.length),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterTile({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 4,
      ),
      child: ListTile(
        title: Text(
          chapter.displayTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chapter.scanlator != null) ...[
              Text(
                'by ${chapter.scanlator}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (chapter.pages != null) ...[
              Text(
                '${chapter.pages} pages',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
