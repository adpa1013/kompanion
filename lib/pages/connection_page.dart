import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'control_page.dart';

class ConnectionPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ConnectionPage({super.key, required this.onToggleTheme});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final TextEditingController _addressController = TextEditingController();
  String _status = 'Enter KOReader device address';
  String _lastAddressHint = '192.168.1.100:8080';

  @override
  void initState() {
    super.initState();
    _loadLastAddress();
  }

  Future<void> _loadLastAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAddress = prefs.getString('last_ip');
    setState(() {
      if (lastAddress != null && lastAddress.isNotEmpty) {
        _lastAddressHint = lastAddress;
        _addressController.text = lastAddress;
      } else {
        _addressController.text = _lastAddressHint;
      }
    });
  }

  Future<void> _saveLastAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_ip', address);
  }

  /// Accepts either `host`, `host:port`, or a full `http(s)://host[:port]` URL
  /// and normalizes it to a bare `scheme://host[:port]` server URL.
  /// Returns null if the input can't be parsed into one.
  String? _normalizeAddress(String input) {
    if (input.contains('://')) {
      final uri = Uri.tryParse(input);
      if (uri == null ||
          uri.host.isEmpty ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        return null;
      }
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
      ).toString();
    }

    final parts = input.split(':');
    final host = parts[0];
    if (host.isEmpty || parts.length > 2) {
      return null;
    }

    int port = 8080;
    if (parts.length == 2) {
      final parsedPort = int.tryParse(parts[1]);
      if (parsedPort == null || parsedPort < 1 || parsedPort > 65535) {
        return null;
      }
      port = parsedPort;
    }

    return Uri(scheme: 'http', host: host, port: port).toString();
  }

  void _connect() async {
    final input = _addressController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _status = 'Please enter a device address';
      });
      return;
    }

    final serverUrl = _normalizeAddress(input);
    if (serverUrl == null) {
      setState(() {
        _status =
            'Please enter a valid address, e.g. 192.168.1.100:8080 or https://example.com';
      });
      return;
    }

    await _saveLastAddress(input);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ControlPage(
            serverUrl: serverUrl,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: const AssetImage('assets/icons/koreader.png'),
                        height: 80,
                        fit: BoxFit.contain,
                        colorBlendMode: isDark ? BlendMode.srcIn : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kompanion',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 1.2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'KOReader device address',
                      border: const OutlineInputBorder(),
                      hintText: _lastAddressHint,
                      prefixIcon: const Icon(Icons.device_hub),
                    ),
                    keyboardType: TextInputType.url,
                    enabled: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter a LAN address like 192.168.1.100:8080 (default port 8080), '
                    'or a full https:// URL if KOReader is behind a reverse proxy.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton(
                    onPressed: _connect,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      disabledBackgroundColor:
                          Theme.of(context).colorScheme.surface,
                    ),
                    child: const Text(
                      'CONNECT',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color.fromARGB(255, 108, 108, 108),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: widget.onToggleTheme,
                tooltip:
                    isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}