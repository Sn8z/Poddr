import 'package:flutter/material.dart';

class PoddrStatusMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const PoddrStatusMessage({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer.withAlpha(50)
            : colorScheme.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? colorScheme.error.withAlpha(77)
              : colorScheme.primary.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            size: 18,
            color: isError ? colorScheme.error : colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isError ? colorScheme.error : colorScheme.primary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
