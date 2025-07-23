import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoColorMapper extends ColorMapper {
  const LogoColorMapper(this.theme, {this.useThemeColors = true});

  final ThemeData theme;
  final bool useThemeColors;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (useThemeColors) {
      if (color == const Color(0xFF7F9DC4)) {
        return theme.colorScheme.primaryFixedDim;
      }
      if (color == const Color.fromARGB(255, 217, 226, 255)) {
        return theme.colorScheme.secondary;
      }
    }

    if (color == const Color.fromARGB(255, 217, 226, 255) &&
        theme.brightness == Brightness.light) {
      return const Color.fromARGB(255, 66, 100, 144);
    }

    return color;
  }
}

class PrimaryColorMapper extends ColorMapper {
  const PrimaryColorMapper(this.theme);

  final ThemeData theme;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return theme.colorScheme.primary;
  }
}

class TertiaryColorMapper extends ColorMapper {
  const TertiaryColorMapper(this.theme);

  final ThemeData theme;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return theme.colorScheme.tertiary;
  }
}
