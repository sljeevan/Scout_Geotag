import 'package:flutter_test/flutter_test.dart';
import 'package:sitepin_flutter/main.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const SitePinApp());
    expect(find.text('SitePin'), findsOneWidget);
  });
}
