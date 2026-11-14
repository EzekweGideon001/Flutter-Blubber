import 'package:flutter/material.dart';

class AppStateView extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  final String? message;
  final Widget? action;
  final bool loading;
  final TextStyle? titleStyle;

  const AppStateView({
    super.key,
    required this.title,
    this.icon,
    this.color,
    this.message,
    this.action,
    this.loading = false,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              CircularProgressIndicator(
                color: color ?? theme.colorScheme.onSurfaceVariant,
              )
            else if (icon != null)
              Icon(
                icon,
                size: 64,
                color: color ?? theme.colorScheme.onSurfaceVariant,
              ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle ?? theme.textTheme.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 8), action!],
          ],
        ),
      ),
    );
  }
}
