import 'package:flutter/material.dart';

/// Safari-style rounded "pill" address bar.
class SafariAddressBar extends StatelessWidget {
  const SafariAddressBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onTap,
    this.isLoading = false,
    this.progress = 0,
    this.trailing,
    this.hintText = 'Search or enter website',
  });

  final TextEditingController controller;
  final void Function(String) onSubmitted;
  final VoidCallback? onTap;
  final bool isLoading;
  final double progress;
  final Widget? trailing;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress > 0 ? progress / 100 : null,
                  color: colors.primary,
                ),
              )
            else
              Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onTap: onTap,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration.collapsed(hintText: hintText),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            // ignore: use_null_aware_elements
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
