/// Bluetooth Low Energy Protocol Definitions
/// 
/// Defines the communication protocol between mobile app and Smart Locket device.
/// Includes BLE service/characteristic UUIDs, device identification,
/// and protocol message parsing for device status information.
/// 
/// Protocol Overview:
/// - Uses custom BLE service with control and data characteristics
/// - ASCII commands for device control (STAT?, PUT, DELALL, etc.)
/// - Binary data transfer for photo files with framing protocol
/// - Status responses in key=value format
library ble_protocol;

/// BLE service and characteristic identifiers
/// 
/// Defines the UUID constants used for Smart Locket BLE communication.
/// These must match the UUIDs implemented in the device firmware.
class BleIds {
  /// Device name prefix for discovery during BLE scan
  /// Devices advertising names starting with this prefix are considered Smart Lockets
  static const String advertisedNamePrefix = "Locket";
  
  /// Primary service UUID for Smart Locket communication
  /// Custom 128-bit UUID for the main service containing all characteristics
  static const String svc = "12345678-1234-1234-1234-123456789abc";
  
  /// Control characteristic UUID for commands and status
  /// Used for ASCII command transmission and response notifications
  /// Supports: read, write, notify properties
  static const String ctrl = "12345678-1234-1234-1234-123456789abd";
  
  /// Data characteristic UUID for file transfer
  /// Used for binary data transmission (photo files)
  /// Supports: write without response for high throughput
  static const String data = "12345678-1234-1234-1234-123456789abe";
}

/// Device status information container
/// 
/// Represents the current state of Smart Locket device storage
/// including photo count and available space.
class DeviceStat {
  /// Number of photos currently stored on device
  final int photos;
  
  /// Available storage space in bytes
  final int freeSpace;

  /// Creates device status instance
  /// 
  /// [photos] Current photo count on device
  /// [freeSpace] Available storage space in bytes
  DeviceStat(this.photos, this.freeSpace);

  /// Parses device status response string
  /// 
  /// Parses ASCII response in format: "STAT photos=5,free=1024"
  /// Extracts key=value pairs and converts to DeviceStat object.
  /// 
  /// [response] Raw ASCII response from device
  /// 
  /// Returns DeviceStat object or null if parsing fails.
  /// 
  /// Example input: "STAT photos=12,free=2048"
  /// Results in: DeviceStat(12, 2048)
  static DeviceStat? parse(String response) {
    // Split response into command and parameters
    final parts = response.split(' ');
    if (parts.length < 2) return null;
    
    // Parse comma-separated key=value parameters
    final params = parts[1].split(',');
    int photos = 0;
    int freeSpace = 0;
    
    // Extract each parameter
    for (final param in params) {
      final kv = param.split('=');
      if (kv.length == 2) {
        switch (kv[0]) {
          case 'photos':
            photos = int.tryParse(kv[1]) ?? 0;
            break;
          case 'free':
            freeSpace = int.tryParse(kv[1]) ?? 0;
            break;
        }
      }
    }
    
    return DeviceStat(photos, freeSpace);
  }
}