/// Local Data Storage Service
/// 
/// Manages persistent local storage using Hive database.
/// Handles initialization, registration of custom adapters,
/// and provides access to photo collection storage.
/// 
/// Uses Hive for:
/// - Fast local storage without SQL overhead
/// - Type-safe object storage with generated adapters
/// - Cross-platform compatibility (mobile, desktop, web)
/// - Automatic serialization/deserialization
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../models/photo_item.dart';

/// Local storage service using Hive database
/// 
/// Provides centralized access to local data storage with
/// type-safe operations and automatic persistence.
class Store {
  /// Box name for photo collection storage
  static const boxPhotos = 'photos';
  
  /// Initializes Hive database and registers adapters
  /// 
  /// Setup process:
  /// 1. Initializes Hive for Flutter (sets up platform-specific paths)
  /// 2. Registers PhotoItem adapter for object serialization
  /// 3. Opens photos box for immediate use
  /// 
  /// Must be called before any database operations.
  /// Typically called during app startup in main().
  static Future<void> init() async {
    // Initialize Hive with Flutter-specific configuration
    await Hive.initFlutter();
    
    // Register custom object adapter for PhotoItem serialization
    Hive.registerAdapter(PhotoItemAdapter());
    
    // Open photos box for immediate access
    await Hive.openBox<PhotoItem>(boxPhotos);
  }

  /// Provides access to photos collection box
  /// 
  /// Returns type-safe Hive box for PhotoItem objects.
  /// Supports standard operations: add, get, delete, values, etc.
  /// 
  /// Box must be initialized via init() before first access.
  static Box<PhotoItem> get photos => Hive.box<PhotoItem>(boxPhotos);
}