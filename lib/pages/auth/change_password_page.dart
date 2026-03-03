import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:todolist_app/components/button/td_elevated_button.dart';
import 'package:todolist_app/components/snack_bar/td_snack_bar.dart';
import 'package:todolist_app/components/snack_bar/top_snack_bar.dart';
import 'package:todolist_app/components/text_field/td_text_field_password.dart';
import 'package:todolist_app/gen/assets.gen.dart';
import 'package:todolist_app/pages/auth/login_page.dart';
import 'package:todolist_app/resources/app_color.dart';
import 'package:todolist_app/services/local/shared_prefs.dart';
import 'package:todolist_app/services/remote/auth_services.dart';
import 'package:todolist_app/services/remote/body/change_password_body.dart';
import 'package:todolist_app/services/remote/code_error.dart';
import 'package:todolist_app/utils/validator.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _changePassword(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final body = ChangePasswordBody()
      ..password = newPasswordController.text
      ..oldPassword = currentPasswordController.text;

    authServices
        .changePassword(body)
        .then((response) {
          final data = jsonDecode(response.body);
          if (data['status_code'] == 200) {
            if (!context.mounted) return;
            showTopSnackBar(
              context,
              const TDSnackBar.success(
                message: 'Password has been changed, please login 😍',
              ),
            );
            // setState(() => isLoading = false);
            SharedPrefs.removeSeason();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => LoginPage(email: widget.email),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            dev.log('object message ${data['message']}');
            if (!context.mounted) return;
            showTopSnackBar(
              context,
              TDSnackBar.error(message: (data['message'] as String?).toLang),
            );
            setState(() => isLoading = false);
          }
        })
        .catchError((onError) {
          dev.log('object $onError');
          if (!context.mounted) return;
          showTopSnackBar(
            context,
            const TDSnackBar.error(message: "INTERNET_OR_SERVER"),
          );
          setState(() => isLoading = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
              top: MediaQuery.of(context).padding.top + 38.0,
              bottom: 16.0,
            ),
            children: [
              const Center(
                child: Text(
                  'Change Password',
                  style: TextStyle(color: AppColor.red, fontSize: 24.0),
                ),
              ),
              const SizedBox(height: 32.0),
              Center(
                child: Image.asset(
                  Assets.images.todoIcon.path,
                  width: 90.0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 40.0),
              TdTextFieldPassword(
                controller: currentPasswordController,
                hintText: 'Current Password',
                validator: Validator.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18.0),
              TdTextFieldPassword(
                controller: newPasswordController,
                hintText: 'New Password',
                validator: Validator.password,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18.0),
              TdTextFieldPassword(
                controller: confirmPasswordController,
                onChanged: (_) => setState(() {}),
                hintText: 'Confirm Password',
                validator: Validator.confirmPassword(
                  newPasswordController.text,
                ),
                onFieldSubmitted: (_) => _changePassword(context),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 72.0),
              TdElevatedButton(
                onPressed: () => _changePassword(context),
                text: 'Done',
                isDisable: isLoading,
              ),
              const SizedBox(height: 20.0),
              TdElevatedButton.outline(
                onPressed: () => Navigator.pop(context),
                text: 'Cancel',
                isDisable: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
