import 'package:flutter/material.dart';
import 'package:focusmate/core/constants/app_colors.dart';

/// Three-option priority selector (Low / Medium / High).
class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  static const _options = [
    (label: 'Low', value: 0, color: AppColors.priorityLow),
    (label: 'Medium', value: 1, color: AppColors.priorityMedium),
    (label: 'High', value: 2, color: AppColors.priorityHigh),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: _options.map((opt) {
            final selected = value == opt.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(opt.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? opt.color.withOpacity(0.12)
                          : Theme.of(context)
                              .colorScheme
                              .surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? opt.color
                            : Theme.of(context).dividerColor,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        opt.label,
                        style: TextStyle(
                          color: selected
                              ? opt.color
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
