import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';

/// Reads a PNG file from the specified path and converts it to an [Image] object.
/// 
/// Parameters:
///   - path: The file system path of the PNG to read
/// 
/// Returns a Future that completes with the loaded [Image].
Future<Image> readPng(String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

/// Writes an [Image] object to a PNG file at the specified path.
/// 
/// Parameters:
///   - path: The file system path where the PNG should be saved
///   - image: The [Image] object to be written
Future<void> writePng(String path, Image image) async {
  final data = await image.toByteData(format: ImageByteFormat.png);
  File(path).writeAsBytes(data!.buffer.asUint8List());
}

/// Converts an [Image] object to raw RGBA bytes.
/// 
/// Parameters:
///   - image: The source [Image] object
/// 
/// Returns a Future that completes with the image data as RGBA bytes.
Future<Uint8List> imgToRgba(Image image) async {
  final data = await image.toByteData(format: ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List();
}

/// Creates an [Image] object from raw RGBA bytes.
/// 
/// Parameters:
///   - rawRgba: The raw RGBA byte data to convert
/// 
/// Returns a Future that completes with the created [Image].
Future<Image> rgbaToImg(Uint8List rawRgba) async {
  final codec = await instantiateImageCodec(rawRgba);
  return (await codec.getNextFrame()).image;
}

/// Resizes an [Image] to the specified dimensions.
/// 
/// Parameters:
///   - image: The source [Image] to resize
///   - width: The target width in pixels
///   - height: The target height in pixels
/// 
/// Returns a Future that completes with the resized [Image].
Future<Image> resizeImage(Image image, int width, int height) async {
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  final codec = await instantiateImageCodec(
    bytes!.buffer.asUint8List(),
    targetWidth: width,
    targetHeight: height
  );
  return (await codec.getNextFrame()).image;
}