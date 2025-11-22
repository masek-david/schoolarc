import 'dart:async';
import 'dart:math';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:m3_expressive_shapes/shapes/_shapes.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/shapes_list.dart';
import 'package:schoolarc/widgets/subject_shortcut.dart';
import 'package:schoolarc/widgets/tiles/animated_checkbox.dart';
import 'package:schoolarc/widgets/tiles/tile_slidable.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';

class HwTile extends StatefulWidget {
  const HwTile({
    super.key,
    required this.hw,
    this.showDate = true,
    this.showCompletion = true,
    this.showBorderIfMissed = true,
    this.slidableController,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
    required this.onConvert,
    this.draggable = false,
  });

  final Homework hw;
  final bool showDate;
  final SlidableController? slidableController;
  final bool showCompletion;
  final bool draggable;
  final bool showBorderIfMissed;
  final void Function(bool)? onChangedCompletion;
  final void Function()? onDelete;
  final void Function() onEdit;
  final void Function()? onConvert;

  @override
  State<HwTile> createState() => _HwTileState();
}

class _HwTileState extends State<HwTile> with TickerProviderStateMixin {
  static const double borderRadius = 12;
  static const double padding = 5;

  final wholeDuration = const Duration(milliseconds: 1200);
  final scaleDuration = const Duration(milliseconds: 600);

  /// during animation is always active, determines the rotation of the cookie
  ///
  /// elasticOut curve
  late final _rotationController =
      AnimationController(vsync: this, duration: wholeDuration);

  /// active only on the begining and ending of the animation, determines the scale of the whole checkbox
  ///
  /// elasticOut curve
  late final _scaleController =
      AnimationController(vsync: this, duration: scaleDuration);
  Timer? _returnAnimationTimer;

  RoundedPolygon shape = MaterialShapes.cookie12;

  @override
  void dispose() {
    try {
      _rotationController.dispose();
      _scaleController.dispose();
    } on Object {
      // somehow, sometimes the controllers are already disposed
    }
    super.dispose();
  }

  void animate(bool value) {
    if (_scaleController.value > 0) {
      _returnAnimationTimer?.cancel();
      _scaleController.animateTo(0, curve: Curves.elasticOut);
    }

    if (value) {
      shape = symetricShapes[Random().nextInt(symetricShapes.length)];
      _rotationController.value = 0;
      _rotationController.animateTo(1, curve: Curves.decelerate);
      _scaleController.animateTo(1, curve: Curves.elasticOut);

      _returnAnimationTimer = Timer(
          wholeDuration - scaleDuration + const Duration(milliseconds: 300),
          () {
        if (!mounted) return;
        _scaleController.animateTo(0, curve: Curves.elasticOut);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hw.isBeingAnimated && !_rotationController.isAnimating) {
      animate(true);
    }

    return widget.draggable
        ? LayoutBuilder(
            builder: (context, constraints) {
              return LongPressDraggable(
                data: widget.hw,
                onDragStarted: () => HapticFeedback.mediumImpact(),
                feedback: SizedBox(
                  width: constraints.maxWidth,
                  child: Opacity(
                    opacity: 0.6,
                    child: buildTile(),
                  ),
                ),
                child: buildTile(),
              );
            },
          )
        : buildTile();
  }

  Widget buildTile() {
    final bool isMissed =
        widget.hw.isCompleted == false && widget.hw.date.isBefore(Date.today());
    final missedColor = isMissed
        ? Colors.red.harmonizeWith(Theme.of(context).primaryColor)
        : null;

    final opacity =
        widget.hw.isCompleted && !widget.hw.isBeingAnimated ? 0.5 : 1.0;
    final backgroundColor = widget.hw.isCompleted && !widget.hw.isBeingAnimated
        ? Theme.of(context).colorScheme.surfaceContainerLowest
        : Theme.of(context).colorScheme.surfaceContainerLow;

    return ClipRRect(
      child: TileSlidable(
        isHomework: true,
        slidableController: widget.slidableController,
        onDelete: widget.onDelete,
        onConvert: widget.onConvert,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: isMissed && widget.showBorderIfMissed
                ? Border.all(
                    color: missedColor!,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            color: backgroundColor,
          ),
          child: WebRequestFocus(
            offset: true,
            onPressed: () async => widget.onEdit(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: widget.onEdit,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: const EdgeInsets.all(padding),
                    // main row
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (settings.get(Setting.debugMode))
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.hw.stateReaddingVersion.toString()),
                              Text(widget.hw.order.toString()),
                              if (widget.hw.isBeingAnimated)
                                const Icon(
                                  Icons.animation,
                                  size: 15,
                                )
                            ],
                          ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(borderRadius - padding),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          child: SubjectShortcut(subject: widget.hw.subject),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // if (widget.hw.isShared)
                            //   Icon(
                            //     Icons.share,
                            //     size: 16,
                            //     color: Theme.of(context)
                            //         .colorScheme
                            //         .onSurfaceVariant,
                            //   ),
                            if (widget.hw.description != '')
                              Icon(
                                Icons.notes,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          ],
                        ),
                        // if (widget.hw.description != '' || widget.hw.isShared)
                        if (widget.hw.description != '')
                          const SizedBox(width: 8),
                        Expanded(child: Text(widget.hw.text, maxLines: 2)),
                        const SizedBox(width: 5),
                        if (widget.showDate)
                          Text(
                            widget.hw.date.formatWithText(),
                            maxLines: 2,
                            style: TextStyle(
                              color: isMissed ? missedColor : null,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(width: 4),
                        if (widget.showCompletion)
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return AnimatedCheckbox(
                                value: widget.hw.isCompleted,
                                priority: widget.hw.priority,
                                shape: shape,
                                onChanged: widget.onChangedCompletion == null
                                    ? (value) {}
                                    : (value) {
                                        HapticFeedback.vibrate();
                                        if (widget.onChangedCompletion !=
                                            null) {
                                          widget.onChangedCompletion!(value);
                                        }
                                        animate(value);
                                      },
                                rotation: _rotationController.value,
                                scale: _scaleController.value,
                              );
                            },
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}