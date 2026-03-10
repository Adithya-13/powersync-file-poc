import 'package:flutter_test/flutter_test.dart';

import 'package:powersync_file_poc/main.dart';

void main() {
  testWidgets('App renders landing text', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('PowerSync POC'), findsOneWidget);
  });
}
