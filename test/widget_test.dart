import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/main.dart';

void main() {
  testWidgets('App basic initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshFarmApp());
    expect(find.byType(FreshFarmApp), findsOneWidget);
  });
}
