import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/signup_data_controller.dart';
import '../../styles/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/next_button.dart';
import '../../widgets/signin_app_bar.dart';
import 'profile_picker_page.dart';

class SeekerCareerPage extends StatefulWidget {
  const SeekerCareerPage({super.key});

  @override
  State<SeekerCareerPage> createState() => _SeekerCareerPageState();
}

class _SeekerCareerPageState extends State<SeekerCareerPage> {
  late final TextEditingController _careerController;
  late final TextEditingController _introController;

  @override
  void initState() {
    super.initState();
    final data = Get.find<SignupDataController>();
    _careerController = TextEditingController(text: data.career ?? '');
    _introController = TextEditingController(text: data.introduction ?? '');
  }

  @override
  void dispose() {
    _careerController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SignInAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'About you',
                style: TextStyle(
                  color: AppColors.mainColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                controller: _careerController,
                label: 'Career',
                hintText: 'Enter Your Career',
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _introController,
                label: 'One Line Introduction',
                hintText: 'Enter Your Introduction',
              ),

              const SizedBox(height: 48),

              NextButton(
                text: 'Next',
                onPressed: () {
                  // 필수 값이 아니라 그냥 trim 결과만 저장. 빈 문자열도 그대로 들어간다.
                  Get.find<SignupDataController>().setCareerInfo(
                    career: _careerController.text.trim(),
                    introduction: _introController.text.trim(),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePickerPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
