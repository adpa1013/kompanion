import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/remote_action.dart';

/// Maps keyboard keys to [RemoteAction]s.
///
/// Uses an early key event handler rather than [Shortcuts]/[Focus]: a focused
/// [Slider] binds the arrow keys itself, and [WidgetsApp] maps them to focus
/// traversal above the [Navigator], so both would claim them first.
class KeyboardShortcuts extends StatefulWidget {
  const KeyboardShortcuts({
    super.key,
    required this.onAction,
    required this.child,
    this.enabled = true,
  });

  final ValueChanged<RemoteAction> onAction;
  final Widget child;

  /// When false the keys are left to the focus system.
  final bool enabled;

  @override
  State<KeyboardShortcuts> createState() => _KeyboardShortcutsState();
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts> {
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addEarlyKeyEventHandler(_handleKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cached so the key handler does no inherited widget lookups.
    _route = ModalRoute.of(context);
  }

  @override
  void dispose() {
    FocusManager.instance.removeEarlyKeyEventHandler(_handleKey);
    super.dispose();
  }

  RemoteAction? _actionFor(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowLeft) return RemoteAction.prev;
    if (key == LogicalKeyboardKey.arrowRight) return RemoteAction.next;
    if (key == LogicalKeyboardKey.arrowUp) return RemoteAction.brightnessUp;
    if (key == LogicalKeyboardKey.arrowDown) return RemoteAction.brightnessDown;
    // Presenter remotes send these instead of the arrows.
    if (key == LogicalKeyboardKey.pageUp) return RemoteAction.prev;
    if (key == LogicalKeyboardKey.pageDown) return RemoteAction.next;
    return null;
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (!widget.enabled || !mounted || event.synthesized) {
      return KeyEventResult.ignored;
    }

    // A dialog or another page is on top.
    if (_route?.isCurrent != true) return KeyEventResult.ignored;

    final RemoteAction? action = _actionFor(event.logicalKey);
    if (action == null) return KeyEventResult.ignored;

    // Act once per press, but claim repeats and key up too so the browser
    // never scrolls and the focus tree never sees the keys.
    if (event is KeyDownEvent) {
      widget.onAction(action);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
