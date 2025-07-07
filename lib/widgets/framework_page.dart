import 'package:flutter/material.dart';

class FrameworkPage extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final List<Widget> slivers;
  final EdgeInsetsGeometry? padding;
  final bool showAppBar;
  final double appBarHeight;
  final Widget? background;
  final Widget? bottomNavigationBar;

  const FrameworkPage({
    super.key,
    required this.title,
    required this.slivers,
    this.actions,
    this.floatingActionButton,
    this.padding,
    this.showAppBar = true,
    this.appBarHeight = 120,
    this.background,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: CustomScrollView(
        slivers: [
          if (showAppBar)
            SliverAppBar(
              expandedHeight: appBarHeight,
              floating: true,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                background: background ?? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              actions: actions,
            ),
          ...slivers,
        ],
      ),
    );
  }
} 