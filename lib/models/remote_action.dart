/// Actions that can be triggered by a remote input (volume buttons, arrow keys).
///
/// Values are persisted by index, so new actions must be appended.
enum RemoteAction {
  next,
  prev,
  brightnessUp,
  brightnessDown,
}

extension RemoteActionExtension on RemoteAction {
  String get displayName {
    switch (this) {
      case RemoteAction.next:
        return 'Next Page';
      case RemoteAction.prev:
        return 'Previous Page';
      case RemoteAction.brightnessUp:
        return 'Frontlight +10%';
      case RemoteAction.brightnessDown:
        return 'Frontlight -10%';
    }
  }
}

RemoteAction remoteActionFromIndex(int index, RemoteAction fallback) {
  if (index < 0 || index >= RemoteAction.values.length) {
    return fallback;
  }
  return RemoteAction.values[index];
}
