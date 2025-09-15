import 'package:dio/dio.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/api_response.dart';

class ApiService {
  static const String _baseUrl = 'https://api.mangadex.org';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  Future<ApiResponse<Manga>> searchManga({
    String? query,
    int limit = 20,
    int offset = 0,
    List<String>? tags,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'includes[]': ['cover_art', 'author', 'artist'],
        'contentRating[]': ['safe', 'suggestive', 'erotica'],
        'order[relevance]': 'desc',
      };

      if (query != null && query.isNotEmpty) {
        queryParams['title'] = query;
      }

      if (tags != null && tags.isNotEmpty) {
        queryParams['includedTags[]'] = tags;
      }

      if (status != null) {
        queryParams['status[]'] = [status];
      }

      final response = await _dio.get('/manga', queryParameters: queryParams);

      return ApiResponse.fromJson(
        response.data,
        (json) => Manga.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to search manga: $e');
    }
  }

  Future<ApiResponse<Manga>> getMangaById(String id) async {
    try {
      final response = await _dio.get(
        '/manga/$id',
        queryParameters: {
          'includes[]': ['cover_art', 'author', 'artist'],
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => Manga.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to get manga: $e');
    }
  }

  Future<ApiResponse<Chapter>> getMangaChapters({
    required String mangaId,
    int limit = 500, // Increased limit to get more chapters
    int offset = 0,
    String language = 'en',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'includes[]': ['scanlation_group', 'user'],
        'translatedLanguage[]': [language],
        'order[volume]': 'asc',
        'order[chapter]': 'asc',
        'contentRating[]': ['safe', 'suggestive', 'erotica'],
      };

      final response = await _dio.get(
        '/manga/$mangaId/feed',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => Chapter.fromJson(json),
      );
    } catch (e) {
      print('Error loading chapters for manga $mangaId: $e');
      throw Exception('Failed to get chapters: $e');
    }
  }

  Future<ChapterImagesResponse> getChapterImages(String chapterId) async {
    try {
      final response = await _dio.get('/at-home/server/$chapterId');
      return ChapterImagesResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get chapter images: $e');
    }
  }

  Future<ApiResponse<Manga>> getPopularManga({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/manga',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'includes[]': ['cover_art', 'author', 'artist'],
          'contentRating[]': ['safe', 'suggestive', 'erotica'],
          'order[followedCount]': 'desc',
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => Manga.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to get popular manga: $e');
    }
  }

  Future<ApiResponse<Manga>> getLatestManga({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/manga',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'includes[]': ['cover_art', 'author', 'artist'],
          'contentRating[]': ['safe', 'suggestive', 'erotica'],
          'order[updatedAt]': 'desc',
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => Manga.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to get latest manga: $e');
    }
  }
}
