import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'language_picker_page.dart';

/// 스플레시 화면. 구글 로그인 화면과 동일한 레이아웃(배경 + 로고)에서 버튼만 제외.
/// 표시 후 곧장 [LanguagePickerPage] 로 이동한다.
///
/// 새 흐름: Splash → LanguagePicker → Welcome → SignUp(Google) → SignIn.
/// 언어를 가장 먼저 골라야 이후 모든 화면이 선택한 언어로 빌드된다.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Color _mainColor = Color(0xFFFC6340);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 로고가 잠깐 보이도록 딜레이만 둔다.
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (_, _, _) => const LanguagePickerPage(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainColor,
      body: SafeArea(
        child: Center(
          child: SvgPicture.asset('assets/icon/logo_white.svg', width: 228),
        ),
      ),
    );
  }
}
