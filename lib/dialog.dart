import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wechat/contant.dart';

class Dialogs {
  static void showSnakcbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: primaryColor.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showProgresbar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Container(
          width: 80,
          height: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
            colors: const [
              Colors.green,
              Colors.red,
              Colors.black
            ],
            strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line

          ),
        ),
      ),
    );
  }
}
