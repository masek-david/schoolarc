import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/textstyle_extension.dart';

class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    required this.children,
    required this.heroTag,
    this.actions = const [],
  });

  final String title;
  final String heroTag;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            children: children,
          ),
        ),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              collapsedHeight: kToolbarHeight,
              expandedHeight: 200,
              pinned: true,
              actions: actions,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final t = (constraints.maxHeight -
                          MediaQuery.paddingOf(context).top -
                          kToolbarHeight) /
                      (200 - kToolbarHeight);

                  // Interpolate padding between expanded and collapsed
                  final leftPadding =
                      lerpDouble(16, 72, 1 - t)!.clamp(0, double.infinity);

                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(
                        left: leftPadding.toDouble(), bottom: lerpDouble(14, 0, t)!),
                    expandedTitleScale: 1,
                    title: Hero(
                      tag: heroTag,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          style: context.txt.titleLarge!.copyWithNunito(
                            weight: 700,
                            size: lerpDouble(22, 44, t),
                          ),
                          title,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ];
        },
      ),
    );
  }
}
