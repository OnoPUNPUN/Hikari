import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_mode.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final readingModeProvider =
    StateNotifierProvider<ReadingModeNotifier, ReadingMode>((ref) {
      return ReadingModeNotifier(ref.read(storageServiceProvider));
    });

class ReadingModeNotifier extends StateNotifier<ReadingMode> {
  final StorageService _storageService;

  ReadingModeNotifier(this._storageService) : super(ReadingMode.classic) {
    _loadReadingMode();
  }

  Future<void> _loadReadingMode() async {
    final readingMode = await _storageService.getReadingMode();
    state = readingMode;
  }

  Future<void> setReadingMode(ReadingMode readingMode) async {
    state = readingMode;
    await _storageService.setReadingMode(readingMode);
  }
}
