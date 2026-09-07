import 'package:flutter_test/flutter_test.dart';
import 'package:carz_mobile/main.dart';

void main() {
  testWidgets('CarZ app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CarZApp());
  });
}
