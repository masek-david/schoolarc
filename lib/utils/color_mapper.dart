import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoColorMapper extends ColorMapper {
  final int primary;
  final int secondaryContainer;
  final int tertiaryContainer;

  const LogoColorMapper({
    required this.primary,
    required this.secondaryContainer,
    required this.tertiaryContainer,
  });

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == const Color(0xFF5185F7)) {
      return Color(primary);
    }
    if (color == const Color(0xFFC5E1FC)) {
      return Color(secondaryContainer);
    }
    if (color == const Color(0xFFA4A6F8)) {
      return Color(tertiaryContainer);
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
