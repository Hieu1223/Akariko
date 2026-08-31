import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/tab_model.dart';

/// A single tab card in the Tab Switcher grid.
class TabGridCard extends StatelessWidget {
  const TabGridCard({
    super.key,
    required this.tab,
    required this.onTap,
    required this.onClose,
  });

  final TabModel tab;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: tab.screenshotPath != null && tab.screenshotPath!.isNotEmpty
                    ? Image.file(
                        File(tab.screenshotPath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.language, size: 32, color: Colors.grey),
                      )
                    : const Icon(Icons.language, size: 32, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tab.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          tab.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, color: colors.outline),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
