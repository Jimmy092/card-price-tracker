import 'package:flutter/material.dart';

/// Reminds users that sticker price ≠ landed cost and CM/CT must stay labeled.
class EconomicsBanner extends StatelessWidget {
  const EconomicsBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: compact ? 8 : 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                compact
                    ? 'CM = guide trend (multi-seller shipping). CT Zero = single outbound from hub. Never blended.'
                    : 'Cardmarket trend is a reference — shipping is per seller. '
                        'CardTrader Zero mins are a better acquisition signal (one hub shipment). '
                        'Sources are never blended into one price.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
