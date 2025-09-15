import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/manga.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/api_provider.dart';

final homeSearchQueryProvider = StateProvider<String>((ref) => '');
final homeMangaListProvider = StateProvider<List<Manga>>((ref) => []);
final homeLoadingProvider = StateProvider<bool>((ref) => false);
final homeErrorProvider = StateProvider<String?>((ref) => null);

final homeMangaProvider = FutureProvider.family<ApiResponse<Manga>, String>((
  ref,
  query,
) async {
  final apiService = ref.read(apiServiceProvider);

  if (query.isEmpty) {
    return await apiService.getPopularManga();
  } else {
    return await apiService.searchManga(query: query);
  }
});

final homeMangaNotifierProvider =
    StateNotifierProvider<HomeMangaNotifier, HomeMangaState>((ref) {
      return HomeMangaNotifier(ref.read(apiServiceProvider));
    });

class HomeMangaState {
  final List<Manga> mangaList;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final bool hasMore;
  final int currentOffset;

  const HomeMangaState({
    this.mangaList = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.hasMore = true,
    this.currentOffset = 0,
  });

  HomeMangaState copyWith({
    List<Manga>? mangaList,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool? hasMore,
    int? currentOffset,
  }) {
    return HomeMangaState(
      mangaList: mangaList ?? this.mangaList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

class HomeMangaNotifier extends StateNotifier<HomeMangaState> {
  final ApiService _apiService;

  HomeMangaNotifier(this._apiService) : super(const HomeMangaState()) {
    loadPopularManga();
  }

  Future<void> loadPopularManga() async {
    state = state.copyWith(isLoading: true, error: null, searchQuery: '');

    try {
      final response = await _apiService.getPopularManga();

      if (response.isSuccess && response.hasData) {
        state = state.copyWith(
          mangaList: response.dataList ?? [],
          isLoading: false,
          hasMore: (response.dataList?.length ?? 0) >= 20,
          currentOffset: 20,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load popular manga',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading manga: $e',
      );
    }
  }

  Future<void> searchManga(String query) async {
    if (query == state.searchQuery) return;

    state = state.copyWith(isLoading: true, error: null, searchQuery: query);

    try {
      final response = await _apiService.searchManga(query: query);

      if (response.isSuccess && response.hasData) {
        state = state.copyWith(
          mangaList: response.dataList ?? [],
          isLoading: false,
          hasMore: (response.dataList?.length ?? 0) >= 20,
          currentOffset: 20,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No manga found for "$query"',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error searching manga: $e',
      );
    }
  }

  Future<void> loadMoreManga() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = state.searchQuery.isEmpty
          ? await _apiService.getPopularManga(offset: state.currentOffset)
          : await _apiService.searchManga(
              query: state.searchQuery,
              offset: state.currentOffset,
            );

      if (response.isSuccess && response.hasData) {
        final newMangaList = response.dataList ?? [];
        state = state.copyWith(
          mangaList: [...state.mangaList, ...newMangaList],
          isLoading: false,
          hasMore: newMangaList.length >= 20,
          currentOffset: state.currentOffset + 20,
        );
      } else {
        state = state.copyWith(isLoading: false, hasMore: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading more manga: $e',
      );
    }
  }

  void clearSearch() {
    loadPopularManga();
  }
}
