/// Smart Locket Flutter Application
/// 
/// Main entry point for the Smart Locket mobile application.
/// Handles app initialization, Firebase, permissions, and navigation setup.
/// 
/// Copyright 2025 M&E Design
/// Contact: michael@mandedesign.studio
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'services/store.dart';
import 'screens/home_screen.dart';

/// Application entry point
/// 
/// Initializes Flutter bindings, Firebase, local storage (Hive),
/// and launches the main app with permission gating.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Store.init();

  runApp(const App());
}

/// Root application widget
/// 
/// Configures the MaterialApp with theme and navigation.
/// Wraps the home screen with permission gate for security.
class App extends StatelessWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Locket Control",
      // Material 3 theme with indigo color scheme
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo, 
        brightness: Brightness.light
      ),
      // Home screen wrapped in permission gate
      home: const PermGate(child: HomeScreen()),
    );
  }
}

/// Permission gate widget
/// 
/// Ensures required permissions are granted before allowing
/// access to the main application functionality.
/// Handles Bluetooth, storage, and photo permissions.
class PermGate extends StatefulWidget {
  /// Child widget to display after permissions are granted
  final Widget child;
  
  const PermGate({super.key, required this.child});
  
  @override State<PermGate> createState() => _PermGateState();
}

class _PermGateState extends State<PermGate> {
  String msg = "Requesting permissions...";
  bool _isRequesting = true;

  @override
  void initState() {
    super.initState();
    _ask();
  }

  /// Request permissions. Bluetooth is required; storage/photos are optional
  /// (requested again when user picks photos).
  Future<void> _ask() async {
    if (!mounted) return;
    setState(() {
      _isRequesting = true;
      msg = "Requesting permissions...";
    });

    try {
      final req = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.storage,
        Permission.photos,
      ].request();

      if (!mounted) return;
      // Require only Bluetooth to enter app; storage/photos can be denied and requested later in gallery.
      // On iOS, Bluetooth permissions may not appear in the map; treat as OK.
      final scan = req[Permission.bluetoothScan];
      final connect = req[Permission.bluetoothConnect];
      final bluetoothOk = (scan?.isGranted ?? true) && (connect?.isGranted ?? true);
      if (bluetoothOk) {
        setState(() {
          msg = "OK";
          _isRequesting = false;
        });
      } else {
        setState(() {
          msg = "Bluetooth is required. Grant in Settings or tap Retry.";
          _isRequesting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        msg = "Permission error: $e. Tap Retry or open Settings.";
        _isRequesting = false;
      });
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
    if (mounted) _ask();
  }

  @override
  Widget build(BuildContext context) {
    if (msg == "OK") return widget.child;

    return Scaffold(
      appBar: AppBar(title: const Text("Permissions")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRequesting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(),
                ),
              Text(msg, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isRequesting ? null : _ask,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings),
                label: const Text("Open Settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
