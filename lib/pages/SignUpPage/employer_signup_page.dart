import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/signup_data_controller.dart';
import '../../styles/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/next_button.dart';
import '../../widgets/signin_app_bar.dart';
import 'profile_picker_page.dart';

class EmployerSignupPage extends StatefulWidget {
  const EmployerSignupPage({super.key});

  @override
  State<EmployerSignupPage> createState() => _EmployerSignupPageState();
}

class _EmployerSignupPageState extends State<EmployerSignupPage> {
  late final TextEditingController _companyNameController;
  late final TextEditingController _businessAddressController;
  bool isSoleProprietorship = false;

  @override
  void initState() {
    super.initState();
    final data = Get.find<SignupDataController>();
    _companyNameController = TextEditingController(
      text: data.companyName ?? '',
    );
    _businessAddressController = TextEditingController(
      text: data.businessAddress ?? '',
    );
    isSoleProprietorship = data.isSoleProprietorship ?? false;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _businessAddressController.dispose();
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
                controller: _companyNameController,
                label: 'Company Name',
                hintText: 'Enter Company Name',
              ),

              Row(
                children: [
                  Checkbox(
                    value: isSoleProprietorship,
                    onChanged: (val) {
                      setState(() {
                        isSoleProprietorship = val!;
                      });
                    },
                    activeColor: AppColors.subColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: MaterialStateBorderSide.resolveWith(
                      (states) =>
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  const Text('Sole Proprietorship'),
                ],
              ),
              const SizedBox(height: 7),

              CustomTextField(
                controller: _businessAddressController,
                label: '*Business Address',
                hintText: 'Enter Business Address',
              ),

              const SizedBox(height: 24),

              NextButton(
                text: 'Next',
                onPressed: () {
                  Get.find<SignupDataController>().setEmployerInfo(
                    companyName: _companyNameController.text.trim(),
                    isSoleProprietorship: isSoleProprietorship,
                    businessAddress: _businessAddressController.text.trim(),
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
