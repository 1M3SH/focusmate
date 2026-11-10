import 'package:flutter/material.dart';
import 'package:focusmate/core/constants/app_colors.dart';
import 'package:focusmate/core/constants/app_constants.dart';

/// Horizontally scrollable chip selector for task categories.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppConstants.defaultCategories
                .asMap()
                .entries
                .map(
                  (entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final selected = value == cat;
                    final color = AppColors
                        .categoryColors[i % AppColors.categoryColors.length];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: selected,
                        selectedColor: color.withOpacity(0.15),
                        checkmarkColor: color,
                        labelStyle: TextStyle(
                          color: selected
                              ? color
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: selected
                              ? color
                              : Theme.of(context).dividerColor,
                        ),
                        onSelected: (v) =>
                            onChanged(v ? cat : null),
                      ),
                    );
                  },
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
