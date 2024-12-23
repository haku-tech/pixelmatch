import 'package:pixelmatch/pixelmatch.dart';
import 'package:pixelmatch/integration_utils.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
//import 'dart:ui';

void main() {

  test('Pixelmatch and readPng tests', () async {
    final img1 = await readPng('test/fixtures/1a.png');
    final img2 = await readPng('test/fixtures/1b.png');
    final width = img1.width;
    final height = img1.height;
    final expectDiff = await imgToRgba(await readPng('test/fixtures/1diff.png'));
    final actualDiff = Uint8List(width * height * 4);

    final rgba1 = await imgToRgba(img1);
    final rgba2 = await imgToRgba(img2);
    const options = {'threshold': 0.05};
    final mismatch = pixelmatch(rgba1, rgba2, actualDiff, width, height, options);
    final mismatch2 = pixelmatch(rgba1, rgba2, null, width, height, options);

    expectLater(mismatch, equals(143), reason: 'mismatch is different');
    expectLater(mismatch2, equals(143), reason: 'mismatch is different');
    expectLater(expectDiff, equals(actualDiff), reason: 'diff is different');
  });

  
  test('Resize and write image test', () async {
    final img = await readPng('test/fixtures/2a.png');
    final resized = await resizeImage(img, 100, 100);
    expectLater(resized.width, equals(100), reason: 'width is different');
    final existed = await readPng('test/fixtures/2a-resized.png');
    final rgbaExisted = await imgToRgba(existed);
    final rgbaResized = await imgToRgba(resized);
    expectLater(rgbaExisted, equals(rgbaResized), reason: 'resized image is different');
    await writePng('test/fixtures/2a-resized.png', resized);
    final rgbaWriten = await imgToRgba(await readPng('test/fixtures/2a-resized.png'));
    expectLater(rgbaExisted, equals(rgbaWriten), reason: 'written image is different');
  });
}
