import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pageturner_app/utils/input_capabilities.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('volume buttons are Android only', () {
    // The volume_buttons MethodChannel is implemented in MainActivity.kt only.
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      expect(InputCapabilities.hasVolumeButtons,
          platform == TargetPlatform.android,
          reason: 'hasVolumeButtons for $platform');
    }
  });

  test('arrow keys stay live on every host, including mobile', () {
    // A Bluetooth keyboard can be paired with a phone or tablet too.
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      expect(InputCapabilities.arrowKeysEnabled, isTrue,
          reason: 'arrowKeysEnabled for $platform');
    }
  });

  test('only desktop hosts expect a keyboard', () {
    const desktop = {
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    };
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      expect(InputCapabilities.expectsKeyboard, desktop.contains(platform),
          reason: 'expectsKeyboard for $platform');
    }
  });

  test('a host that expects no keyboard still accepts arrow keys', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(InputCapabilities.expectsKeyboard, isFalse);
    expect(InputCapabilities.arrowKeysEnabled, isTrue,
        reason: 'advertising and handling are separate concerns');
  });

  test('the page turn hint names only the inputs the host expects', () {
    const expected = <TargetPlatform, String>{
      TargetPlatform.android: 'Use the volume buttons to turn pages!',
      TargetPlatform.iOS: 'Use the buttons below to turn pages!',
      TargetPlatform.fuchsia: 'Use the buttons below to turn pages!',
      TargetPlatform.linux: 'Use the arrow keys to turn pages!',
      TargetPlatform.macOS: 'Use the arrow keys to turn pages!',
      TargetPlatform.windows: 'Use the arrow keys to turn pages!',
    };
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      expect(InputCapabilities.pageTurnHint, expected[platform],
          reason: 'hint for $platform');
    }
  });
}
