import 'package:flutter/material.dart';
import '../constants/custom_color.dart';

class TodoTextStyles {
  textStyles(bool underline, bool color, bool fontweight, double fontsize,
      bool height) {
    return TextStyle(
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
        color: color ? AppColors.backgroundColor : AppColors.whiteColor,
        fontWeight: fontweight ? FontWeight.w500 : FontWeight.w400,
        fontSize: fontsize,
        height: height ? 1.0 : 0.0);
  }
}
