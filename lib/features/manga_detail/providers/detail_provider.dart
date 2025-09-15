import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/manga.dart';
import '../../../core/models/chapter.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/api_provider.dart';

/// Helper function to process chapters: remove duplicates, filter English-only, sort, handle nulls
List<Chapter> _processChapters(List<Chapter> chapters) {
  print('Processing ${chapters.length} raw chapters');

  // Filter English-only chapters and handle null values
  final filteredChapters = chapters
      .where((chapter) => chapter.translatedLanguage == 'en')
      .where((chapter) => chapter.chapter.isNotEmpty)
      .where((chapter) => chapter.id.isNotEmpty) // Ensure valid ID
      .toList();

  print('After filtering: ${filteredChapters.length} chapters');

  // Remove duplicates based on chapter ID and chapter number
  final uniqueChapters = <String, Chapter>{};
  for (final chapter in filteredChapters) {
    // Use a composite key to avoid duplicates with same chapter number
    final key = '${chapter.volume ?? '0'}_${chapter.chapter}';
    if (!uniqueChapters.containsKey(key)) {
      uniqueChapters[key] = chapter;
    }
  }

  print('After removing duplicates: ${uniqueChapters.length} chapters');

  // Sort by volume and chapter number (ascending order - first to last)
  final sortedChapters = uniqueChapters.values.toList();
  sortedChapters.sort((a, b) {
    // Handle null volumes by treating them as volume 0
    final volumeA = a.volume != null ? double.tryParse(a.volume!) ?? 0.0 : 0.0;
    final volumeB = b.volume != null ? double.tryParse(b.volume!) ?? 0.0 : 0.0;

    // First sort by volume
    if (volumeA != volumeB) {
      return volumeA.compareTo(volumeB);
    }

    // If volumes are equal, sort by chapter number
    final chapterA = double.tryParse(a.chapter) ?? 0.0;
    final chapterB = double.tryParse(b.chapter) ?? 0.0;
    return chapterA.compareTo(chapterB);
  });

  print('Final sorted chapters: ${sortedChapters.length}');
  return sortedChapters;
}

final mangaDetailProvider = FutureProvider.family<Manga, String>((
  ref,
  mangaId,
) async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.getMangaById(mangaId);

  if (response.isSuccess && response.data != null) {
    return response.data!;
  } else {
    throw Exception('Failed to load manga details');
  }
});

final mangaChaptersProvider = FutureProvider.family<List<Chapter>, String>((
  ref,
  mangaId,
) async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.getMangaChapters(mangaId: mangaId);

  if (response.isSuccess && response.hasData) {
    final rawChapters = response.dataList ?? [];
    return _processChapters(rawChapters);
  } else {
    throw Exception('Failed to load chapters');
  }
});

final mangaDetailNotifierProvider =
    StateNotifierProvider.family<MangaDetailNotifier, MangaDetailState, String>(
      (ref, mangaId) {
        return MangaDetailNotifier(ref.read(apiServiceProvider), mangaId);
      },
    );

class MangaDetailState {
  final Manga? manga;
  final List<Chapter> chapters;
  final bool isLoadingManga;
  final bool isLoadingChapters;
  final String? error;

  const MangaDetailState({
    this.manga,
    this.chapters = const [],
    this.isLoadingManga = false,
    this.isLoadingChapters = false,
    this.error,
  });

  MangaDetailState copyWith({
    Manga? manga,
    List<Chapter>? chapters,
    bool? isLoadingManga,
    bool? isLoadingChapters,
    String? error,
  }) {
    return MangaDetailState(
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      isLoadingManga: isLoadingManga ?? this.isLoadingManga,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      error: error,
    );
  }
}

class MangaDetailNotifier extends StateNotifier<MangaDetailState> {
  final ApiService _apiService;
  final String _mangaId;

  MangaDetailNotifier(this._apiService, this._mangaId)
    : super(const MangaDetailState()) {
    loadMangaDetails();
    loadChapters();
  }

  Future<void> loadMangaDetails() async {
    state = state.copyWith(isLoadingManga: true, error: null);

    try {
      final response = await _apiService.getMangaById(_mangaId);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(manga: response.data!, isLoadingManga: false);
      } else {
        state = state.copyWith(
          isLoadingManga: false,
          error: 'Failed to load manga details',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingManga: false,
        error: 'Error loading manga: $e',
      );
    }
  }

  Future<void> loadChapters() async {
    state = state.copyWith(isLoadingChapters: true, error: null);

    try {
      print('Loading chapters for manga: $_mangaId');
      final response = await _apiService.getMangaChapters(mangaId: _mangaId);

      if (response.isSuccess && response.hasData) {
        final rawChapters = response.dataList ?? [];
        print('Received ${rawChapters.length} raw chapters from API');

        if (rawChapters.isEmpty) {
          state = state.copyWith(
            chapters: [],
            isLoadingChapters: false,
            error: 'No chapters available for this manga',
          );
          return;
        }

        final processedChapters = _processChapters(rawChapters);

        if (processedChapters.isEmpty) {
          state = state.copyWith(
            chapters: [],
            isLoadingChapters: false,
            error: 'No English chapters available',
          );
        } else {
          state = state.copyWith(
            chapters: processedChapters,
            isLoadingChapters: false,
          );
        }
      } else {
        state = state.copyWith(
          isLoadingChapters: false,
          error:
              'Failed to load chapters: ${response.message ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error loading chapters for $_mangaId: $e');
      state = state.copyWith(
        isLoadingChapters: false,
        error: 'Error loading chapters: $e',
      );
    }
  }

  void refresh() {
    loadMangaDetails();
    loadChapters();
  }
}
