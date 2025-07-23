import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolarc/utils/color_mapper.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.message,
    this.asset = 'assets/book.svg',
  });

  final String message;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: SvgPicture.asset(
              asset,
              colorMapper: PrimaryColorMapper(Theme.of(context)),
              height: 200,
            ),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
