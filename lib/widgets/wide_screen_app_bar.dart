import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/main_app.dart';

class WideScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WideScreenAppBar({
    super.key,
    required this.isWideScreen,
    this.backgroundColor,
    this.title,
    this.actions,
    this.leading,
  });

  final bool isWideScreen;
  final Color? backgroundColor;

  /// if leading is null, it will be drawer opener button that will be shown only on small screens
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;

  @override
  PreferredSizeWidget build(BuildContext context) {
    bool overrideSize = isWideScreen;

    return PreferredSize(
      preferredSize: preferredSize,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: overrideSize ? true : false,
        child: AppBar(
          backgroundColor: backgroundColor,
          title: title,
          leading:
              isWideScreen ? null : const DrawerButton(onPressed: openDrawer),
          actions: actions,
        ),
      ),
    );
  }

// TODO why is this for web?? check this and arrows for page switching
  @override
  Size get preferredSize =>
      Size.fromHeight(isWideScreen && !kIsWeb ? 32 : kToolbarHeight);
}
