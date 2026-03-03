import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:todolist_app/components/button/td_elevated_button.dart';
import 'package:todolist_app/components/snack_bar/td_snack_bar.dart';
import 'package:todolist_app/components/snack_bar/top_snack_bar.dart';
import 'package:todolist_app/components/text_field/td_text_field.dart';
import 'package:todolist_app/gen/assets.gen.dart';
import 'package:todolist_app/pages/auth/create_new_password_page.dart';
import 'package:todolist_app/resources/app_color.dart';
import 'package:todolist_app/services/remote/auth_services.dart';
import 'package:todolist_app/services/remote/body/otp_body.dart';
import 'package:todolist_app/services/remote/code_error.dart';
import 'package:todolist_app/utils/validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendOtp(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    authServices
        .sendOtp(OtpBody()..email = emailController.text.trim())
        .then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        dev.log('object code ${data['body']['code']}');
        if (!context.mounted) return;
        showTopSnackBar(
          context,
          const TDSnackBar.success(
              message: 'Otp has been sent, check email 😍'),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                CreateNewPasswordPage(email: emailController.text.trim()),
          ),
        );
      } else {
        dev.log('object message ${data['message']}');
        if (!context.mounted) return;
        showTopSnackBar(
          context,
          TDSnackBar.error(message: (data['message'] as String?).toLang),
        );
      }
    }).catchError((onError) {
      dev.log('object $onError');
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        const TDSnackBar.error(message: "INTERNET_OR_SERVER"),
      );
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0)
                .copyWith(top: MediaQuery.of(context).padding.top + 38.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text('Forgot Password',
                      style: TextStyle(color: AppColor.red, fontSize: 24.0)),
                  const SizedBox(height: 2.0),
                  Text('Enter Your Email',
                      style: TextStyle(
                          color: AppColor.brown.withValues(alpha: 0.8),
                          fontSize: 18.6)),
                  const SizedBox(height: 38.0),
                  Image.asset(
                    Assets.images.todoIcon.path,
                    width: 90.0,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 36.0),
                  TdTextField(
                    controller: emailController,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: AppColor.orange),
                    validator: Validator.email,
                    onFieldSubmitted: (_) => _sendOtp(context),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 68.0),
                  TdElevatedButton.outline(
                    onPressed: () => _sendOtp(context),
                    text: 'Next',
                    isDisable: isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
