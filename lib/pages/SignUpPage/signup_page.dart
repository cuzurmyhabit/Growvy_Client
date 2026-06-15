import '../../i18n/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart' hide Trans;
import '../../controllers/signup_data_controller.dart';
import '../../services/auth_repository.dart';
import '../../services/token_storage.dart';
import 'signin_page.dart';
import '../MainPage/main_page.dart'; // 💡 메인 페이지 import 추가 (경로는 프로젝트 구조에 맞게 확인해주세요)

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const Color mainColor = Color(0xFFFC6340);

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// 로그인 중복 클릭 방지 + 로딩 인디케이터 토글.
  bool _isLoggingIn = false;

  /// 구글 계정으로 로그인 → Firebase 인증 → 분기 처리(MainPage or SignInPage) 진입.
  Future<void> _signInWithGoogle() async {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 사용자가 모달을 닫음

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await userCredential.user!.getIdToken();

      debugPrint('[SignUp] Firebase UID: ${userCredential.user?.uid}');
      debugPrint(
        '[SignUp] Firebase ID Token length: ${firebaseIdToken?.length ?? 0}',
      );

      final signupData = Get.find<SignupDataController>();
      signupData.reset();
      signupData.setGoogleAuth(
        email: userCredential.user?.email,
        displayName: userCredential.user?.displayName,
        uid: userCredential.user?.uid,
        idToken: firebaseIdToken,
      );

      bool isRegistered = false; // 💡 가입 여부를 담을 변수 추가

      // API 호출하여 Firebase 토큰 전달 및 자체 토큰 발급, 가입 여부 확인
      if (firebaseIdToken != null && firebaseIdToken.isNotEmpty) {
        await TokenStorage.saveFirebaseIdToken(firebaseIdToken);
        // 수정한 repository 메서드에서 가입 여부(true/false)를 반환받음
        isRegistered = await AuthRepository.exchangeFirebaseTokenForAccess(
          firebaseIdToken,
        );
      }

      if (!mounted) return;

      // 💡 가입 여부에 따른 페이지 이동 분기 처리
      if (isRegistered) {
        // 🟢 기존 회원이면 MainPage 로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainPage(), // 메인 페이지 클래스명에 맞게 수정
          ),
        );
      } else {
        // 🟡 신규 회원이면 추가 정보 입력(SignInPage) 로 이동
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (_, _, _) => const SignInPage(),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } catch (e) {
      debugPrint('[SignUp] Google login error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('signup.google_login_failed'.tr())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  SvgPicture.asset('assets/icon/logo_white.svg', width: 228),

                  const Spacer(),

                  Center(
                    child: SizedBox(
                      width: 318,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoggingIn ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black54,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          disabledBackgroundColor: Colors.white,
                          disabledForegroundColor: Colors.black54,
                        ),
                        child: _isLoggingIn
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: mainColor,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/google_logo.svg',
                                    height: 27,
                                  ),
                                  Text(
                                    'signup.continue_with_google'.tr(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFB2B2B2),
                                    ),
                                  ),
                                  const SizedBox(width: 27),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),

            if (_isLoggingIn)
              const Positioned.fill(child: AbsorbPointer(absorbing: true)),
          ],
        ),
      ),
    );
  }
}
