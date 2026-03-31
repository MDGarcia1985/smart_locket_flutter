/// Image Processing Pipeline
/// 
/// Handles image processing for Smart Locket device compatibility.
/// Processes images to meet device requirements:
/// - Square aspect ratio (center-cropped)
/// - 240x240 pixel resolution
/// - JPEG format with 80% quality
/// - Optimized file size for BLE transfer
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image processing utilities for Smart Locket
/// 
/// Provides static methods for converting various image formats
/// into the specific format required by the locket device.
class ImagePipeline {
  /// Processes image file for locket device compatibility
  /// 
  /// Complete processing pipeline:
  /// 1. Loads and decodes image file (supports common formats)
  /// 2. Center-crops to square aspect ratio (preserves subject)
  /// 3. Resizes to exactly 240x240 pixels using cubic interpolation
  /// 4. Encodes as JPEG with 80% quality (balance of size/quality)
  /// 
  /// The center-crop approach ensures the main subject remains visible
  /// while meeting the square format requirement. Cubic interpolation
  /// provides smooth scaling with minimal artifacts.
  /// 
  /// [f] Input image file (PNG, JPEG, etc.)
  /// 
  /// Returns processed image as JPEG byte array ready for device transfer.
  /// 
  /// Throws Exception if image format is unsupported or file is corrupted.
  static Future<Uint8List> toLocketJpeg(File f) async {
    // Load image file into memory
    final bytes = await f.readAsBytes();
    
    // Decode image (supports PNG, JPEG, GIF, BMP, etc.)
    final src = img.decodeImage(bytes);
    if (src == null) {
      throw Exception("Unsupported image format: ${f.path}");
    }
    
    // Calculate square crop dimensions (use smaller dimension)
    final minSide = src.width < src.height ? src.width : src.height;
    
    // Calculate center crop coordinates
    final x = (src.width - minSide) ~/ 2;   // Horizontal center offset
    final y = (src.height - minSide) ~/ 2;  // Vertical center offset
    
    // Perform center crop to square
    final square = img.copyCrop(
      src, 
      x: x, 
      y: y, 
      width: minSide, 
      height: minSide
    );
    
    // Resize to device resolution with high-quality interpolation
    final resized = img.copyResize(
      square, 
      width: 240, 
      height: 240, 
      interpolation: img.Interpolation.cubic
    );
    
    // Encode as JPEG with 80% quality (good balance for BLE transfer)
    final jpg = img.encodeJpg(resized, quality: 80);
    
    return Uint8List.fromList(jpg);
  }
}