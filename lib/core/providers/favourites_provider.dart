import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manga.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, List<Manga>>((ref) {
      return FavouritesNotifier(ref.read(storageServiceProvider));
    });

class FavouritesNotifier extends StateNotifier<List<Manga>> {
  final StorageService _storageService;

  FavouritesNotifier(this._storageService) : super([]) {
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    final favourites = await _storageService.getFavourites();
    state = favourites;
  }

  Future<void> addFavourite(Manga manga) async {
    if (!state.any((fav) => fav.id == manga.id)) {
      state = [...state, manga];
      await _storageService.addFavourite(manga);
    }
  }

  Future<void> removeFavourite(String mangaId) async {
    state = state.where((fav) => fav.id != mangaId).toList();
    await _storageService.removeFavourite(mangaId);
  }

  Future<bool> isFavourite(String mangaId) async {
    return await _storageService.isFavourite(mangaId);
  }

  bool isFavouriteSync(String mangaId) {
    return state.any((fav) => fav.id == mangaId);
  }
}
