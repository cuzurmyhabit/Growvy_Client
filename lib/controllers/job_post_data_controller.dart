import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/job_post_repository.dart';
import '../utils/interest_ids.dart';

/// 공고 작성 흐름(StartHiringPage / EmployerNoteWritePage)에서 사용자가
/// 입력한 값들을 한 곳에 누적했다가, 마지막 Publish 시점에 한 번에 백엔드로
/// 보내는 컨트롤러. 회원가입의 [SignupDataController] 와 동일한 패턴이다.
///
/// [toPayload] 가 반환하는 JSON 은 백엔드 `POST /jobs` 가 그대로 한 행으로
/// insert 할 수 있는 평탄한 Map.
class JobPostDataController extends GetxController {
  static JobPostDataController get to => Get.find<JobPostDataController>();

  // ---------------- Basic Info ----------------
  String? title;

  /// EMPLOYMENT id (31~35).
  int? employmentTypeId;

  /// INDUSTRY id 들 (1~11).
  final Set<int> industryIds = <int>{};

  // ---------------- Job Details ----------------
  String? responsibilities;
  String? shiftDetails;

  /// "DD/MM/YYYY - DD/MM/YYYY" 형식의 화면 표시 문자열.
  String? scheduleDateRange;

  int? numberOfHires;

  /// 0=일, 1=월, ..., 6=토.
  final Set<int> selectedDayIndices = <int>{};

  /// 요일별 시작/종료 시간.
  final Map<int, JobTimeRange> dayTimes = <int, JobTimeRange>{};

  // ---------------- Pay & Benefits ----------------
  String? hourlyRate;
  String? penaltyRate;

  /// 'Paid separately' | 'Included in rate' 등 백엔드 enum.
  String? superannuation;

  // ---------------- Application Settings ----------------
  DateTime? applicationDeadline;

  // ---------------- Photos (선택) ----------------
  final List<String> photoUrls = <String>[];

  // ---------------- Setters ----------------

  void setBasicInfo({
    String? title,
    int? employmentTypeId,
    Iterable<int>? industryIds,
  }) {
    if (title != null) this.title = title;
    if (employmentTypeId != null) this.employmentTypeId = employmentTypeId;
    if (industryIds != null) {
      this.industryIds
        ..clear()
        ..addAll(industryIds);
    }
  }

  void setJobDetails({
    String? responsibilities,
    String? shiftDetails,
    String? scheduleDateRange,
    int? numberOfHires,
    Iterable<int>? selectedDayIndices,
    Map<int, JobTimeRange>? dayTimes,
  }) {
    if (responsibilities != null) this.responsibilities = responsibilities;
    if (shiftDetails != null) this.shiftDetails = shiftDetails;
    if (scheduleDateRange != null) this.scheduleDateRange = scheduleDateRange;
    if (numberOfHires != null) this.numberOfHires = numberOfHires;
    if (selectedDayIndices != null) {
      this.selectedDayIndices
        ..clear()
        ..addAll(selectedDayIndices);
    }
    if (dayTimes != null) {
      this.dayTimes
        ..clear()
        ..addAll(dayTimes);
    }
  }

  void setPayBenefits({
    String? hourlyRate,
    String? penaltyRate,
    String? superannuation,
  }) {
    if (hourlyRate != null) this.hourlyRate = hourlyRate;
    if (penaltyRate != null) this.penaltyRate = penaltyRate;
    if (superannuation != null) this.superannuation = superannuation;
  }

  void setApplicationDeadline(DateTime? value) {
    applicationDeadline = value;
  }

  void setPhotos(Iterable<String> urls) {
    photoUrls
      ..clear()
      ..addAll(urls);
  }

  // ---------------- Validation ----------------

  bool isBasicInfoValid() {
    return (title ?? '').trim().isNotEmpty &&
        employmentTypeId != null &&
        industryIds.isNotEmpty;
  }

  bool isJobDetailsValid() {
    return (responsibilities ?? '').trim().isNotEmpty &&
        (shiftDetails ?? '').trim().isNotEmpty &&
        (scheduleDateRange ?? '').trim().isNotEmpty &&
        (numberOfHires ?? 0) > 0 &&
        selectedDayIndices.isNotEmpty;
  }

  bool isPayBenefitsValid() {
    return (hourlyRate ?? '').trim().isNotEmpty &&
        (penaltyRate ?? '').trim().isNotEmpty &&
        (superannuation ?? '').trim().isNotEmpty;
  }

  bool isReadyForSubmit() {
    return isBasicInfoValid() &&
        isJobDetailsValid() &&
        isPayBenefitsValid() &&
        applicationDeadline != null;
  }

  // ---------------- Serialization ----------------

  /// 백엔드 `POST /jobs` body. 평탄한 구조 + 빈 값은 키 생략.
  Map<String, dynamic> toPayload() {
    final m = <String, dynamic>{};
    void put(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is int && value == 0) return;
      m[key] = value;
    }

    put('title', title?.trim());
    put('employmentTypeId', employmentTypeId);
    if (industryIds.isNotEmpty) {
      m['industryIds'] = (industryIds.toList()..sort());
    }
    put('responsibilities', responsibilities?.trim());
    put('shiftDetails', shiftDetails?.trim());
    put('scheduleDateRange', scheduleDateRange?.trim());
    put('numberOfHires', numberOfHires);
    if (selectedDayIndices.isNotEmpty) {
      m['daysOfWeek'] = (selectedDayIndices.toList()..sort());
    }
    if (dayTimes.isNotEmpty) {
      m['shifts'] = [
        for (final entry in dayTimes.entries)
          {
            'dayIndex': entry.key,
            'fromHour': entry.value.from.hour,
            'fromMinute': entry.value.from.minute,
            'toHour': entry.value.to.hour,
            'toMinute': entry.value.to.minute,
          },
      ];
    }
    put('hourlyRate', hourlyRate?.trim());
    put('penaltyRate', penaltyRate?.trim());
    put('superannuation', superannuation?.trim());
    if (applicationDeadline != null) {
      final d = applicationDeadline!;
      m['applicationDeadline'] =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    if (photoUrls.isNotEmpty) {
      m['photoUrls'] = List<String>.from(photoUrls);
    }
    return m;
  }

  /// [toPayload] 의 alias. 백엔드가 받자마자 DB jobs 테이블 한 행으로
  /// insert 할 수 있는 평탄한 Map 임을 호출 측에 분명히 한다.
  Map<String, dynamic> toDbRow() => toPayload();

  /// 디버그/검증용: 카테고리 라벨로 묶어서 한 줄.
  String describeForDebug() {
    final p = toPayload();
    final keys = p.keys.toList()..sort();
    final empCat = employmentTypeId == null
        ? 'EMPLOYMENT=null'
        : 'EMPLOYMENT=${IdCatalog.byId(employmentTypeId!)?.englishLabel ?? '?'}';
    final industryCats = industryIds
        .map((id) => IdCatalog.byId(id)?.englishLabel ?? '?')
        .join(', ');
    return '[$empCat | INDUSTRY=$industryCats] '
        '${keys.map((k) => '$k=${p[k]}').join(' | ')}';
  }

  /// 누적 페이로드를 한 번에 백엔드로 전송한다.
  /// 응답으로 생성된 job JSON 을 반환 (없으면 빈 map).
  Future<Map<String, dynamic>> submitToBackend() {
    return JobPostRepository.submit(payload: toPayload());
  }

  /// 다음 공고 작성을 위해 누적값 초기화.
  void reset() {
    title = null;
    employmentTypeId = null;
    industryIds.clear();
    responsibilities = null;
    shiftDetails = null;
    scheduleDateRange = null;
    numberOfHires = null;
    selectedDayIndices.clear();
    dayTimes.clear();
    hourlyRate = null;
    penaltyRate = null;
    superannuation = null;
    applicationDeadline = null;
    photoUrls.clear();
  }
}

/// 요일별 근무 시작/종료 시간을 들고 다니는 단순 값 객체.
/// (StartHiringPage 내부의 _TimeRange 와 동일한 의미, 다만 컨트롤러 외부에서도
/// 참조할 수 있도록 public 으로 분리)
class JobTimeRange {
  const JobTimeRange({required this.from, required this.to});
  final TimeOfDay from;
  final TimeOfDay to;
}
