import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Reminds users that sticker price ≠ landed cost and CM/CT must stay labeled.
class EconomicsBanner extends StatelessWidget {
  const EconomicsBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 8 : 12, 16, compact ? 4 : 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.ctTeal.withValues(alpha: 0.14),
              AppTheme.cmAmber.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: compact ? 10 : 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                ),
                child: Icon(
                  Icons.balance_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compare, don’t blend',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      compact
                          ? 'CM = daily guide · CT = live hub offers · shipping differs'
                          : 'Cardmarket trend is a reference (multi-seller shipping). '
                              'CardTrader Zero is a live acquisition signal (one hub shipment). '
                              'Sources stay labeled separately.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
