import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';

class Destination {
  Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  Widget icon;
  Widget selectedIcon;
  String label;
}

class FloatingTabBar extends StatefulWidget {
  const FloatingTabBar({
    super.key,
    required this.controller,
    required this.destinations,
    required this.onFabTap,
  });

  final TabController controller;
  final List<Destination> destinations;
  final Future<void> Function(int page) onFabTap;

  @override
  State<FloatingTabBar> createState() => _FloatingTabBarState();
}

class _FloatingTabBarState extends State<FloatingTabBar> {
  final spacing = 4.0;
  final width = 280.0;
  final height = 56.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[6],
              borderRadius: BorderRadius.circular(1000),
              color: context.col.surfaceContainer,
            ),
            child: TabBar(
              controller: widget.controller,
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsetsGeometry.all(4),
              indicator: BoxDecoration(
                color: context.col.secondaryContainer,
                borderRadius: BorderRadius.circular(1000),
              ),
              tabs: List.generate(
                widget.destinations.length,
                (index) {
                  final destination = widget.destinations[index];

                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            iconTheme: IconThemeData(
                              size: 22,
                              color: context.col.onSecondaryContainer,
                            ),
                          ),
                          child: destination.icon,
                        ),
                        Expanded(
                          child: Text(
                            textAlign: TextAlign.center,
                            destination.label,
                            style: context.txt.labelMedium?.copyWith(
                              color: context.col.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          WebRequestFocus(
            onPressed: () => widget.onFabTap(widget.controller.index),
            child: FloatingActionButton(
              child: const Icon(Icons.add_rounded),
              onPressed: () => widget.onFabTap(widget.controller.index),
            ),
          ),
        ],
      ),
    );
  }
}
