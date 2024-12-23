library;

import 'dart:typed_data';
import 'src/private_utils.dart';

export '' if (dart.library.ui) 'integration_utils.dart';

/// Default options for pixel matching.
///
/// Contains the following configuration options:
/// * [threshold] - Matching threshold (0 to 1); smaller is more sensitive
/// * [includeAA] - Whether to skip anti-aliasing detection
/// * [alpha] - Opacity of original image in diff output
/// * [aaColor] - Color of anti-aliased pixels in diff output
/// * [diffColor] - Color of different pixels in diff output
/// * [diffColorAlt] - Alternative color for dark on light differences
/// * [diffMask] - Whether to draw the diff over a transparent background
const Map<String, dynamic> defaultOptions = {
  'threshold': 0.1,
  'includeAA': false,
  'alpha': 0.1,
  'aaColor': [255, 255, 0],
  'diffColor': [255, 0, 0],
  'diffColorAlt': null,
  'diffMask': false
};

/// Performs pixel-by-pixel image comparison between two images.
///
/// Compares two images and generates a diff output highlighting the differences.
/// Returns the number of pixels that are different between the two images.
///
/// Parameters:
/// * [rgbaImg1] - First image data as RGBA bytes
/// * [rgbaImg2] - Second image data as RGBA bytes
/// * [output] - Optional output image data where the diff will be drawn
/// * [width] - Width of the images in pixels
/// * [height] - Height of the images in pixels
/// * [options] - Comparison options (see [defaultOptions])
///
/// Returns the number of pixels that differ between the images.
///
/// Throws:
/// * [ArgumentError] if image sizes don't match or if image data size doesn't match dimensions
int pixelmatch(Uint8List rgbaImg1, Uint8List rgbaImg2, Uint8List? output, int width,
    int height, Map<String, dynamic> options) {
  if (rgbaImg1.length != rgbaImg2.length ||
      (output != null && output.length != rgbaImg1.length)) {
    throw ArgumentError(
        'Image sizes do not match. (${rgbaImg1.length}, ${rgbaImg2.length}, ${output!.length})');
  }

  final len = width * height;
  if (rgbaImg1.length != len * 4) {
    throw ArgumentError(
        'Image data size does not match width/height. (${rgbaImg1.length}, ${len * 4})');
  }

  options = {...defaultOptions, ...options};

  final a32 = Uint32List.view(rgbaImg1.buffer, rgbaImg1.offsetInBytes, len);
  final b32 = Uint32List.view(rgbaImg2.buffer, rgbaImg2.offsetInBytes, len);
  bool identical = true;

  for (var i = 0; i < len; i++) {
    if (a32[i] != b32[i]) {
      identical = false;
      break;
    }
  }
  if (identical) {
    if (output != null && !options['diffMask']) {
      for (var i = 0; i < len; i++) {
        drawGrayPixel(rgbaImg1, 4 * i, options['alpha'], output);
      }
    }
    return 0;
  }

  final double maxDelta = 35215.0 * options['threshold'] * options['threshold'];
  final aaColor = options['aaColor'] as List<int>;
  final diffColor = options['diffColor'] as List<int>;
  final diffColorAlt =
      options['diffColorAlt'] ?? options['diffColor'] as List<int>;
  int diff = 0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pos = (y * width + x) * 4;
      final delta = colorDelta(rgbaImg1, rgbaImg2, pos, pos);

      if (delta.abs() > maxDelta) {
        if (!options['includeAA'] &&
            (antialiased(rgbaImg1, rgbaImg2, width, height, x, y) ||
                antialiased(rgbaImg2, rgbaImg1, width, height, x, y))) {
          if (output != null && !options['diffMask']) {
            drawPixel(output, pos, aaColor[0], aaColor[1], aaColor[2]);
          }
        } else {
          if (output != null) {
            if (delta < 0) {
              drawPixel(output, pos, diffColorAlt[0], diffColorAlt[1],
                  diffColorAlt[2]);
            } else {
              drawPixel(output, pos, diffColor[0], diffColor[1], diffColor[2]);
            }
          }
          diff++;
        }
      } else if (output != null) {
        if (!options['diffMask']) {
          drawGrayPixel(rgbaImg1, pos, options['alpha'], output);
        }
      }
    }
  }

  return diff;
}
