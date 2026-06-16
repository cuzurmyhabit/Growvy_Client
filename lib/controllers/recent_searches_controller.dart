import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자가 입력한 최근 검색어를 앱 전역에서 single source-of-truth 로 관리.
///
/// SearchPage(별도 전체 페이지) / SearchOverlay(메인 위 오버레이) 두 곳이
/// 모두 이 컨트롤러를 구독하므로, 한쪽에서 'ㅇㅇ' 을 검색해 두면 다른 쪽에서도
/// 동일하게 칩이 노출된다. 메인으로 나갔다가 다시 검색 화면을 열어도 그대로
/// 유지되며, SharedPreferences 로 디스크에 저장되어 앱 재실행 후에도 살아남는다.
class RecentSearchesController extends GetxController {
  static RecentSearchesController get to => Get.find<RecentSearchesController>();

  static const String _prefsKey = 'recent_searches_v1';
  static const int _maxLength = 20;

  /// 디자인 시안에 맞춰 처음 한 번만 채워주는 시드 더미.
  /// 사용자가 검색을 한 번이라도 한 뒤(또는 직접 모두 지운 뒤)부터는
  /// 시드를 다시 채우지 않는다.
  static const List<String> _seed = [
    'Farm work',
    'Farm',
    'Cafe',
    'Cafe staff',
    'Hotel staff',
    'Hotel',
    'Warehouse',
  ];

  /// UI 에서 `Obx(() => …)` 로 구독해 그리는 관찰 가능 리스트.
  final RxList<String> recents = <String>[].obs;

  bool _loaded = false;

  @override
  void onInit() {
    super.onInit();
    _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey);
      if (saved == null) {
        // 첫 실행: 시드 더미를 채워둔다.
        recents.assignAll(_seed);
        await prefs.setStringList(_prefsKey, _seed);
      } else {
        recents.assignAll(saved);
      }
    } catch (_) {
      // 디스크 접근 실패 시에도 UI 는 동작해야 하므로 in-memory 시드만 채움.
      recents.assignAll(_seed);
    } finally {
      _loaded = true;
    }
  }

  Future<void> _save() async {
    if (!_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, recents.toList());
    } catch (_) {
      // 저장 실패는 무시 — 다음 변경 시 다시 시도.
    }
  }

  /// 새 검색어를 맨 위에 추가. 같은 단어(대소문자 무시) 가 있으면 위로 끌어올림.
  /// 최대 [_maxLength] 개까지만 유지.
  void add(String raw) {
    final term = raw.trim();
    if (term.isEmpty) return;
    recents.removeWhere(
      (existing) => existing.toLowerCase() == term.toLowerCase(),
    );
    recents.insert(0, term);
    if (recents.length > _maxLength) {
      recents.removeRange(_maxLength, recents.length);
    }
    _save();
  }

  /// 특정 칩의 X 아이콘으로 한 건 삭제.
  void remove(String term) {
    final removed = recents.remove(term);
    if (!removed) {
      // 대소문자 차이로 안 지워졌을 경우 한 번 더 시도.
      recents.removeWhere(
        (existing) => existing.toLowerCase() == term.toLowerCase(),
      );
    }
    _save();
  }

  /// "delete all" 텍스트 버튼.
  void clearAll() {
    recents.clear();
    _save();
  }
}
