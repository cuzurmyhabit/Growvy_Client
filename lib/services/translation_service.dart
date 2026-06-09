import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

/// 네트워크 기반(비공식 Google Translate endpoint) 자동 번역 서비스.
///
/// - 순수 Dart 패키지(`translator`)만 사용하므로 iOS native 의존성이 없다.
///   → GoogleSignIn 등 네이티브 설정에 전혀 영향을 주지 않는다.
/// - 결과는 (source>target|text) 키로 메모리에 캐시한다.
/// - 동일 키 동시 호출은 하나의 Future 로 합쳐서 중복 호출을 막는다.
/// - [prewarm] 으로 다수의 문자열을 미리 번역 캐시에 채울 수 있다.
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  final GoogleTranslator _translator = GoogleTranslator();

  final Map<String, String> _cache = <String, String>{};
  final Map<String, Future<String>> _inflight = <String, Future<String>>{};

  String _key(String text, String target, String source) =>
      '$source>$target|$text';

  /// 단건 번역. 비어 있거나 source==target 이면 원본 반환.
  Future<String> translate(
    String text, {
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    if (sourceLanguage == targetLanguage) return text;

    final key = _key(trimmed, targetLanguage, sourceLanguage);

    final cached = _cache[key];
    if (cached != null) return cached;

    final pending = _inflight[key];
    if (pending != null) return pending;

    final future = _doTranslate(
      trimmed,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    ).then((result) {
      _cache[key] = result;
      _inflight.remove(key);
      return result;
    }).catchError((Object e, StackTrace _) {
      _inflight.remove(key);
      if (kDebugMode) {
        debugPrint('[TranslationService] failed for "$trimmed": $e');
      }
      return text;
    });

    _inflight[key] = future;
    return future;
  }

  /// 동기 캐시 조회. AutoTranslateText 가 첫 build 에서 깜빡임 없이
  /// 캐시된 번역을 그대로 그려주기 위해 사용한다.
  String? cached(
    String text, {
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    if (sourceLanguage == targetLanguage) return text;
    return _cache[_key(trimmed, targetLanguage, sourceLanguage)];
  }

  /// 여러 문자열을 한 번에 번역해 캐시에 채운다.
  ///
  /// 동시 요청 수는 [concurrency] 로 제한해 비공식 endpoint 의
  /// rate-limit / 일시 차단을 피한다.
  /// [onProgress] 는 (완료수, 전체수) 로 호출된다.
  Future<void> prewarm(
    Iterable<String> texts, {
    required String targetLanguage,
    String sourceLanguage = 'en',
    int concurrency = 6,
    void Function(int done, int total)? onProgress,
  }) async {
    if (sourceLanguage == targetLanguage) {
      onProgress?.call(0, 0);
      return;
    }

    final unique = <String>{
      for (final t in texts)
        if (t.trim().isNotEmpty) t.trim(),
    }.toList();

    final total = unique.length;
    if (total == 0) {
      onProgress?.call(0, 0);
      return;
    }

    var done = 0;
    onProgress?.call(done, total);

    var index = 0;
    Future<void> worker() async {
      while (true) {
        final i = index++;
        if (i >= total) return;
        await translate(
          unique[i],
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
        done++;
        onProgress?.call(done, total);
      }
    }

    final workers = <Future<void>>[
      for (var i = 0; i < concurrency && i < total; i++) worker(),
    ];
    await Future.wait(workers);
  }

  Future<String> _doTranslate(
    String text, {
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final translation = await _translator.translate(
      text,
      from: sourceLanguage,
      to: targetLanguage,
    );
    return translation.text;
  }
}
