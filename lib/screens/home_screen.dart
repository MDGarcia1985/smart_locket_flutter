/// Home Screen - Main application interface
/// 
/// Primary screen for Smart Locket app that handles device discovery,
/// Bluetooth connection establishment, and navigation to gallery.
/// Provides visual feedback for connection status and user actions.
library;

import 'package:flutter/material.dart';
import '../services/ble_service.dart';
import '../services/auth_service.dart';
import 'device_gallery_screen.dart';
import 'login_screen.dart';

/// Home screen widget for Smart Locket application
/// 
/// Manages the main user interface including:
/// - Bluetooth device scanning and connection
/// - Connection status display
/// - Navigation to device gallery
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Bluetooth Low Energy service for device communication
  final BleService _ble = BleService();
  
  /// Flag indicating if connection attempt is in progress
  bool _isConnecting = false;
  
  /// Current connection status message displayed to user
  String _status = "Not connected";
  
  /// Current authenticated user
  User? _currentUser;

  /// Initiates Bluetooth scan and connection to Smart Locket device
  /// 
  /// Scans for devices with "Locket" prefix in advertised name,
  /// establishes connection, and updates UI with status feedback.
  /// Handles connection errors gracefully with user-friendly messages.
  Future<void> _connectToDevice() async {
    // Update UI to show connection in progress
    setState(() {
      _isConnecting = true;
      _status = "Scanning for device...";
    });

    try {
      // Attempt to scan for and connect to locket device
      await _ble.scanAndConnect();
      
      // Update UI on successful connection
      setState(() {
        _status = "Connected to locket";
        _isConnecting = false;
      });
    } catch (e) {
      // Handle connection failure with error message
      setState(() {
        _status = "Connection failed: $e";
        _isConnecting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes
    AuthService.userStream.listen((user) {
      setState(() => _currentUser = user);
    });
    // Set initial user state
    _currentUser = AuthService.currentUser;
  }
  
  /// Opens login screen
  Future<void> _showLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
  
  /// Signs out current user
  Future<void> _signOut() async {
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Locket"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_currentUser != null)
            PopupMenuButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle),
                    const SizedBox(width: 4),
                    Text(_currentUser!.name),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _signOut,
                  child: const Text('Sign Out'),
                ),
              ],
            )
          else
            TextButton(
              onPressed: _showLogin,
              child: const Text('Sign In'),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bluetooth icon as visual indicator
            Icon(
              Icons.bluetooth,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            
            // Connection status text
            Text(
              _status,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Connect button - shown when not connected and not connecting
            if (!_isConnecting && _status == "Not connected")
              ElevatedButton.icon(
                onPressed: _connectToDevice,
                icon: const Icon(Icons.bluetooth_searching),
                label: const Text("Connect to Locket"),
              ),
            
            // Gallery button - shown when successfully connected
            if (_status.startsWith("Connected"))
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to device gallery with BLE service instance
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceGalleryScreen(ble: _ble),
                    ),
                  );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text("Open Gallery"),
              ),
            
            // Loading indicator - shown during connection attempt
            if (_isConnecting)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}