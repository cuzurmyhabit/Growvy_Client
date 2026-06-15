import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'signup_repository.dart';

/// 공고 작성 페이로드를 백엔드로 전송하는 repository.
///
/// 회원가입(`SignupRepository`) 과 동일한 정책:
///   - `API_ENABLED=false` 면 stub 으로 동작 (디버그 로그만)
///   - 짧은 timeout (8초) + try/catch → 백엔드 미응답이어도 throw 하지 않음
///   - 응답 body 가 비어 있으면 빈 map 반환
class JobPostRepository {
  JobPostRepository._();

  /// 회원가입과 같은 ON/OFF 플래그를 공유한다.
  static bool get enabled => SignupRepository.enabled;

  /// 백엔드 endpoint (스펙 확정 시 한 줄만 바꾸면 됨).
  static const String _path = 'jobs';

  /// 공고 페이로드를 POST.
  ///
  /// 반환: 백엔드가 생성한 job JSON (없으면 빈 map).
  static Future<Map<String, dynamic>> submit({
    required Map<String, dynamic> payload,
  }) async {
    if (!enabled) {
      debugPrint('[JobPostRepository] (stub, API_ENABLED=false) payload=$payload');
      return <String, dynamic>{};
    }

    try {
      return await ApiClient.post(_path, body: payload)
          .timeout(const Duration(seconds: 8));
    } on TimeoutException catch (e) {
      debugPrint('[JobPostRepository] backend timeout(8s) → 빈 응답: $e');
      return <String, dynamic>{};
    } on ApiException catch (e) {
      debugPrint('[JobPostRepository] backend unreachable → 빈 응답: $e');
      return <String, dynamic>{};
    } catch (e) {
      debugPrint('[JobPostRepository] unexpected → 빈 응답: $e');
      return <String, dynamic>{};
    }
  }
}
