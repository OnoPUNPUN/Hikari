enum ReadingMode { classic, webtoon }

extension ReadingModeExtension on ReadingMode {
  String get displayName {
    switch (this) {
      case ReadingMode.classic:
        return 'Classic';
      case ReadingMode.webtoon:
        return 'Webtoon';
    }
  }

  String get description {
    switch (this) {
      case ReadingMode.classic:
        return 'Horizontal page view';
      case ReadingMode.webtoon:
        return 'Vertical scrolling';
    }
  }
}
