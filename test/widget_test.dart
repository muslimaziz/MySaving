import 'package:flutter_test/flutter_test.dart';

import 'package:mysaving/main.dart';
import 'package:mysaving/screens/splash_screen.dart';

void main() {
  testWidgets('App shows SplashScreen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MySavingApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('MySaving'), findsOneWidget);
  });
}
