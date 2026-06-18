import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/utils/fonts.dart';

class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    required this.children,
    required this.heroTag,
    this.child,
    this.actions = const [],
  });

  final String title;
  final String heroTag;
  final List<Widget> children;

  /// If child widget is provided, children is ignored
  ///
  /// child must be scrollable
  final Widget? child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final expandedHeight = 240.0;

    return Scaffold(
      body: NestedScrollView(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child:
                child ??
                ListView(
                  children: children,
                ),
          ),
        ),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              collapsedHeight: kToolbarHeight,
              expandedHeight: expandedHeight,
              pinned: true,
              leading: Align(
                alignment: .center,
                child: IconButtonM3E(
                  onPressed: () => Navigator.pop(context),
                  // TODO bgcol
                  // backgroundColor: context.col.surfaceContainer,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              actions: actions,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final t =
                      (constraints.maxHeight -
                          MediaQuery.paddingOf(context).top -
                          kToolbarHeight) /
                      (expandedHeight - kToolbarHeight);

                  // Interpolate padding between expanded and collapsed
                  final leftPadding = lerpDouble(
                    16,
                    72,
                    1 - t,
                  )!.clamp(0, double.infinity);

                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(
                      left: leftPadding.toDouble(),
                      bottom: 14,
                    ),
                    expandedTitleScale: 1,
                    title: Hero(
                      tag: heroTag,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          title,
                          // lerps between titleLarge (AppBar default) and displayMedium
                          style: googleSansFlex(
                            weight: lerpDouble(400, 700, t),
                            size: lerpDouble(22, 45, t),
                            width: lerpDouble(100, 131, t),
                            letterSpacing: lerpDouble(0, -1.5, t),
                            roundness: 100,
                          ),
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
