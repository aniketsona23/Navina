import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

/// Common scaffold wrapper for all screens
class AppScaffold extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final double? elevation;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.backgroundColor,
    this.appBarColor,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = true,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appBarColor ?? AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: centerTitle,
        elevation: elevation,
        leading: leading ?? (showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            )
          : null),
        actions: actions,
      ),
      body: body,
    );
  }
}

/// Scaffold for assist screens with specific styling
class AssistScaffold extends StatelessWidget {
  final String title;
  final Color assistColor;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;

  const AssistScaffold({
    super.key,
    required this.title,
    required this.assistColor,
    required this.body,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      appBarColor: assistColor,
      body: body,
      actions: actions,
      leading: leading,
    );
  }
}
