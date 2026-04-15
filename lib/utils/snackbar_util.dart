import 'package:flutter/material.dart';

class SnackbarUtil {

  static void showInfo(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
      }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  static void showSuccess(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
      }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  static void showError(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
      }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  static void _showSnackbar(
      BuildContext context, {
        required String message,
        required Color backgroundColor,
        required IconData icon,
        required Duration duration,
      }) {

    final media = MediaQuery.of(context);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,

      margin: EdgeInsets.fromLTRB(
        media.size.width * 0.5,
        media.padding.top + 10,
        16,
        media.size.height - 100,
      ),

      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}