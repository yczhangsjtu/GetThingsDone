import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_gtd/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(GTDApp());

    expect(find.text("收集箱"), findsNWidgets(2));
    expect(find.text('日历'), findsOneWidget);
    expect(find.text('行动'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pump();

    expect(find.text("收集箱"), findsOneWidget);
    expect(find.text('日历'), findsNWidgets(2));
    expect(find.text('清单'), findsOneWidget);
  });
}
