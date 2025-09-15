class Chapter {
  final String id;
  final String mangaId;
  final String title;
  final String chapter;
  final String? volume;
  final String? translatedLanguage;
  final String? scanlator;
  final int? pages;
  final DateTime? publishAt;
  final DateTime? readableAt;
  final String? externalUrl;

  const Chapter({
    required this.id,
    required this.mangaId,
    required this.title,
    required this.chapter,
    this.volume,
    this.translatedLanguage,
    this.scanlator,
    this.pages,
    this.publishAt,
    this.readableAt,
    this.externalUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};

    return Chapter(
      id: json['id'] ?? '',
      mangaId:
          json['relationships']?.firstWhere(
            (rel) => rel['type'] == 'manga',
            orElse: () => {'id': ''},
          )['id'] ??
          '',
      title: attributes['title'] ?? 'Chapter ${attributes['chapter'] ?? '0'}',
      chapter: attributes['chapter'] ?? '0',
      volume: attributes['volume'],
      translatedLanguage: attributes['translatedLanguage'],
      scanlator: attributes['scanlator'],
      pages: attributes['pages'],
      publishAt: attributes['publishAt'] != null
          ? DateTime.tryParse(attributes['publishAt'])
          : null,
      readableAt: attributes['readableAt'] != null
          ? DateTime.tryParse(attributes['readableAt'])
          : null,
      externalUrl: attributes['externalUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mangaId': mangaId,
      'title': title,
      'chapter': chapter,
      'volume': volume,
      'translatedLanguage': translatedLanguage,
      'scanlator': scanlator,
      'pages': pages,
      'publishAt': publishAt?.toIso8601String(),
      'readableAt': readableAt?.toIso8601String(),
      'externalUrl': externalUrl,
    };
  }

  String get displayTitle {
    // Format: "Vol.1 Ch.3 - Chapter Name" or "Ch.1 - Chapter Name"
    final volumeText = volume != null ? 'Vol.$volume ' : '';
    final chapterText = 'Ch.$chapter';
    final baseTitle = '$volumeText$chapterText';

    // If there's a meaningful chapter title, add it
    if (title.isNotEmpty && title != 'Chapter $chapter') {
      return '$baseTitle - $title';
    }

    return baseTitle;
  }

  Chapter copyWith({
    String? id,
    String? mangaId,
    String? title,
    String? chapter,
    String? volume,
    String? translatedLanguage,
    String? scanlator,
    int? pages,
    DateTime? publishAt,
    DateTime? readableAt,
    String? externalUrl,
  }) {
    return Chapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      title: title ?? this.title,
      chapter: chapter ?? this.chapter,
      volume: volume ?? this.volume,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      scanlator: scanlator ?? this.scanlator,
      pages: pages ?? this.pages,
      publishAt: publishAt ?? this.publishAt,
      readableAt: readableAt ?? this.readableAt,
      externalUrl: externalUrl ?? this.externalUrl,
    );
  }
}
