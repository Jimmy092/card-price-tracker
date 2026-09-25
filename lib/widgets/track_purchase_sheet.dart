import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/cardtrader_client.dart';
import '../widgets/price_format.dart';

/// Result of the "add purchase" sheet (EUR cents paid per copy).
class TrackPurchaseDraft {
  TrackPurchaseDraft({
    required this.paidCents,
    required this.purchasedAt,
    required this.quantity,
    required this.foil,
    required this.language,
    required this.condition,
    required this.notes,
  });

  final int paidCents;
  final DateTime purchasedAt;
  final int quantity;
  final bool? foil;
  final String? language;
  final String? condition;
  final String notes;
}

/// Collect what the user paid and the copy attributes for portfolio tracking.
Future<TrackPurchaseDraft?> showTrackPurchaseSheet(
  BuildContext context, {
  required String cardName,
  String? expansion,
  bool? initialFoil,
  String? initialLanguage,
  String? initialCondition,
  int? suggestedPaidCents,
}) {
  return showModalBottomSheet<TrackPurchaseDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _TrackPurchaseForm(
        cardName: cardName,
        expansion: expansion,
        initialFoil: initialFoil,
        initialLanguage: initialLanguage,
        initialCondition: initialCondition,
        suggestedPaidCents: suggestedPaidCents,
      );
    },
  );
}

class _TrackPurchaseForm extends StatefulWidget {
  const _TrackPurchaseForm({
    required this.cardName,
    this.expansion,
    this.initialFoil,
    this.initialLanguage,
    this.initialCondition,
    this.suggestedPaidCents,
  });

  final String cardName;
  final String? expansion;
  final bool? initialFoil;
  final String? initialLanguage;
  final String? initialCondition;
  final int? suggestedPaidCents;

  @override
  State<_TrackPurchaseForm> createState() => _TrackPurchaseFormState();
}

class _TrackPurchaseFormState extends State<_TrackPurchaseForm> {
  late final TextEditingController _paid;
  late final TextEditingController _qty;
  late final TextEditingController _notes;
  late DateTime _purchasedAt;
  late bool? _foil;
  late String? _language;
  late String? _condition;
  String? _error;

  @override
  void initState() {
    super.initState();
    final suggest = widget.suggestedPaidCents;
    _paid = TextEditingController(
      text: suggest == null ? '' : (suggest / 100.0).toStringAsFixed(2),
    );
    _qty = TextEditingController(text: '1');
    _notes = TextEditingController();
    _purchasedAt = DateTime.now();
    _foil = widget.initialFoil;
    _language = widget.initialLanguage;
    _condition = widget.initialCondition;
  }

  @override
  void dispose() {
    _paid.dispose();
    _qty.dispose();
    _notes.dispose();
    super.dispose();
  }

  int? _parseEurToCents(String raw) {
    final cleaned = raw.trim().replaceAll('€', '').replaceAll(' ', '');
    if (cleaned.isEmpty) return null;
    final normalized = cleaned.replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || value < 0) return null;
    return (value * 100).round();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchasedAt,
      firstDate: DateTime(1993),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      _purchasedAt = DateTime(picked.year, picked.month, picked.day, 12);
    });
  }

  void _submit() {
    final cents = _parseEurToCents(_paid.text);
    if (cents == null) {
      setState(() => _error = 'Enter a valid paid price in EUR');
      return;
    }
    final qty = int.tryParse(_qty.text.trim()) ?? 0;
    if (qty < 1) {
      setState(() => _error = 'Quantity must be at least 1');
      return;
    }
    Navigator.of(context).pop(
      TrackPurchaseDraft(
        paidCents: cents,
        purchasedAt: _purchasedAt,
        quantity: qty,
        foil: _foil,
        language: _language,
        condition: _condition,
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Track purchase',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                widget.cardName,
                if (widget.expansion != null && widget.expansion!.isNotEmpty)
                  widget.expansion!,
              ].join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paid,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: 'Paid per copy (EUR)',
                hintText: '12.50',
                prefixText: '€ ',
                helperText: widget.suggestedPaidCents == null
                    ? null
                    : 'Suggested from CT: ${formatEurCents(widget.suggestedPaidCents)}',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qty,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      MaterialLocalizations.of(context).formatMediumDate(
                        _purchasedAt,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Finish', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'any', label: Text('Any')),
                ButtonSegment(value: 'non', label: Text('Non-foil')),
                ButtonSegment(value: 'foil', label: Text('Foil')),
              ],
              selected: {
                _foil == true
                    ? 'foil'
                    : _foil == false
                        ? 'non'
                        : 'any',
              },
              onSelectionChanged: (s) {
                final v = s.first;
                setState(() {
                  _foil = v == 'foil'
                      ? true
                      : v == 'non'
                          ? false
                          : null;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              // ignore: deprecated_member_use
              value: _language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Any / unknown'),
                ),
                for (final o in CardLanguages.options)
                  DropdownMenuItem(value: o.$1, child: Text(o.$2)),
              ],
              onChanged: (v) => setState(() => _language = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              // ignore: deprecated_member_use
              value: _condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Any / unknown'),
                ),
                for (final c in CardCondition.values)
                  DropdownMenuItem(value: c.label, child: Text(c.label)),
              ],
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Seller, order #, …',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Add to Portfolio'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
