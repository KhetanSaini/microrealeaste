import 'package:flutter/material.dart';

/// A reusable tab section widget for consistent tabbed layouts.
/// Supports custom tab labels, icons, and any widget as tab content.
/// Can manage its own TabController or accept an external one.
class TabbedSection extends StatefulWidget {
  final List<Tab> tabs;
  final List<Widget> children;
  final TabController? controller;
  final ValueChanged<int>? onTabChanged;
  final bool isScrollable;
  final EdgeInsetsGeometry? tabBarPadding;
  final Color? backgroundColor;
  final double? elevation;
  final double? tabBarHeight;

  const TabbedSection({
    Key? key,
    required this.tabs,
    required this.children,
    this.controller,
    this.onTabChanged,
    this.isScrollable = false,
    this.tabBarPadding,
    this.backgroundColor,
    this.elevation,
    this.tabBarHeight,
  })  : assert(tabs.length == children.length, 'Tabs and children must have the same length'),
        super(key: key);

  @override
  State<TabbedSection> createState() => _TabbedSectionState();
}

class _TabbedSectionState extends State<TabbedSection> with TickerProviderStateMixin {
  TabController? _internalController;

  TabController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TabController(length: widget.tabs.length, vsync: this);
      _internalController!.addListener(_handleTabChange);
    } else {
      widget.controller!.addListener(_handleTabChange);
    }
  }

  @override
  void didUpdateWidget(covariant TabbedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && (oldWidget.tabs.length != widget.tabs.length)) {
      _internalController?.dispose();
      _internalController = TabController(length: widget.tabs.length, vsync: this);
      _internalController!.addListener(_handleTabChange);
    }
  }

  @override
  void dispose() {
    if (_internalController != null) {
      _internalController!.removeListener(_handleTabChange);
      _internalController!.dispose();
    } else {
      widget.controller?.removeListener(_handleTabChange);
    }
    super.dispose();
  }

  void _handleTabChange() {
    if (_controller.indexIsChanging) return;
    widget.onTabChanged?.call(_controller.index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Material(
          color: widget.backgroundColor ?? theme.colorScheme.surface,
          elevation: widget.elevation ?? 0,
          child: Padding(
            padding: widget.tabBarPadding ?? const EdgeInsets.symmetric(horizontal: 0),
            child: SizedBox(
              height: widget.tabBarHeight ?? 48,
              child: TabBar(
                controller: _controller,
                tabs: widget.tabs,
                isScrollable: widget.isScrollable,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: widget.children,
          ),
        ),
      ],
    );
  }
} 