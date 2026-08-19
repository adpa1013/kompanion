import 'package:shared_preferences/shared_preferences.dart';
import 'remote_action.dart';

/// Remote input preferences, persisted in SharedPreferences.
class InputSettings {
  const InputSettings({
    required this.volumeUpAction,
    required this.volumeDownAction,
  });

  final RemoteAction volumeUpAction;
  final RemoteAction volumeDownAction;

  static const String _upKey = 'volume_up_action';
  static const String _downKey = 'volume_down_action';

  static Future<InputSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return InputSettings(
      volumeUpAction: remoteActionFromIndex(
        prefs.getInt(_upKey) ?? RemoteAction.next.index,
        RemoteAction.next,
      ),
      volumeDownAction: remoteActionFromIndex(
        prefs.getInt(_downKey) ?? RemoteAction.prev.index,
        RemoteAction.prev,
      ),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_upKey, volumeUpAction.index);
    await prefs.setInt(_downKey, volumeDownAction.index);
  }
}
