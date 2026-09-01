// ignore_for_file: unused_element_parameter

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/m3e/m3e_motion_curves.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/double_extension.dart';

const _collapsedWidth = 96.0;

sealed class NavigationRailItem {}

class NavigationPrimaryDestination implements NavigationRailItem {
  const NavigationPrimaryDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.showBadge = false,
  });

  final Widget label;
  final Widget icon;
  final Widget? selectedIcon;
  final bool showBadge;
}

class NavigationSecondaryDestination implements NavigationRailItem {
  const NavigationSecondaryDestination({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final Widget label;
  final Widget icon;
  final void Function() onPressed;
  final bool showBadge;
}

class NavigationHeader implements NavigationRailItem {
  const NavigationHeader({
    required this.label,
  });

  final Widget label;
}

class NavigationRailScaffold extends StatefulWidget {
  const NavigationRailScaffold({
    super.key,
    required this.child,
    required this.pageIndex,
    required this.onTap,
    required this.destinations,
  });

  final Widget child;
  final int pageIndex;
  final void Function({required int newScreenIndex}) onTap;
  final List<NavigationRailItem> destinations;

  @override
  State<NavigationRailScaffold> createState() => _NavigationRailScaffoldState();
}

class _NavigationRailScaffoldState extends State<NavigationRailScaffold>
    with TickerProviderStateMixin {
  late final _spatialController = AnimationController(
    vsync: this,
    value: 0,
    lowerBound: -1,
    upperBound: 2,
  );
  late final _effectsController = AnimationController(vsync: this);
  final _scrollController = ScrollController();

  bool expanded = false;
  bool modal = true;

  void switchExpanded({bool onlyClose = false}) {
    expanded = !expanded;
    if (onlyClose) {
      expanded = false;
    }
    if (!expanded) {
      _scrollController.animateTo(
        0,
        duration: SpatialMotion.defaultMotion.duration,
        curve: SpatialMotion.defaultMotion.curve,
      );
    }
    _spatialController.animateWith(
      SpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 1,
          stiffness: 380,
          ratio: 0.8,
        ),
        _spatialController.value,
        expanded ? 1 : 0,
        0,
        snapToEnd: true,
      ),
    );
    _effectsController.animateWith(
      SpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 1,
          stiffness: 1600,
          ratio: 1,
        ),
        _spatialController.value,
        expanded ? 1 : 0,
        0,
        snapToEnd: true,
      ),
    );
  }

  @override
  void dispose() {
    _spatialController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late bool showTopButtonBadge = false;
    for (final destination in widget.destinations) {
      if (destination is NavigationSecondaryDestination) {
        if (destination.showBadge) {
          showTopButtonBadge = true;
          break;
        }
      }
    }

    return Material(
      color: context.col.surfaceContainer,
      child: AnimatedBuilder(
        animation: _spatialController,
        builder: (context, child) {
          return Stack(
            children: [
              Padding(padding: const .only(left: 96), child: child!),
              IgnorePointer(
                ignoring: !expanded,
                child: GestureDetector(
                  onTapDown: (details) => switchExpanded(onlyClose: true),
                  child: Container(
                    color: context.col.scrim.withValues(
                      alpha: 0.4 * _effectsController.value,
                    ),
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                width: 96 + _spatialController.value * (220 - 96),
                decoration: BoxDecoration(
                  borderRadius: .horizontal(right: const .circular(16)),
                  color: context.col.surfaceContainer,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: (_collapsedWidth - 48) / 2,
                      ),
                      child: _NavigationRailExpandButton(
                        showBadge: showTopButtonBadge && !expanded,
                        spatialAnim: _spatialController.value,
                        effectsAnim: _effectsController.value,
                        onPressed: switchExpanded,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(
                          context,
                        ).copyWith(scrollbars: false),
                        child: ListView.builder(
                          physics: expanded
                              ? null
                              : const NeverScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: widget.destinations.length,
                          itemBuilder: (context, index) {
                            switch (widget.destinations[index]) {
                              case NavigationPrimaryDestination e:
                                return _NavigationRailPrimaryButton(
                                  spatialAnim: _spatialController.value,
                                  effectsAnim: _effectsController.value,
                                  destination: e,
                                  onTap: () =>
                                      widget.onTap(newScreenIndex: index),
                                  selected: widget.pageIndex == index,
                                );
                              case NavigationHeader e:
                                return _NavigationRailHeader(
                                  header: e,
                                  spatialAnim: _spatialController.value,
                                  effectsAnim: _effectsController.value,
                                );
                              case NavigationSecondaryDestination e:
                                return _NavigationRailSecondaryButton(
                                  spatialAnim: _spatialController.value,
                                  effectsAnim: _effectsController.value,
                                  destination: e,
                                );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        child: Padding(
          padding: const EdgeInsetsGeometry.fromLTRB(0, 12, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(12),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Material(
  //     color: context.col.surfaceContainer,
  //     child: AnimatedBuilder(
  //       animation: _spatialController,
  //       builder: (context, child) {
  //         return Row(
  //           children: [
  //             Container(
  //               height: double.infinity,
  //               width: 96 + _spatialController.value * (220 - 96),
  //               color: context.col.surfaceContainer,
  //               child: Column(
  //                 crossAxisAlignment: .start,
  //                 children: [
  //                   const SizedBox(height: 16),
  //                   Padding(
  //                     padding: const EdgeInsets.only(
  //                       left: (_collapsedWidth - 48) / 2,
  //                     ),
  //                     child: _NavigationRailExpandButton(
  //                       spatialAnim: _spatialController.value,
  //                       effectsAnim: _effectsController.value,
  //                       onPressed: switchExpanded,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 20),
  //                   Expanded(
  //                     child: ListView.builder(
  //                       itemCount: widget.destinations.length,
  //                       itemBuilder: (context, index) {
  //                         switch (widget.destinations[index]) {
  //                           case NavigationPrimaryDestination e:
  //                             return _NavigationRailPrimaryButton(
  //                               spatialAnim: _spatialController.value,
  //                               effectsAnim: _effectsController.value,
  //                               destination: e,
  //                               onTap: () =>
  //                                   widget.onTap(newScreenIndex: index),
  //                               selected: widget.pageIndex == index,
  //                             );
  //                           case NavigationHeader e:
  //                             return _NavigationRailHeader(
  //                               header: e,
  //                               spatialAnim: _spatialController.value,
  //                               effectsAnim: _effectsController.value,
  //                             );
  //                           case NavigationSecondaryDestination e:
  //                             return _NavigationRailSecondaryButton(
  //                               spatialAnim: _spatialController.value,
  //                               effectsAnim: _effectsController.value,
  //                               destination: e,
  //                             );
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Expanded(child: child!),
  //           ],
  //         );
  //       },
  //       child: Padding(
  //         padding: const EdgeInsetsGeometry.fromLTRB(0, 12, 12, 12),
  //         child: ClipRRect(
  //           borderRadius: BorderRadiusGeometry.circular(12),
  //           child: widget.child,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class _NavigationRailExpandButton extends StatelessWidget {
  const _NavigationRailExpandButton({
    super.key,
    required this.onPressed,
    required this.spatialAnim,
    required this.effectsAnim,
    required this.showBadge,
  });

  final double spatialAnim;
  final double effectsAnim;
  final bool showBadge;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: showBadge,
      child: IconButton(
        style: const ButtonStyle(
          splashFactory: NewInkSparkle.splashFactory,
        ),
        onPressed: onPressed,
        icon: Transform.rotate(
          angle: 3.1428 * (1 + spatialAnim),
          child: Stack(
            children: [
              Opacity(
                opacity: effectsAnim.flipProgress,
                child: const Icon(Icons.menu_rounded),
              ),
              Opacity(
                opacity: effectsAnim,
                child: const Icon(Icons.menu_open_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationRailHeader extends StatelessWidget {
  const _NavigationRailHeader({
    super.key,
    required this.header,
    required this.spatialAnim,
    required this.effectsAnim,
  });

  final NavigationHeader header;
  final double spatialAnim;
  final double effectsAnim;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: ((effectsAnim * 4) - 3).clamp(0, 1),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12 + 24 * spatialAnim, 12, 16, 0),
        child: SizedBox(
          height: 36,
          child: Align(
            alignment: .centerLeft,
            child: DefaultTextStyle(
              style: context.txt.labelLarge!.copyWith(
                color: context.col.onSurfaceVariant,
              ),
              child: header.label,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationRailPrimaryButton extends StatelessWidget {
  const _NavigationRailPrimaryButton({
    super.key,
    required this.selected,
    required this.onTap,
    required this.destination,
    required this.spatialAnim,
    required this.effectsAnim,
  });

  final bool selected;
  final double spatialAnim;
  final double effectsAnim;
  final NavigationPrimaryDestination destination;
  final void Function() onTap;

  static const _collapsedIndicatorWidth = 56.0;
  static const _collapsedIndicatorHeight = 32.0;
  static const _expandedIndicatorHeight = 56.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final col = context.col;

    final expandedTxt = context.txt.labelLarge ?? const TextStyle(fontSize: 14);

    return Semantics(
      button: true,
      child: _InputPadding(
        minSize: const Size(double.infinity, 0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            SizedBox(height: effectsAnim.flipProgress * 6),
            Container(
              margin: const .only(
                left: (_collapsedWidth - _collapsedIndicatorWidth) / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: .circular(100),
                color: selected ? col.secondaryContainer : null,
              ),
              height:
                  _collapsedIndicatorHeight +
                  effectsAnim *
                      (_expandedIndicatorHeight - _collapsedIndicatorHeight),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: .circular(100),
                  splashFactory: NewInkSparkle.splashFactory,
                  onTap: onTap,
                  child: Padding(
                    padding: const .symmetric(
                      horizontal: (_collapsedIndicatorWidth - _iconSize) / 2,
                    ),
                    child: Stack(
                      alignment: .centerLeft,
                      children: [
                        Badge(
                          isLabelVisible: destination.showBadge,
                          child: IconTheme(
                            data:
                                IconTheme.of(
                                  context,
                                ).copyWith(
                                  size: _iconSize,
                                  color: selected
                                      ? context.col.onSecondaryContainer
                                      : context.col.onSurfaceVariant,
                                ),
                            child:
                                (selected
                                    ? destination.selectedIcon
                                    : destination.icon) ??
                                destination.icon,
                          ),
                        ),
                        Align(
                          widthFactor: effectsAnim,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 8 + spatialAnim * _iconSize,
                            ),
                            child: Opacity(
                              opacity: ((effectsAnim * 4) - 3).clamp(0, 1),
                              child: DefaultTextStyle(
                                textAlign: .start,
                                style: expandedTxt.copyWith(
                                  color: selected
                                      ? col.onSecondaryContainer
                                      : col.onSurfaceVariant,
                                ),
                                child: destination.label,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 88,
              child: Align(
                heightFactor: effectsAnim.flipProgress,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                  child: Center(
                    child: Opacity(
                      opacity: effectsAnim.flipProgress,
                      child: DefaultTextStyle(
                        textAlign: .center,
                        style: context.txt.labelMedium!.copyWith(
                          color: selected
                              ? col.secondary
                              : col.onSurfaceVariant,
                        ),
                        child: destination.label,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationRailSecondaryButton extends StatelessWidget {
  const _NavigationRailSecondaryButton({
    super.key,
    required this.destination,
    required this.spatialAnim,
    required this.effectsAnim,
  });

  final double spatialAnim;
  final double effectsAnim;
  final NavigationSecondaryDestination destination;

  static const _collapsedIndicatorWidth = 56.0;
  static const _expandedIndicatorHeight = 56.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final col = context.col;

    final expandedTxt = context.txt.labelLarge ?? const TextStyle(fontSize: 14);

    return Semantics(
      button: true,
      child: _InputPadding(
        minSize: const Size(double.infinity, 0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Container(
              margin: const .only(
                left: (_collapsedWidth - _collapsedIndicatorWidth) / 2,
              ),
              height: _expandedIndicatorHeight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: .circular(100),
                  splashFactory: NewInkSparkle.splashFactory,
                  onTap: effectsAnim == 0 ? null : destination.onPressed,
                  child: Padding(
                    padding: const .symmetric(
                      horizontal: (_collapsedIndicatorWidth - _iconSize) / 2,
                    ),
                    child: Stack(
                      alignment: .centerLeft,
                      children: [
                        Opacity(
                          opacity: effectsAnim,
                          child: Badge(
                            isLabelVisible: destination.showBadge,
                            child: IconTheme(
                              data: IconTheme.of(context).copyWith(
                                size: _iconSize,
                                color: context.col.onSurfaceVariant,
                              ),
                              child: destination.icon,
                            ),
                          ),
                        ),
                        Align(
                          widthFactor: effectsAnim,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 8 + spatialAnim * _iconSize,
                            ),
                            child: Opacity(
                              opacity: ((effectsAnim * 4) - 3).clamp(0, 1),
                              child: DefaultTextStyle(
                                textAlign: .start,
                                style: expandedTxt.copyWith(
                                  color: col.onSurfaceVariant,
                                ),
                                child: destination.label,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Copied from button_style_button.dart
///
/// A widget to pad the area around a [ButtonStyleButton]'s inner [Material].
///
/// Redirect taps that occur in the padded area around the child to the center
/// of the child. This increases the size of the button and the button's
/// "tap target", but not its material or its ink splashes.
class _InputPadding extends SingleChildRenderObjectWidget {
  const _InputPadding({super.child, required this.minSize});

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderInputPadding renderObject,
  ) {
    renderObject.minSize = minSize;
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, [RenderBox? child]) : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) {
      return;
    }
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize.width);
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicHeight(width), minSize.height);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize.width);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize.height);
    }
    return 0.0;
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
  }) {
    if (child != null) {
      final Size childSize = layoutChild(child!, constraints);
      final double width = math.max(childSize.width, minSize.width);
      final double height = math.max(childSize.height, minSize.height);
      return constraints.constrain(Size(width, height));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final RenderBox? child = this.child;
    if (child == null) {
      return null;
    }
    final double? result = child.getDryBaseline(constraints, baseline);
    if (result == null) {
      return null;
    }
    final Size childSize = child.getDryLayout(constraints);
    return result +
        Alignment.center
            .alongOffset(getDryLayout(constraints) - childSize as Offset)
            .dy;
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    if (child != null) {
      final childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = Alignment.center.alongOffset(
        size - child!.size as Offset,
      );
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Removed so it works even when the childs width is infinite
    // if (super.hitTest(result, position: position)) {
    //   return true;
    // }

    // added y offset because when not expanded, the inkwell is more up
    final Offset center = child!.size.center(const Offset(0, -10));
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == center);
        return child!.hitTest(result, position: center);
      },
    );
  }
}
