import 'package:arisu_browser/presentation/common_widgets/safari_address_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({
  required TextEditingController controller,
  required FocusNode focusNode,
  void Function(String)? onChanged,
  VoidCallback? onClear,
}) =>
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            SafariAddressBar(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onClear: onClear,
              onSubmitted: (_) {},
              trailing: const Icon(Icons.bookmark_border),
            ),
            // Something else to move focus to.
            const TextField(key: Key('other')),
          ],
        ),
      ),
    );

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;

  setUp(() {
    controller = TextEditingController(text: 'https://example.com');
    focusNode = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('idle bar shows the lock icon and the trailing action',
      (tester) async {
    await tester.pumpWidget(_host(controller: controller, focusNode: focusNode));

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('focusing swaps in the search icon and the clear button',
      (tester) async {
    await tester.pumpWidget(_host(controller: controller, focusNode: focusNode));

    focusNode.requestFocus();
    await tester.pump();

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byIcon(Icons.bookmark_border), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('the clear button hides itself once the field is empty',
      (tester) async {
    await tester.pumpWidget(_host(controller: controller, focusNode: focusNode));
    focusNode.requestFocus();
    await tester.pump();
    expect(find.byIcon(Icons.close), findsOneWidget);

    controller.clear();
    await tester.pump();
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('clearing does not blur the field (editing continues)',
      (tester) async {
    var cleared = 0;
    await tester.pumpWidget(_host(
      controller: controller,
      focusNode: focusNode,
      onClear: () {
        cleared++;
        controller.clear();
      },
    ));
    focusNode.requestFocus();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(cleared, 1);
    expect(focusNode.hasFocus, isTrue);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('typing reports every keystroke through onChanged',
      (tester) async {
    final typed = <String>[];
    await tester.pumpWidget(_host(
      controller: controller,
      focusNode: focusNode,
      onChanged: typed.add,
    ));

    await tester.enterText(find.byType(TextField).first, 'flut');
    expect(typed, ['flut']);
  });

  testWidgets('losing focus restores the idle chrome', (tester) async {
    await tester.pumpWidget(_host(controller: controller, focusNode: focusNode));
    focusNode.requestFocus();
    await tester.pump();
    expect(find.byIcon(Icons.search), findsOneWidget);

    focusNode.unfocus();
    await tester.pump();

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });
}
