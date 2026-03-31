/// Device Gallery Screen - Photo management interface
/// 
/// Manages photo synchronization between mobile device and Smart Locket.
/// Handles photo selection, processing, local storage, and device transfer.
/// Enforces 50-photo limit on locket device with newest-first priority.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:collection/collection.dart';
import '../services/store.dart';
import '../services/image_pipeline.dart';
import '../services/ble_service.dart';
import '../models/photo_item.dart';
import 'package:path_provider/path_provider.dart';

/// Device gallery screen for photo management
/// 
/// Provides interface for:
/// - Viewing local photo collection
/// - Adding new photos from device
/// - Syncing photos to Smart Locket device
/// - Managing device storage (erase functionality)
class DeviceGalleryScreen extends StatefulWidget {
  /// Bluetooth service instance for device communication
  final BleService ble;
  
  const DeviceGalleryScreen({super.key, required this.ble});
  
  @override State<DeviceGalleryScreen> createState() => _DeviceGalleryScreenState();
}

class _DeviceGalleryScreenState extends State<DeviceGalleryScreen> {
  /// Number of photos currently stored on the locket device
  int? locketCount;
  
  /// Flag indicating if sync operation is in progress
  bool busy = false;

  /// Refreshes device status to get current photo count
  /// 
  /// Queries the connected locket device for storage statistics
  /// and updates the UI with current photo count.
  Future<void> _refreshStat() async {
    final st = await widget.ble.getStatus();
    setState(() => locketCount = st?.photos);
  }

  /// Opens file picker and adds selected images to local collection
  /// 
  /// Process:
  /// 1. Opens native file picker for image selection (multiple allowed)
  /// 2. Processes each image through ImagePipeline (resize, crop, compress)
  /// 3. Saves processed images to app documents directory
  /// 4. Creates PhotoItem records and stores in local Hive database
  /// 5. Updates UI to reflect new additions
  Future<void> _pickAndAdd() async {
    // Open file picker for image selection
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true, 
      type: FileType.image
    );
    if (res == null) return;
    
    // Get app documents directory for storage
    final appDir = await getApplicationDocumentsDirectory();
    
    // Process each selected file
    for (final f in res.files) {
      final path = f.path;
      if (path == null) continue;
      
      final file = File(path);
      // Process image: crop to square, resize to 240x240, compress to JPEG
      final jpg = await ImagePipeline.toLocketJpeg(file);
      
      // Generate unique ID and save processed image
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final out = File("${appDir.path}/$id.jpg");
      await out.writeAsBytes(jpg, flush: true);
      
      // Create and store PhotoItem record
      final item = PhotoItem(id, out.path, 240, 240, DateTime.now());
      await Store.photos.add(item);
    }
    
    // Refresh UI to show new photos
    setState(() {});
  }

  /// Synchronizes top 50 newest photos to locket device
  /// 
  /// Enforces device storage limit by selecting only the 50 most
  /// recently added photos. Transfers each photo via BLE protocol
  /// with error handling for failed transfers.
  Future<void> _syncToLocket() async {
    if (busy) return;
    
    setState(() => busy = true);
    try {
      // Get all photos sorted by newest first
      final items = Store.photos.values.toList()
        ..sort((a,b)=> b.addedAt.compareTo(a.addedAt));
      
      // Limit to top 50 for device storage constraints
      final top50 = items.take(50).toList();
      
      // Transfer each photo to device
      for (final p in top50) {
        final bytes = await File(p.path).readAsBytes();
        final ok = await widget.ble.sendJpeg(p.id, bytes);
        // Stop transfer if any photo fails
        if (!ok) break;
      }
      
      // Update device status after sync
      await _refreshStat();
    } finally {
      setState(() => busy = false);
    }
  }

  /// Erases all photos from locket device
  /// 
  /// Sends delete command to device and refreshes status.
  /// Local photos remain unchanged.
  Future<void> _eraseLocket() async {
    await widget.ble.deleteAll();
    await _refreshStat();
  }

  @override void initState() {
    super.initState();
    // Get initial device status on screen load
    _refreshStat();
  }

  @override
  Widget build(BuildContext context) {
    final items = Store.photos.values.sorted((a,b)=>b.addedAt.compareTo(a.addedAt)).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Gallery"),
        actions: [
          IconButton(onPressed: _refreshStat, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Locket capacity (max 50)"),
            subtitle: Text("On locket: ${locketCount ?? '—'}"),
            trailing: Wrap(spacing: 8, children: [
              ElevatedButton(onPressed: busy ? null : _syncToLocket, child: Text(busy ? "Syncing..." : "Sync Top 50")),
              OutlinedButton(onPressed: _eraseLocket, child: const Text("Erase Locket")),
            ]),
          ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: items.length,
              itemBuilder: (_, i){
                final it = items[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(it.path), fit: BoxFit.cover),
                    Positioned(
                      right: 4, bottom: 4,
                      child: Container(color: Colors.black54, padding: const EdgeInsets.symmetric(horizontal:6, vertical:2),
                        child: Text(it.addedAt.toIso8601String().substring(0,10),
                          style: const TextStyle(color: Colors.white, fontSize: 10))),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndAdd, child: const Icon(Icons.add_photo_alternate)),
    );
  }
}