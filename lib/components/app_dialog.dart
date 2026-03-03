import 'package:flutter/material.dart';
import 'package:todolist_app/components/button/td_elevated_button.dart';
import 'package:todolist_app/resources/app_color.dart';

class AppDialog {
  AppDialog._();

  static void dialog(
    BuildContext context, {
    Widget? title,
    required String content,
    Function()? action,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: title,
        content: Text(
          content,
          style: const TextStyle(color: AppColor.brown, fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TdElevatedButton.smallOutline(
                onPressed: () {
                  action?.call();
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                text: 'Yes',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: TdElevatedButton.smallOutline(
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  text: 'No',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
