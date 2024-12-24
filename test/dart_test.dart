import 'package:pixelmatch/pixelmatch.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const options = {'threshold': 0.05};

  group('Pixelmatch Tests', () {
    diffTest('1a', '1b', '1diff', options, 143);
    diffTest('1a', '1b', '1diffmask', {'threshold': 0.05, 'includeAA': false, 'diffMask': true}, 143);
    diffTest('1a', '1a', '1emptydiffmask', {'threshold': 0, 'diffMask': true}, 0);
    diffTest('2a', '2b', '2diff', {'threshold': 0.05, 'alpha': 0.5, 'aaColor': [0, 192, 0], 'diffColor': [255, 0, 255]}, 12437);
    diffTest('3a', '3b', '3diff', options, 212);
    diffTest('4a', '4b', '4diff', options, 36049);
    diffTest('5a', '5b', '5diff', options, 0);
    diffTest('6a', '6b', '6diff', options, 51);
    diffTest('6a', '6a', '6empty', {'threshold': 0}, 0);
    diffTest('7a', '7b', '7diff', {'diffColorAlt': [0, 255, 0]},2448);
  });
}

void diffTest(String imgPath1, String imgPath2, String diffPath,
    Map<String, dynamic> options, int expectedMismatch) {
  final info = 'comparing $imgPath1 to $imgPath2, ${options.toString()}';

  test(info, () {
    final img1 = readImage(imgPath1);
    final img2 = readImage(imgPath2);
    final diff = readImage(diffPath);
    final width = img1.width;
    final height = img1.height;
    final out = Uint8List(width * height * 4);

    final mismatch = pixelmatch(
        img1.toUint8List(), img2.toUint8List(), out, width, height, options);
    final mismatch2 = pixelmatch(
        img1.toUint8List(), img2.toUint8List(), null, width, height, options);

    expect(diff.toUint8List(), equals(out), reason: 'diff is different');
    expect(mismatch, equals(expectedMismatch), reason: 'number of mismatched pixels');
    expect(mismatch, equals(mismatch2), reason: 'number of mismatched pixels without diff');
  });
}

img.Image readImage(String name) {
  final bytes = File('test/fixtures/$name.png').readAsBytesSync();
  final image = img.decodePng(bytes);
  return image!.convert(numChannels: 4);
}
