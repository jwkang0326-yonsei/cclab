import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_verse_model.dart';
import '../../core/constants/bible_constants.dart';

/// getBible API를 통한 성경 본문 조회 서비스
/// 개역한글(KRV) - Public Domain
class BibleContentService {
  static const String _apiBaseUrl = 'https://api.getbible.net/v2/korean';
  static const String _cachePrefix = 'bible_cache_';

  /// 특정 장의 성경 본문을 조회합니다.
  /// 캐시가 있으면 캐시에서, 없으면 API 호출 후 캐시 저장.
  Future<BibleChapterContent> getChapter({
    required String bookKey,
    required int chapter,
  }) async {
    final bookNumber = BibleConstants.getApiBookNumber(bookKey);
    if (bookNumber == null) {
      throw Exception('알 수 없는 성경 책: $bookKey');
    }

    final cacheKey = '$_cachePrefix${bookKey}_$chapter';

    // 1. 캐시 확인
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return BibleChapterContent.fromJson(json);
      }
    } catch (e) {
      debugPrint('캐시 읽기 실패: $e');
    }

    // 2. API 호출
    final url = '$_apiBaseUrl/$bookNumber/$chapter.json';
    try {
      final response = await _httpGet(url);
      if (response == null) {
        throw Exception('성경 본문을 불러올 수 없습니다.');
      }

      final json = jsonDecode(response) as Map<String, dynamic>;
      final content = BibleChapterContent.fromGetBibleJson(json);

      // 3. 캐시 저장
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(content.toJson()));
      } catch (e) {
        debugPrint('캐시 저장 실패: $e');
      }

      return content;
    } catch (e) {
      throw Exception('성경 본문 로딩 실패: $e');
    }
  }

  /// dart:io HttpClient를 사용한 GET 요청
  Future<String?> _httpGet(String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        return await response.transform(utf8.decoder).join();
      }

      debugPrint('API 응답 오류: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('HTTP 요청 실패: $e');
      rethrow;
    }
  }
}

/// Riverpod Provider
final bibleContentServiceProvider = Provider((ref) => BibleContentService());

/// 챕터 내용을 비동기로 로드하는 FutureProvider
final bibleChapterContentProvider =
    FutureProvider.family<BibleChapterContent, ({String bookKey, int chapter})>(
  (ref, params) async {
    final service = ref.watch(bibleContentServiceProvider);
    return service.getChapter(
      bookKey: params.bookKey,
      chapter: params.chapter,
    );
  },
);
