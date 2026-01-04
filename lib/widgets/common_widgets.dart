import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiaryTheme {
  static Color getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.orangeAccent;
      case 'Sad':
        return Colors.blueAccent;
      case 'Excited':
        return Colors.pinkAccent;
      case 'Grateful':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}

class AppSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 4,
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
