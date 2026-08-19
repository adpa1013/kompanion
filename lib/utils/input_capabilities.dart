import 'package:flutter/foundation.dart';

/// Which remote input methods the current host provides.
///
/// Uses [defaultTargetPlatform] rather than `dart:io`'s `Platform`, which
/// throws on web. [kIsWeb] is checked first because a browser on Android still
/// reports [TargetPlatform.android].
class InputCapabilities {
  const InputCapabilities._();

  /// Android only: the `volume_buttons` MethodChannel is implemented in
  /// `MainActivity.kt` and nowhere else.
  static bool get hasVolumeButtons =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// True everywhere: a Bluetooth keyboard can be paired with any host, and
  /// without one the handler simply never fires.
  static bool get arrowKeysEnabled => true;

  /// Whether a keyboard is the *expected* way to drive this host, and so worth
  /// advertising in the page turning hint. Narrower than [arrowKeysEnabled];
  /// the bindings stay listed in the Input Settings dialog everywhere.
  static bool get expectsKeyboard =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  /// Instruction line describing how to turn pages on this host.
  static String get pageTurnHint {
    if (hasVolumeButtons && expectsKeyboard) {
      return 'Use the volume buttons or arrow keys to turn pages!';
    }
    if (hasVolumeButtons) return 'Use the volume buttons to turn pages!';
    if (expectsKeyboard) return 'Use the arrow keys to turn pages!';
    return 'Use the buttons below to turn pages!';
  }
}
