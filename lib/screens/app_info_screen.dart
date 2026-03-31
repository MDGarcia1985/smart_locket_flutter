/// App Information Screen
/// 
/// Displays app metadata, version information, and download links.
/// Provides users with app details and access to store listings.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_loader.dart';

/// App information and download screen
/// 
/// Shows comprehensive app details including version, features,
/// developer information, and platform-specific download links.
class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});
  
  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  AppMetadata? _metadata;
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }
  
  /// Loads app metadata and version information
  Future<void> _loadAppInfo() async {
    try {
      final metadata = await AppLoader.loadMetadata();
      setState(() {
        _metadata = metadata;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }
  
  /// Copies store URL to clipboard
  Future<void> _copyUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL copied to clipboard: $url')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_metadata == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load app information')),
      );
    }
    
    final storeUrls = AppLoader.getStoreUrls(_metadata!.packageId);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _metadata!.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text('Version ${_metadata!.version} (${_metadata!.buildNumber})'),
                    const SizedBox(height: 8),
                    Text(_metadata!.description),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...(_metadata!.features.map((feature) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(feature)),
                          ],
                        ),
                      )
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Download links
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.android),
                      title: const Text('Google Play Store'),
                      subtitle: const Text('Tap to copy URL'),
                      onTap: () => _copyUrl(storeUrls['google_play']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_iphone),
                      title: const Text('Apple App Store'),
                      subtitle: const Text('Tap to copy URL'),
                      onTap: () => _copyUrl(storeUrls['app_store']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.computer),
                      title: const Text('Microsoft Store'),
                      subtitle: const Text('Tap to copy URL'),
                      onTap: () => _copyUrl(storeUrls['microsoft_store']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('GitHub Releases'),
                      subtitle: const Text('Tap to copy URL'),
                      onTap: () => _copyUrl(storeUrls['github_releases']!),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Developer info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_metadata!.developer.name),
                    Text(_metadata!.developer.email),
                    Text(_metadata!.developer.website),
                    const SizedBox(height: 8),
                    Text(_metadata!.copyright),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}