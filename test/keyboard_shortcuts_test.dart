import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pageturner_app/models/remote_action.dart';
import 'package:pageturner_app/widgets/keyboard_shortcuts.dart';

void main() {
  testWidgets('arrow keys win over a focused Slider', (tester) async {
    final actions = <RemoteAction>[];
    double sliderValue = 12;
    final sliderFocus = FocusNode();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeyboardShortcuts(
          onAction: actions.add,
          child: StatefulBuilder(
            builder: (context, setState) => Slider(
              focusNode: sliderFocus,
              value: sliderValue,
              max: 24,
              onChanged: (v) => setState(() => sliderValue = v),
            ),
          ),
        ),
      ),
    ));

    sliderFocus.requestFocus();
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, sliderFocus,
        reason: 'slider must really hold focus for this test to mean anything');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(actions, <RemoteAction>[
      RemoteAction.next,
      RemoteAction.prev,
      RemoteAction.brightnessUp,
      RemoteAction.brightnessDown,
    ]);
    expect(sliderValue, 12, reason: 'slider must not also consume the arrows');
  });

  testWidgets('held key fires once and still claims repeats', (tester) async {
    final actions = <RemoteAction>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeyboardShortcuts(
          onAction: actions.add,
          child: const SizedBox.expand(),
        ),
      ),
    ));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    expect(await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight), isTrue,
        reason: 'repeats must be claimed so the browser does not scroll');
    expect(await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight), isTrue);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(actions, <RemoteAction>[RemoteAction.next],
        reason: 'one HTTP command per physical press, not per repeat');
  });

  testWidgets('ignores arrows while a dialog is on top', (tester) async {
    final actions = <RemoteAction>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeyboardShortcuts(
          onAction: actions.add,
          child: const SizedBox.expand(),
        ),
      ),
    ));
    final BuildContext context = tester.element(find.byType(SizedBox));

    showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(content: TextField()),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(actions, isEmpty);
  });

  testWidgets('only the topmost page acts when two are mounted', (tester) async {
    final under = <RemoteAction>[];
    final over = <RemoteAction>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeyboardShortcuts(
          onAction: under.add,
          child: const SizedBox.expand(),
        ),
      ),
    ));
    final BuildContext context = tester.element(find.byType(SizedBox));

    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        body: KeyboardShortcuts(
          onAction: over.add,
          child: const ColoredBox(color: Color(0xFF000000)),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(over, <RemoteAction>[RemoteAction.next]);
    expect(under, isEmpty,
        reason: 'the still-mounted page below must not also turn the page');

    Navigator.of(context).pop();
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(under, <RemoteAction>[RemoteAction.prev],
        reason: 'the page below regains the keys once it is topmost again');
    expect(over, <RemoteAction>[RemoteAction.next]);
  });

  testWidgets('enabled: false hands the arrows back to the focus system',
      (tester) async {
    final actions = <RemoteAction>[];
    double sliderValue = 12;
    final sliderFocus = FocusNode();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeyboardShortcuts(
          enabled: false,
          onAction: actions.add,
          child: StatefulBuilder(
            builder: (context, setState) => Slider(
              focusNode: sliderFocus,
              value: sliderValue,
              max: 24,
              onChanged: (v) => setState(() => sliderValue = v),
            ),
          ),
        ),
      ),
    ));

    sliderFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(actions, isEmpty, reason: 'no remote action when disabled');
    expect(sliderValue, greaterThan(12),
        reason: 'the Slider gets its arrow key back');
  });

  testWidgets('Page Up / Page Down turn pages, as presenter remotes send',
      (tester) async {
    final actions = <RemoteAction>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeyboardShortcuts(
          onAction: actions.add,
          child: const SizedBox.expand(),
        ),
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();

    expect(actions, <RemoteAction>[RemoteAction.next, RemoteAction.prev]);
  });
}
