import 'package:flutter_test/flutter_test.dart';
import 'package:kompanion/models/input_settings.dart';
import 'package:kompanion/models/remote_action.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('a fresh install defaults to next/prev', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await InputSettings.load();

    expect(settings.volumeUpAction, RemoteAction.next);
    expect(settings.volumeDownAction, RemoteAction.prev);
  });

  test('an out of range stored index falls back to the default', () async {
    SharedPreferences.setMockInitialValues({
      'volume_up_action': 99,
      'volume_down_action': -1,
    });
    final settings = await InputSettings.load();

    expect(settings.volumeUpAction, RemoteAction.next);
    expect(settings.volumeDownAction, RemoteAction.prev);
  });

  test('settings round trip', () async {
    SharedPreferences.setMockInitialValues({});
    await const InputSettings(
      volumeUpAction: RemoteAction.brightnessUp,
      volumeDownAction: RemoteAction.brightnessDown,
    ).save();

    final settings = await InputSettings.load();
    expect(settings.volumeUpAction, RemoteAction.brightnessUp);
    expect(settings.volumeDownAction, RemoteAction.brightnessDown);
  });
}
