import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoColorMapper extends ColorMapper {
  const LogoColorMapper(this.theme);

  final ThemeData theme;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == const Color(0xFF7F9DC4)) {
      return theme.colorScheme.primaryFixedDim;
    }
    if (color == const Color(0xFFD0E4FF)) {
      return theme.colorScheme.secondary;
    }
    return color;
  }
}

class BookColorMapper extends ColorMapper {
  const BookColorMapper(this.theme);

  final ThemeData theme;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    final scheme = theme.colorScheme;

    if (color == const Color.fromARGB(255, 255, 0, 0)) {
      return scheme.primary;
    }
    if (color == const Color.fromARGB(255, 0, 0, 255)) {
      return scheme.primaryContainer;
    }
    if (color == const Color.fromARGB(255, 0, 255, 0)) {
      return scheme.tertiaryContainer;
    }
    if (color == const Color.fromARGB(255, 0, 255, 255)) {
      return scheme.tertiary;
    }
    if (color == const Color.fromARGB(255, 255, 0, 255)) {
      return scheme.secondaryContainer;
    }
    return color;
  }
}
