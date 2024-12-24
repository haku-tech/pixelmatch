import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';

import 'package:pixelmatch/pixelmatch.dart';

/// Decodes a PNG image from a byte array into an [Image] object.
/// 
/// Parameters:
///   - bytes: The PNG image data as a [Uint8List].
/// 
/// Returns a Future that completes with the decoded [Image].
Future<Image> decodePng(Uint8List bytes) async {
  final codec = await instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

/// Encodes an [Image] object into a PNG format byte array.
/// 
/// Parameters:
///   - image: The [Image] to encode.
/// 
/// Returns a Future that completes with the encoded image data as a [Uint8List].
Future<Uint8List> encodePng(Image image) async {
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

/// Reads a PNG file from the specified path and converts it to an [Image] object.
/// 
/// Parameters:
///   - path: The file system path of the PNG to read
/// 
/// Returns a Future that completes with the loaded [Image].
Future<Image> readPng(String path) async {
  final bytes = await File(path).readAsBytes();
  return decodePng(bytes);
}

/// Writes an [Image] object to a PNG file at the specified path.
/// 
/// Parameters:
///   - path: The file system path where the PNG should be saved
///   - image: The [Image] object to be written
Future<void> writePng(String path, Image image) async {
  File(path).writeAsBytes(await encodePng(image));
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
  final codec = await instantiateImageCodec(
    await encodePng(image),
    targetWidth: width,
    targetHeight: height
  );
  return (await codec.getNextFrame()).image;
}

/// Resizes a raw image byte array to the specified dimensions.
/// 
/// Parameters:
///   - rawBytes: The source image data as a list of bytes
///   - width: The target width in pixels
///   - height: The target height in pixels
/// 
/// Returns a Future that completes with the resized image data as a list of bytes.
Future<List<int>> resizeRawImage(List<int> rawBytes, int width, int height) async {
  final codec = await instantiateImageCodec(
    Uint8List.fromList(rawBytes),
    targetWidth: width,
    targetHeight: height
  );
  return encodePng((await codec.getNextFrame()).image);
}

/// Compares two [Image] objects and calculates the number of differing pixels.
/// 
/// Parameters:
///   - img1: The first [Image] object to compare.
///   - img2: The second [Image] object to compare.
///   - options: A map of options to customize the comparison.
/// 
/// Returns a Future that completes with a tuple containing:
///   - A [double] representing the ratio of differing pixels to the total
///     number of pixels in the images.
///   - A [Uint8List] containing the raw RGBA byte data of the difference image.
Future<(double, Uint8List)> imgPixelmatch(Image img1, Image img2, Map<String, dynamic> options) async {
  final rgba1 = await imgToRgba(img1);
  final rgba2 = await imgToRgba(img2);
  final diff = Uint8List(rgba1.length);
  final numPix = pixelmatch(rgba1, rgba2, diff, img1.width, img1.height, options);
  final ratio = numPix / (img1.width * img1.height);
  return (ratio, diff);
}