import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/models/manga.dart';

class FavouriteMangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavouriteMangaCard({
    super.key,
    required this.manga,
    required this.onTap,
    required this.onRemove,
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
              _buildCoverImage(context),
              const SizedBox(width: 12),
              _buildMangaDetails(context),
              _buildRemoveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        height: 120,
        child: manga.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: manga.coverUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported),
                ),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported),
              ),
      ),
    );
  }

  Widget _buildMangaDetails(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 4),
          if (manga.author != null) ...[
            _buildAuthor(context),
            const SizedBox(height: 4),
          ],
          if (manga.description != null) ...[
            _buildDescription(context),
            const SizedBox(height: 8),
          ],
          _buildStatusAndYear(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      manga.title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthor(BuildContext context) {
    return Text(
      'by ${manga.author}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      manga.description!,
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusAndYear(BuildContext context) {
    return Row(
      children: [
        _buildStatusBadge(context),
        if (manga.year != null) ...[
          const SizedBox(width: 8),
          _buildYearText(context),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: manga.status == 'completed'
            ? Colors.green
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        manga.status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: manga.status == 'completed'
              ? Colors.white
              : Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildYearText(BuildContext context) {
    return Text(
      '${manga.year}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return IconButton(
      onPressed: onRemove,
      icon: const Icon(Icons.favorite, color: Colors.red),
      tooltip: 'Remove from favourites',
    );
  }
}
