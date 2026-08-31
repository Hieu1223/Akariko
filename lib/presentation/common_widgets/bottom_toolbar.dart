import 'package:flutter/material.dart';

/// Bottom toolbar: Back / Forward / New Tab / Tabs / Menu.
class BottomToolbar extends StatelessWidget {
  const BottomToolbar({
    super.key,
    required this.onBack,
    required this.onForward,
    required this.onNewTab,
    required this.onTabs,
    required this.onMenu,
    required this.tabCount,
    this.canGoBack = false,
    this.canGoForward = false,
  });

  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onNewTab;
  final VoidCallback onTabs;
  final VoidCallback onMenu;
  final int tabCount;
  final bool canGoBack;
  final bool canGoForward;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ToolButton(
                icon: Icons.arrow_back,
                onPressed: canGoBack ? onBack : null,
              ),
              _ToolButton(
                icon: Icons.arrow_forward,
                onPressed: canGoForward ? onForward : null,
              ),
              _ToolButton(
                icon: Icons.add,
                onPressed: onNewTab,
              ),
              _TabButton(onPressed: onTabs, count: tabCount),
              _ToolButton(
                icon: Icons.more_horiz,
                onPressed: onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, color: onPressed == null ? Colors.grey : null),
        onPressed: onPressed,
      );
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.onPressed, required this.count});
  final VoidCallback onPressed;
  final int count;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Badge.count(
          count: count,
          child: const Icon(Icons.square_outlined),
        ),
        onPressed: onPressed,
      );
}
