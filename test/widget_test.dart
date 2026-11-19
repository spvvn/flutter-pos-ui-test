import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos_app/main.dart';

void main() {
  testWidgets('adds and removes products from the order', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(
        find.text('Tap a menu item to add it to the order.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Original Burger').first);
    await tester.pumpAndSettle();
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('\$5.99'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Add one Original Burger'));
    await tester.pumpAndSettle();
    expect(find.text('\$11.98'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove one Original Burger'));
    await tester.pumpAndSettle();
    expect(find.text('\$5.99'), findsWidgets);

    await tester.tap(find.byTooltip('Remove one Original Burger'));
    await tester.pumpAndSettle();
    expect(
        find.text('Tap a menu item to add it to the order.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on a narrow screen without layout exceptions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Lorem Restaurant'), findsOneWidget);
    expect(find.text('Order · Table 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
