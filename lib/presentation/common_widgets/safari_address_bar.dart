import 'package:flutter/material.dart';

/// Safari-style rounded "pill" address bar.
///
/// While the field has focus it turns into a search box: the lock/progress icon
/// becomes a magnifier and the trailing action becomes "clear". The clear button
/// is driven by a [ValueListenableBuilder] on the controller, so typing rebuilds
/// one icon instead of the whole bar (and never the browser shell around it).
class SafariAddressBar extends StatefulWidget {
  const SafariAddressBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.isLoading = false,
    this.progress = 0,
    this.trailing,
    this.hintText = 'Search or enter website',
  });

  final TextEditingController controller;
  final void Function(String) onSubmitted;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  /// Invoked by the trailing "clear" button while editing.
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool isLoading;
  final double progress;

  /// Action shown when the bar is idle (the bookmark toggle).
  final Widget? trailing;
  final String hintText;

  @override
  State<SafariAddressBar> createState() => _SafariAddressBarState();
}

class _SafariAddressBarState extends State<SafariAddressBar> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChanged);
    _focused = widget.focusNode?.hasFocus ?? false;
  }

  @override
  void didUpdateWidget(SafariAddressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      widget.focusNode?.addListener(_onFocusChanged);
      _focused = widget.focusNode?.hasFocus ?? false;
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    final focused = widget.focusNode?.hasFocus ?? false;
    if (focused == _focused) return;
    setState(() => _focused = focused);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Row(
          children: [
            _leading(colors),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                textInputAction: TextInputAction.go,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration.collapsed(hintText: widget.hintText),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (_focused)
              _ClearButton(
                controller: widget.controller,
                onClear: widget.onClear,
              )
            // ignore: use_null_aware_elements
            else if (widget.trailing != null)
              widget.trailing!,
          ],
        ),
      ),
    );
  }

  Widget _leading(ColorScheme colors) {
    if (_focused) {
      return Icon(Icons.search, size: 15, color: Colors.grey.shade600);
    }
    if (widget.isLoading) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: widget.progress > 0 ? widget.progress / 100 : null,
          color: colors.primary,
        ),
      );
    }
    return Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade600);
  }
}

/// Rebuilds on text changes only for itself (not the enclosing bar).
class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller, this.onClear});

  final TextEditingController controller;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) return const SizedBox(width: 8);
        return ExcludeFocus(
          // Clearing must not blur the field (that would end editing).
          child: IconButton(
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            tooltip: 'Clear',
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        );
      },
    );
  }
}
