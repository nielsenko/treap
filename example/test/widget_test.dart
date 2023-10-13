import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo/main.dart';
import 'package:todo/ui/task_tile.dart';

void main() {
  testWidgets('Add task smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byType(TaskTile), findsNothing);

    // Tap the '+' icon and await animation
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(TaskTile), findsOneWidget);
  });
}
