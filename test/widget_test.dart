import 'package:flutter_test/flutter_test.dart';

import 'package:card_price_tracker/app/app.dart';

void main() {
  testWidgets('App boots to watchlist shell', (tester) async {
    await tester.pumpWidget(const CardPriceApp());
    await tester.pump(); // start frame
    // Allow first async frame without settling forever (db/streams).
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Watchlist'), findsWidgets);
  });
}
