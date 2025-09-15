class ApiResponse<T> {
  final String result;
  final T? data;
  final List<T>? dataList;
  final int? total;
  final int? limit;
  final int? offset;
  final String? message;

  const ApiResponse({
    required this.result,
    this.data,
    this.dataList,
    this.total,
    this.limit,
    this.offset,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    if (json['data'] is List) {
      return ApiResponse<T>(
        result: json['result'] ?? 'ok',
        dataList: (json['data'] as List)
            .map((item) => fromJsonT(item as Map<String, dynamic>))
            .toList(),
        total: json['total'],
        limit: json['limit'],
        offset: json['offset'],
        message: json['message'],
      );
    } else {
      return ApiResponse<T>(
        result: json['result'] ?? 'ok',
        data: json['data'] != null
            ? fromJsonT(json['data'] as Map<String, dynamic>)
            : null,
        total: json['total'],
        limit: json['limit'],
        offset: json['offset'],
        message: json['message'],
      );
    }
  }

  bool get isSuccess => result == 'ok';
  bool get hasData =>
      data != null || (dataList != null && dataList!.isNotEmpty);
}

class ChapterImagesResponse {
  final String baseUrl;
  final String chapterHash;
  final List<String> data;
  final List<String> dataSaver;

  const ChapterImagesResponse({
    required this.baseUrl,
    required this.chapterHash,
    required this.data,
    required this.dataSaver,
  });

  factory ChapterImagesResponse.fromJson(Map<String, dynamic> json) {
    return ChapterImagesResponse(
      baseUrl: json['baseUrl'] ?? '',
      chapterHash: json['chapter']?['hash'] ?? '',
      data: List<String>.from(json['chapter']?['data'] ?? []),
      dataSaver: List<String>.from(json['chapter']?['dataSaver'] ?? []),
    );
  }

  List<String> get imageUrls {
    return data
        .map((fileName) => '$baseUrl/data/$chapterHash/$fileName')
        .toList();
  }

  List<String> get imageUrlsSaver {
    return dataSaver
        .map((fileName) => '$baseUrl/data-saver/$chapterHash/$fileName')
        .toList();
  }
}
