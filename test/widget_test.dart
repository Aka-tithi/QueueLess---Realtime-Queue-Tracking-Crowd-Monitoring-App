import 'package:flutter_test/flutter_test.dart';
import 'package:queueless/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QueueLessApp());
  });
}
