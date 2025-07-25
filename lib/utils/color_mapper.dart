import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoColorMapper extends ColorMapper {
  final int primaryFixedDimColor;
  final int secondaryColor;
  final bool isDark;
  final bool useThemeColors;

  const LogoColorMapper({
    required this.primaryFixedDimColor,
    required this.secondaryColor,
    required this.isDark,
    this.useThemeColors = true,
  });

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (useThemeColors) {
      if (color == const Color(0xFF7F9DC4)) {
        return Color(primaryFixedDimColor);
      }
      if (color == const Color.fromARGB(255, 217, 226, 255)) {
        return Color(secondaryColor);
      }
    }

    if (color.toARGB32() ==
            const Color.fromARGB(255, 217, 226, 255).toARGB32() &&
        isDark == false) {
      return const Color.fromARGB(255, 66, 100, 144);
    }

    return color;
  }
}

class BasicColorMapper extends ColorMapper {
  const BasicColorMapper(this.mappedColor);

  final int mappedColor;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return Color(mappedColor);
  }
}