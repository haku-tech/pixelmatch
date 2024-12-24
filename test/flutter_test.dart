import 'package:pixelmatch/pixelmatch.dart';
import 'package:pixelmatch/utils.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
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

  test('Raw resize and imgPixelmatch', () async {
    final img = await readPng('test/fixtures/2a.png');
    final rawResized = resizeRawImage(await encodePng(img), 100, 100);
    final resized = await decodePng(Uint8List.fromList(await rawResized));
    expectLater(resized.width, equals(100), reason: 'width is different');
    final existed = await readPng('test/fixtures/2a-resized.png');
    final diffNum = (await imgPixelmatch(existed, resized, {})).$1;
    expectLater(0, diffNum, reason: 'resized image is different');
    final img2 = await readPng('test/fixtures/2b.png');
    final options = {'threshold': 0.05, 'alpha': 0.5, 'aaColor': [0, 192, 0], 'diffColor': [255, 0, 255]};
    final diff = await imgPixelmatch(img, img2, options);
    expect(diff.$1, 12437 / (img2.width * img2.height), reason: 'imgPixelmatch from disk');
    final expected = await readPng('test/fixtures/2diff.png');
    final rgbaExp = await imgToRgba(expected);
    expectLater(rgbaExp, equals(diff.$2), reason: 'resized image is different');
  });
}
