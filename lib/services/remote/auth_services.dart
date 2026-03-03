import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:todolist_app/constants/app_constant.dart';
import 'package:todolist_app/services/local/shared_prefs.dart';
import 'package:todolist_app/services/remote/body/change_password_body.dart';
import 'package:todolist_app/services/remote/body/login_body.dart';
import 'package:todolist_app/services/remote/body/new_password_body.dart';
import 'package:todolist_app/services/remote/body/otp_body.dart';
import 'package:todolist_app/services/remote/body/register_body.dart';

abstract class ImplAuthServices {
  Future<http.Response> sendOtp(OtpBody body);
  Future<http.Response> register(RegisterBody body);
  Future<http.Response> login(LoginBody body);
  Future<http.Response> postForgotPassword(NewPasswordBody body);
  Future<http.Response> changePassword(ChangePasswordBody body);
}

class AuthServices implements ImplAuthServices {
  static final httpLog = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  @override
  Future<http.Response> sendOtp(OtpBody body) async {
    const url = AppConstant.endPointOtp;

    http.Response response = await httpLog.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }

  @override
  Future<http.Response> register(RegisterBody body) async {
    const url = AppConstant.endPointAuthRegister;

    http.Response response = await httpLog.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }

  @override
  Future<http.Response> login(LoginBody body) async {
    const url = AppConstant.endPointLogin;

    http.Response response = await httpLog.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }

  @override
  Future<http.Response> postForgotPassword(NewPasswordBody body) async {
    const url = AppConstant.endPointForgotPassword;

    http.Response response = await httpLog.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode({
        'email': body.email,
        'password': body.password,
        'code': body.code,
      }),
    );
    return response;
  }

  @override
  Future<http.Response> changePassword(ChangePasswordBody body) async {
    const url = AppConstant.endPointChangePassword;

    http.Response response = await httpLog.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs.token}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }
}
