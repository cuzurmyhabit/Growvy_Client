import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import '../../controllers/signup_data_controller.dart';
import '../../styles/colors.dart';
import '../../widgets/signup_button.dart';
import '../../widgets/signin_app_bar.dart';
import 'common_signup_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SignInAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'signup.are_you'.tr(),
              style: const TextStyle(
                color: AppColors.mainColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            SignUpButton(
              text: 'signup.employer'.tr(),
              onPressed: () {
                Get.find<SignupDataController>().setUserType(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CommonSignUpPage(isEmployer: true),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SignUpButton(
              text: 'signup.job_seeker'.tr(),
              onPressed: () {
                Get.find<SignupDataController>().setUserType(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CommonSignUpPage(isEmployer: false),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}