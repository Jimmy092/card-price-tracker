import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/cardtrader_client.dart';
import 'price_format.dart';

class EditLotDraft {
  EditLotDraft({
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

class SellLotDraft {
  SellLotDraft({required this.soldCents, required this.soldAt});
  final int soldCents;
  final DateTime soldAt;
}

Future<EditLotDraft?> showEditLotSheet(
  BuildContext context, {
  required String cardName,
  required int paidCents,
  required DateTime purchasedAt,
  required int quantity,
  bool? foil,
  String? language,
  String? condition,
  String notes = '',
}) {
  return showModalBottomSheet<EditLotDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _EditLotForm(
      cardName: cardName,
      paidCents: paidCents,
      purchasedAt: purchasedAt,
      quantity: quantity,
      foil: foil,
      language: language,
      condition: condition,
      notes: notes,
    ),
  );
}

Future<SellLotDraft?> showSellLotSheet(
  BuildContext context, {
  required String cardName,
  int? suggestedCents,
}) {
  return showModalBottomSheet<SellLotDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _SellLotForm(
      cardName: cardName,
      suggestedCents: suggestedCents,
    ),
  );
}

Future<(int? buy, int? sell)?> showWatchlistTargetsSheet(
  BuildContext context, {
  required String cardName,
  int? targetBuyCents,
  int? targetSellCents,
}) {
  return showModalBottomSheet<(int?, int?)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _TargetsForm(
      cardName: cardName,
      targetBuyCents: targetBuyCents,
      targetSellCents: targetSellCents,
    ),
  );
}

int? _parseEurToCents(String raw) {
  final cleaned = raw.trim().replaceAll('€', '').replaceAll(' ', '');
  if (cleaned.isEmpty) return null;
  final normalized = cleaned.replaceAll(',', '.');
  final value = double.tryParse(normalized);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}

class _EditLotForm extends StatefulWidget {
  const _EditLotForm({
    required this.cardName,
    required this.paidCents,
    required this.purchasedAt,
    required this.quantity,
    this.foil,
    this.language,
    this.condition,
    this.notes = '',
  });

  final String cardName;
  final int paidCents;
  final DateTime purchasedAt;
  final int quantity;
  final bool? foil;
  final String? language;
  final String? condition;
  final String notes;

  @override
  State<_EditLotForm> createState() => _EditLotFormState();
}

class _EditLotFormState extends State<_EditLotForm> {
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
    _paid = TextEditingController(
      text: (widget.paidCents / 100.0).toStringAsFixed(2),
    );
    _qty = TextEditingController(text: '${widget.quantity}');
    _notes = TextEditingController(text: widget.notes);
    _purchasedAt = widget.purchasedAt;
    _foil = widget.foil;
    _language = widget.language;
    _condition = widget.condition;
  }

  @override
  void dispose() {
    _paid.dispose();
    _qty.dispose();
    _notes.dispose();
    super.dispose();
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
      setState(() => _error = 'Enter a valid paid price');
      return;
    }
    final qty = int.tryParse(_qty.text.trim()) ?? 0;
    if (qty < 1) {
      setState(() => _error = 'Quantity must be at least 1');
      return;
    }
    Navigator.of(context).pop(
      EditLotDraft(
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
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit lot', style: Theme.of(context).textTheme.titleLarge),
            Text(widget.cardName),
            const SizedBox(height: 12),
            TextField(
              controller: _paid,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Paid per copy (EUR)',
                prefixText: '€ ',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qty,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      MaterialLocalizations.of(context)
                          .formatMediumDate(_purchasedAt),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                const DropdownMenuItem(value: null, child: Text('Any')),
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
                const DropdownMenuItem(value: null, child: Text('Any')),
                for (final c in CardCondition.values)
                  DropdownMenuItem(value: c.label, child: Text(c.label)),
              ],
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

class _SellLotForm extends StatefulWidget {
  const _SellLotForm({required this.cardName, this.suggestedCents});
  final String cardName;
  final int? suggestedCents;

  @override
  State<_SellLotForm> createState() => _SellLotFormState();
}

class _SellLotFormState extends State<_SellLotForm> {
  late final TextEditingController _sold;
  late DateTime _soldAt;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.suggestedCents;
    _sold = TextEditingController(
      text: s == null ? '' : (s / 100.0).toStringAsFixed(2),
    );
    _soldAt = DateTime.now();
  }

  @override
  void dispose() {
    _sold.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _soldAt,
      firstDate: DateTime(1993),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      _soldAt = DateTime(picked.year, picked.month, picked.day, 12);
    });
  }

  void _submit() {
    final cents = _parseEurToCents(_sold.text);
    if (cents == null) {
      setState(() => _error = 'Enter sale price per copy');
      return;
    }
    Navigator.of(context).pop(SellLotDraft(soldCents: cents, soldAt: _soldAt));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mark sold', style: Theme.of(context).textTheme.titleLarge),
          Text(widget.cardName),
          const SizedBox(height: 12),
          TextField(
            controller: _sold,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: 'Sale price per copy (EUR)',
              prefixText: '€ ',
              helperText: widget.suggestedCents == null
                  ? null
                  : 'Suggested CT: ${formatEurCents(widget.suggestedCents)}',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event),
            label: Text(
              MaterialLocalizations.of(context).formatMediumDate(_soldAt),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('Record sale')),
        ],
      ),
    );
  }
}

class _TargetsForm extends StatefulWidget {
  const _TargetsForm({
    required this.cardName,
    this.targetBuyCents,
    this.targetSellCents,
  });
  final String cardName;
  final int? targetBuyCents;
  final int? targetSellCents;

  @override
  State<_TargetsForm> createState() => _TargetsFormState();
}

class _TargetsFormState extends State<_TargetsForm> {
  late final TextEditingController _buy;
  late final TextEditingController _sell;

  @override
  void initState() {
    super.initState();
    _buy = TextEditingController(
      text: widget.targetBuyCents == null
          ? ''
          : (widget.targetBuyCents! / 100.0).toStringAsFixed(2),
    );
    _sell = TextEditingController(
      text: widget.targetSellCents == null
          ? ''
          : (widget.targetSellCents! / 100.0).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _buy.dispose();
    _sell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Price alerts', style: Theme.of(context).textTheme.titleLarge),
          Text(widget.cardName),
          const SizedBox(height: 8),
          Text(
            'Notify after sync when CT (or CM for sell) crosses a target.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _buy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Buy at or below (EUR)',
              prefixText: '€ ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sell,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Sell at or above (EUR)',
              prefixText: '€ ',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop((
                _parseEurToCents(_buy.text),
                _parseEurToCents(_sell.text),
              ));
            },
            child: const Text('Save targets'),
          ),
        ],
      ),
    );
  }
}
