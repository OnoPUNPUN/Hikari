class Manga {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final List<String> tags;
  final String status;
  final int? year;
  final String? author;
  final String? artist;

  const Manga({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.tags = const [],
    this.status = 'ongoing',
    this.year,
    this.author,
    this.artist,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    // Check if this is a saved favorite (flat structure) or MangaDx API response
    if (json.containsKey('title') && !json.containsKey('attributes')) {
      // This is a saved favorite with flat structure
      return Manga.fromSavedJson(json);
    }

    // This is a MangaDx API response
    final attributes = json['attributes'] ?? {};
    final relationships = json['relationships'] ?? [];

    String? coverUrl;
    String? author;
    String? artist;

    // Extract cover URL from relationships
    for (var rel in relationships) {
      if (rel['type'] == 'cover_art') {
        final fileName = rel['attributes']?['fileName'];
        if (fileName != null) {
          coverUrl =
              'https://uploads.mangadex.org/covers/${json['id']}/$fileName';
        }
      } else if (rel['type'] == 'author') {
        author = rel['attributes']?['name'];
      } else if (rel['type'] == 'artist') {
        artist = rel['attributes']?['name'];
      }
    }

    return Manga(
      id: json['id'] ?? '',
      title:
          attributes['title']?['en'] ??
          attributes['title']?['ja'] ??
          attributes['title']?.values.first ??
          'Unknown Title',
      description:
          attributes['description']?['en'] ??
          attributes['description']?['ja'] ??
          attributes['description']?.values.first,
      coverUrl: coverUrl,
      tags:
          (attributes['tags'] as List?)
              ?.map(
                (tag) =>
                    tag['attributes']?['name']?['en'] ??
                    tag['attributes']?['name']?.values.first,
              )
              .where((name) => name != null)
              .cast<String>()
              .toList() ??
          [],
      status: attributes['status'] ?? 'ongoing',
      year: attributes['year'],
      author: author,
      artist: artist,
    );
  }

  /// Factory method for deserializing saved favorites (flat JSON structure)
  factory Manga.fromSavedJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      description: json['description'],
      coverUrl: json['coverUrl'],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      status: json['status'] ?? 'ongoing',
      year: json['year'],
      author: json['author'],
      artist: json['artist'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'tags': tags,
      'status': status,
      'year': year,
      'author': author,
      'artist': artist,
    };
  }

  Manga copyWith({
    String? id,
    String? title,
    String? description,
    String? coverUrl,
    List<String>? tags,
    String? status,
    int? year,
    String? author,
    String? artist,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      year: year ?? this.year,
      author: author ?? this.author,
      artist: artist ?? this.artist,
    );
  }
}
