import 'package:flutter_test/flutter_test.dart';
import 'package:kompanion/models/remote_action.dart';

void main() {
  test('persisted indices stay stable for existing installs', () {
    // Settings are stored as enum indices, so next/prev must keep index 0/1.
    expect(RemoteAction.next.index, 0);
    expect(RemoteAction.prev.index, 1);
  });

  test('out of range stored indices fall back instead of throwing', () {
    expect(remoteActionFromIndex(99, RemoteAction.next), RemoteAction.next);
    expect(remoteActionFromIndex(-1, RemoteAction.prev), RemoteAction.prev);
    expect(remoteActionFromIndex(2, RemoteAction.next), RemoteAction.brightnessUp);
  });
}
