import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class WideScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WideScreenAppBar({
    super.key,
    required this.isWideScreen,
    this.title, 
    this.actions,
    this.leading, 
  });

  final bool isWideScreen;
  /// if leading is null, it will be drawer opener button that will be shown only on small screens
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;

  @override
  PreferredSizeWidget build(BuildContext context) {
    bool overrideSize = isWideScreen && settings.get(Setting.showAppOverlay);
    
    final myPreferredSize = Size.fromHeight(overrideSize ? 32 : kToolbarHeight);
    
    return PreferredSize(
      preferredSize: myPreferredSize,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: overrideSize ? true : false,
        child: AppBar(
          title: title,
          leading: isWideScreen ? null : const DrawerButton(onPressed: switchDrawer),
          actions: actions,
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(isWideScreen && settings.get(Setting.showAppOverlay) ? 32 : kToolbarHeight);
}
