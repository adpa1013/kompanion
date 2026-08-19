import 'package:flutter/services.dart';
import '../utils/input_capabilities.dart';

/// Service for handling volume button events
class VolumeButtonService {
  static const MethodChannel _channel = MethodChannel('volume_buttons');

  final VoidCallback onVolumeUp;
  final VoidCallback onVolumeDown;

  bool _listening = false;

  VolumeButtonService({
    required this.onVolumeUp,
    required this.onVolumeDown,
  }) {
    if (InputCapabilities.hasVolumeButtons) {
      _setupMethodCallHandler();
      _listening = true;
    }
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'volumeUp') {
        onVolumeUp();
      } else if (call.method == 'volumeDown') {
        onVolumeDown();
      }
    });
  }

  void dispose() {
    if (_listening) {
      _channel.setMethodCallHandler(null);
      _listening = false;
    }
  }
}
