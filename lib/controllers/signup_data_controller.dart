import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 회원가입 단계마다 사용자가 입력한 값을 한 곳에 누적했다가
/// 마지막 SignupCompletePage 에서 한 번에 서버(DB)로 보낼 수 있게 해 주는 컨트롤러.
///
/// - 현재는 DB 연동 전 단계라서 [submitToBackend] 가 [toPayload] 결과를 그대로
///   `debugPrint` 만 한다. 실제 API 가 준비되면 여기서 `http.post(...)` 로 한 번에
///   전송하면 된다.
/// - 모든 필드는 nullable. 사용자가 한 번도 거치지 않은 단계는 그냥 null/빈 값으로 남는다.
/// - employer / seeker 분기에 따라 [toPayload] 가 반환하는 키가 달라진다.
class SignupDataController extends GetxController {
  static SignupDataController get to => Get.find<SignupDataController>();

  // --------------- Google 로그인 단계 ---------------
  String? googleEmail;
  String? googleDisplayName;
  String? googleUid;
  String? googleIdToken;

  // --------------- 직군 선택 ---------------
  /// true: Employer, false: Job seeker, null: 아직 선택 전
  bool? isEmployer;

  // --------------- 공통 정보 (CommonSignUpPage) ---------------
  String? name;
  String? dateOfBirth; // YYYY/MM/DD 문자열
  String? phoneNumber;
  String? gender; // 'Male' | 'Female' | null

  // --------------- 프로필 ---------------
  String? profileImageAsset;

  // --------------- Employer 전용 (EmployerSignupPage) ---------------
  String? companyName;
  bool? isSoleProprietorship;
  String? businessAddress;

  // --------------- Seeker 전용 ---------------
  String? homeAddress;
  final List<String> interests = <String>[]; // SeekerInterestPage
  final Map<int, int> surveyAnswers = <int, int>{}; // SeekerSurveyPage
  String? career; // SeekerCareerPage
  String? introduction; // SeekerCareerPage

  // ---------------- Setter helpers ----------------

  void setGoogleAuth({
    String? email,
    String? displayName,
    String? uid,
    String? idToken,
  }) {
    if (email != null) googleEmail = email;
    if (displayName != null) googleDisplayName = displayName;
    if (uid != null) googleUid = uid;
    if (idToken != null) googleIdToken = idToken;
  }

  void setUserType(bool employer) {
    isEmployer = employer;
  }

  void setBasicInfo({
    String? name,
    String? dateOfBirth,
    String? phoneNumber,
    String? gender,
  }) {
    if (name != null) this.name = name;
    if (dateOfBirth != null) this.dateOfBirth = dateOfBirth;
    if (phoneNumber != null) this.phoneNumber = phoneNumber;
    if (gender != null) this.gender = gender;
  }

  void setProfileImage(String assetPath) {
    profileImageAsset = assetPath;
  }

  void setEmployerInfo({
    String? companyName,
    bool? isSoleProprietorship,
    String? businessAddress,
  }) {
    if (companyName != null) this.companyName = companyName;
    if (isSoleProprietorship != null) {
      this.isSoleProprietorship = isSoleProprietorship;
    }
    if (businessAddress != null) this.businessAddress = businessAddress;
  }

  void setHomeAddress(String value) {
    homeAddress = value;
  }

  void setInterests(Iterable<String> values) {
    interests
      ..clear()
      ..addAll(values);
  }

  void setSurveyAnswers(Map<int, int> answers) {
    surveyAnswers
      ..clear()
      ..addAll(answers);
  }

  void setCareerInfo({String? career, String? introduction}) {
    if (career != null) this.career = career;
    if (introduction != null) this.introduction = introduction;
  }

  // ---------------- 직렬화 ----------------

  /// DB 로 보낼 최종 payload.
  /// employer / seeker 분기에 따라 키가 달라진다.
  Map<String, dynamic> toPayload() {
    final base = <String, dynamic>{
      'isEmployer': isEmployer,
      'auth': {
        'email': googleEmail,
        'displayName': googleDisplayName,
        'uid': googleUid,
        // idToken 은 백엔드 전송 시에만 쓰고 화면에 남기지 않는 게 안전하지만
        // 모으는 단계이므로 일단 포함한다. (전송 직전에 제거해도 됨)
        'idToken': googleIdToken,
      },
      'profile': {
        'name': name,
        'dateOfBirth': dateOfBirth,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'profileImageAsset': profileImageAsset,
      },
    };
    if (isEmployer == true) {
      base['employer'] = {
        'companyName': companyName,
        'isSoleProprietorship': isSoleProprietorship,
        'businessAddress': businessAddress,
      };
    } else {
      base['seeker'] = {
        'homeAddress': homeAddress,
        'interests': List<String>.from(interests),
        'surveyAnswers': Map<int, int>.from(surveyAnswers),
        'career': career,
        'introduction': introduction,
      };
    }
    return base;
  }

  /// DB 연동 전 단계의 placeholder.
  /// 실제 백엔드가 붙으면 이 메서드 안에서 `http.post(...)` 로 [toPayload] 를 보낸다.
  Future<void> submitToBackend() async {
    final payload = toPayload();
    debugPrint('[SignupDataController] collected payload = $payload');
    // TODO: API 연동 시 여기서 http.post / Dio 사용해 한 번에 전송.
  }

  /// 다음 회원가입 시도를 위해 누적된 값을 초기화한다.
  void reset() {
    googleEmail = null;
    googleDisplayName = null;
    googleUid = null;
    googleIdToken = null;
    isEmployer = null;
    name = null;
    dateOfBirth = null;
    phoneNumber = null;
    gender = null;
    profileImageAsset = null;
    companyName = null;
    isSoleProprietorship = null;
    businessAddress = null;
    homeAddress = null;
    interests.clear();
    surveyAnswers.clear();
    career = null;
    introduction = null;
  }
}
