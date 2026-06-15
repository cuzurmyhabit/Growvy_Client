/// 백엔드 DB seed (id ↔ enum/label) 를 한 곳에서 관리한다.
///
/// 모든 회원가입 / 공고 작성 화면은 사용자 선택을 반드시 **id (정수)** 로 보관하고,
/// 화면 표시는 i18nKey 를 통해 번역해서 보여 준다. 그렇게 하면
/// 라벨 문자열(공백/apostrophe/번역) 차이로 백엔드 매핑이 깨지지 않는다.
///
/// 백엔드 seed (id | label | category):
///   1~11   INDUSTRY
///   12~14  ENERGY_STYLE
///   15~17  WORK_ENVIRONMENT
///   18~20  SOCIAL_PREFERENCE
///   21~23  COMFORT_ZONE
///   24~27  MAIN_GOAL
///   28~30  WORK_PACE
///   31~35  EMPLOYMENT
library;

/// `(id, i18nKey, englishLabel)` 단일 옵션.
///
/// - [id] : 백엔드로 그대로 전송될 정수 (DB seed id).
/// - [i18nKey] : 화면 표시용 i18n 키. `i18nKey.tr()` 로 변환.
/// - [englishLabel] : 디버그/로깅 / 캐시 용. 백엔드 매핑에는 사용 X.
class IdOption {
  final int id;
  final String i18nKey;
  final String englishLabel;
  const IdOption(this.id, this.i18nKey, this.englishLabel);
}

/// 백엔드 카테고리 enum (interestId ↔ 카테고리 역매핑에 사용).
/// `dbName` 은 백엔드 DB seed 의 SNAKE_CASE 라벨과 정확히 일치한다.
enum InterestCategory {
  industry('INDUSTRY'),
  energyStyle('ENERGY_STYLE'),
  workEnvironment('WORK_ENVIRONMENT'),
  socialPreference('SOCIAL_PREFERENCE'),
  comfortZone('COMFORT_ZONE'),
  mainGoal('MAIN_GOAL'),
  workPace('WORK_PACE'),
  employment('EMPLOYMENT');

  const InterestCategory(this.dbName);
  final String dbName;
}

/// 회원가입/공고 작성에서 공통으로 쓰는 ID-옵션 카탈로그.
///
/// 추가/수정이 필요하면 백엔드 seed 와 함께 이 파일만 손보면 된다.
class IdCatalog {
  IdCatalog._();

  // ------------------------------------------------------------------
  // INDUSTRY 1~11
  // ------------------------------------------------------------------
  static const List<IdOption> industries = [
    IdOption(1, 'interests.hospitality_fb', 'Hospitality & F&B'),
    IdOption(2, 'interests.retail_sales', 'Retail & Sales'),
    IdOption(3, 'interests.farm_seasonal', 'Farm & Seasonal'),
    IdOption(4, 'interests.manufacturing', 'Manufacturing'),
    IdOption(5, 'interests.factory_work', 'Factory Work'),
    IdOption(6, 'interests.cleaning_facilities', 'Cleaning & Facilities'),
    IdOption(7, 'interests.construction', 'Construction'),
    IdOption(8, 'interests.logistics_moving', 'Logistics & Moving'),
    IdOption(9, 'interests.events_festivals', 'Events & Festivals'),
    IdOption(10, 'interests.customer_service', 'Customer Service'),
    IdOption(11, 'interests.other_jobs', 'Other Jobs'),
  ];

  // ------------------------------------------------------------------
  // EMPLOYMENT 31~35 (공고 작성 화면에서 사용)
  // ------------------------------------------------------------------
  static const List<IdOption> employmentTypes = [
    IdOption(31, 'employment_types.casual', 'Casual'),
    IdOption(32, 'employment_types.part_time', 'Part-time'),
    IdOption(33, 'employment_types.full_time', 'Full-time'),
    IdOption(34, 'employment_types.contract', 'Contract'),
    IdOption(35, 'employment_types.temporary', 'Temporary'),
  ];

  /// id → IdOption 빠른 조회용 lookup table (industries + employmentTypes).
  /// (survey 옵션은 SeekerSurveyPage 안에서만 쓰이므로 여기엔 포함하지 않음)
  static final Map<int, IdOption> _byId = <int, IdOption>{
    for (final o in industries) o.id: o,
    for (final o in employmentTypes) o.id: o,
  };

  /// id → IdOption. 모르면 null.
  static IdOption? byId(int id) => _byId[id];

  /// id → 카테고리. 백엔드 seed 범위를 기반으로 판별.
  static InterestCategory? categoryOf(int id) {
    if (id >= 1 && id <= 11) return InterestCategory.industry;
    if (id >= 12 && id <= 14) return InterestCategory.energyStyle;
    if (id >= 15 && id <= 17) return InterestCategory.workEnvironment;
    if (id >= 18 && id <= 20) return InterestCategory.socialPreference;
    if (id >= 21 && id <= 23) return InterestCategory.comfortZone;
    if (id >= 24 && id <= 27) return InterestCategory.mainGoal;
    if (id >= 28 && id <= 30) return InterestCategory.workPace;
    if (id >= 31 && id <= 35) return InterestCategory.employment;
    return null;
  }
}
