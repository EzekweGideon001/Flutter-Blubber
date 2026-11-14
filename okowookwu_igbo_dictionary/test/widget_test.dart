import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:igbo_dictionary/main.dart';
import 'package:igbo_dictionary/views/home_screen.dart';

void main() {
  testWidgets('Branded splash opens the app', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const IgboDictionaryApp());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/icon/splash_screen.png',
      ),
      findsOneWidget,
    );
    expect(find.text('Ọkọwookwu – Igbo Dictionary'), findsOneWidget);
    expect(find.text('Made with IgboAPI'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
