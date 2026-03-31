/// App Loader Service
/// 
/// Handles app distribution, updates, and store integration.
/// Provides functionality for checking app versions, downloading updates,
/// and managing app store metadata.
library;

import 'dart:convert';
import 'package:flutter/services.dart';

/// App loader and distribution service
/// 
/// Manages app metadata, version checking, and store integration
/// for Smart Locket application distribution.
class AppLoader {
  static AppMetadata? _metadata;
  
  /// Loads app metadata from JSON configuration
  /// 
  /// Reads app_metadata.json from assets and parses into
  /// structured AppMetadata object for use throughout app.
  static Future<AppMetadata> loadMetadata() async {
    if (_metadata != null) return _metadata!;
    
    try {
      final jsonString = await rootBundle.loadString('app_metadata.json');
      final jsonData = json.decode(jsonString);
      _metadata = AppMetadata.fromJson(jsonData['app']);
      return _metadata!;
    } catch (e) {
      throw Exception('Failed to load app metadata: $e');
    }
  }
  
  /// Gets current app version information from metadata
  /// 
  /// Returns version string from loaded metadata.
  static Future<String> getCurrentVersion() async {
    final metadata = await loadMetadata();
    return '${metadata.version} (${metadata.buildNumber})';
  }
  
  /// Generates app store download URLs
  /// 
  /// Creates platform-specific download links for app distribution.
  /// Returns map of platform names to store URLs.
  static Map<String, String> getStoreUrls(String packageId) {
    return {
      'google_play': 'https://play.google.com/store/apps/details?id=$packageId',
      'app_store': 'https://apps.apple.com/app/id/PLACEHOLDER_APP_ID',
      'microsoft_store': 'https://www.microsoft.com/store/apps/$packageId',
      'github_releases': 'https://github.com/mandedesign/smart-locket-flutter/releases'
    };
  }
  
  /// Checks if app update is available
  /// 
  /// Compares current version with latest available version.
  /// Returns true if update is available, false otherwise.
  static Future<bool> isUpdateAvailable() async {
    // Implementation would check remote version API
    // For now, returns false (no update available)
    return false;
  }
}

/// App metadata container
/// 
/// Holds structured app information loaded from JSON configuration.
class AppMetadata {
  final String name;
  final String packageId;
  final String version;
  final String buildNumber;
  final String description;
  final String category;
  final Developer developer;
  final List<String> features;
  final Map<String, List<String>> permissions;
  final List<String> supportedPlatforms;
  final Map<String, dynamic> minSdk;
  final String license;
  final String copyright;
  
  AppMetadata({
    required this.name,
    required this.packageId,
    required this.version,
    required this.buildNumber,
    required this.description,
    required this.category,
    required this.developer,
    required this.features,
    required this.permissions,
    required this.supportedPlatforms,
    required this.minSdk,
    required this.license,
    required this.copyright,
  });
  
  /// Creates AppMetadata from JSON data
  factory AppMetadata.fromJson(Map<String, dynamic> json) {
    return AppMetadata(
      name: json['name'],
      packageId: json['package_id'],
      version: json['version'],
      buildNumber: json['build_number'],
      description: json['description'],
      category: json['category'],
      developer: Developer.fromJson(json['developer']),
      features: List<String>.from(json['features']),
      permissions: Map<String, List<String>>.from(
        json['permissions'].map((k, v) => MapEntry(k, List<String>.from(v)))
      ),
      supportedPlatforms: List<String>.from(json['supported_platforms']),
      minSdk: json['min_sdk'],
      license: json['license'],
      copyright: json['copyright'],
    );
  }
}

/// Developer information container
class Developer {
  final String name;
  final String email;
  final String website;
  
  Developer({
    required this.name,
    required this.email,
    required this.website,
  });
  
  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      name: json['name'],
      email: json['email'],
      website: json['website'],
    );
  }
}