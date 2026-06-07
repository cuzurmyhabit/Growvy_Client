import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/signup_data_controller.dart';

/// 앱 최초 바인딩 (AuthController, SignupDataController 등 전역 의존성)
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    // 회원가입 흐름의 각 단계 입력값을 누적했다가 마지막에 한 번에 서버로 보내기 위한 컨트롤러.
    Get.put<SignupDataController>(SignupDataController(), permanent: true);
  }
}
