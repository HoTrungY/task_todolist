import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:todolist_app/components/button/td_elevated_button.dart';
import 'package:todolist_app/components/snack_bar/td_snack_bar.dart';
import 'package:todolist_app/components/snack_bar/top_snack_bar.dart';
import 'package:todolist_app/components/text_field/td_text_field.dart';
import 'package:todolist_app/components/text_field/td_text_field_password.dart';
import 'package:todolist_app/gen/assets.gen.dart';
import 'package:todolist_app/pages/auth/forgot_password_page.dart';
import 'package:todolist_app/pages/auth/register_page.dart';
import 'package:todolist_app/pages/main_page.dart';
import 'package:todolist_app/resources/app_color.dart';
import 'package:todolist_app/services/local/shared_prefs.dart';
import 'package:todolist_app/services/remote/auth_services.dart';
import 'package:todolist_app/services/remote/body/login_body.dart';
import 'package:todolist_app/services/remote/code_error.dart';
import 'package:todolist_app/utils/validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.email});

  final String? email;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthServices authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email ?? '';
  }

  Future<void> _submitLogin(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    LoginBody body = LoginBody()
      ..email = emailController.text.trim()
      ..password = passwordController.text;

    authServices.login(body).then((response) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        final token = data['body']['token'];
        SharedPrefs.token = token;
        dev.log('object token $token');
        // setState(() => isLoading = false);
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainPage(
              title: 'Tasks',
            ),
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
    }).catchError((onError) {
      dev.log('object $onError');
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        const TDSnackBar.error(message: 'INTERNET_OR_SERVER'),
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
                top: MediaQuery.of(context).padding.top + 38.0, bottom: 16.0),
            children: [
              const Center(
                child: Text(
                  'Sign in',
                  style: TextStyle(color: AppColor.red, fontSize: 26.0),
                ),
              ),
              const SizedBox(height: 32.0),
              Center(
                child: Image.asset(Assets.images.todoIcon.path,
                    width: 90.0, fit: BoxFit.cover),
              ),
              const SizedBox(height: 36.0),
              TdTextField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.orange),
                validator: Validator.email,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20.0),
              TdTextFieldPassword(
                controller: passwordController,
                hintText: 'Password',
                validator: Validator.password,
                onFieldSubmitted: (_) => _submitLogin(context),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    )),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: AppColor.red, fontSize: 16.0),
                    ),
                  ),
                  const Text(
                    ' | ',
                    style: TextStyle(color: AppColor.orange, fontSize: 16.0),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    )),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColor.brown, fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60.0),
              TdElevatedButton(
                onPressed: () => _submitLogin(context),
                text: 'Sign in',
                isDisable: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
