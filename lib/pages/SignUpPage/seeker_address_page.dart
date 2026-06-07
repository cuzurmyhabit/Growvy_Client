import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/signup_data_controller.dart';
import '../../styles/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/next_button.dart';
import '../../widgets/signin_app_bar.dart';
import 'seeker_interest_page.dart';

class SeekerAddressPage extends StatefulWidget {
  const SeekerAddressPage({super.key});

  @override
  State<SeekerAddressPage> createState() => _SeekerAddressPageState();
}

class _SeekerAddressPageState extends State<SeekerAddressPage> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: Get.find<SignupDataController>().homeAddress ?? '',
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SignInAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              const SizedBox(height: 34),

              CustomTextField(
                controller: _addressController,
                label: '*Home Address',
                hintText: 'Enter Home Address',
              ),

              const SizedBox(height: 24),

              NextButton(
                text: 'Next',
                onPressed: () {
                  Get.find<SignupDataController>().setHomeAddress(
                    _addressController.text.trim(),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeekerInterestPage(),
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
