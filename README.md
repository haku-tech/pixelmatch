# pixelmatch

Makes building multi-platform UIs a breeze. Small and fast diff image library with utils for integration/e2e testing.

## Motivation

I wanted to interact with Xcode and Android Studio much less, because it is possible to make screenshots in Github Actions CI with real iPhone/Android emulators. This is especially useful for thouse who don't have access to Apple/Android devices, FFI graphics libraries, UI/game testing and open source projects.

| expected | actual | diff |
| --- | --- | --- |
| ![](test/fixtures/4a.png) | ![](test/fixtures/4b.png) | ![diff](test/fixtures/4diff.png) |

## Features

- Diff image comparison with customizable threshold, AA and colors for output.
- Workflow for iOS/Android/Web screenshot making in CI (PR welcome for other CI).
- Lightweight utils for cropping notch from iPhone, decoding and resizing images.
- Color difference based on [color science research](https://web.archive.org/web/20240414154638/http://riaa.uaem.mx/xmlui/bitstream/handle/20.500.12055/91/progmat222010Measuring.pdf) from the ported [mapbox](https://github.com/mapbox/pixelmatch) library.

## Usage

With Dart SDK it can be used in web, mobile and desktop. Like a diff library.

```dart
import 'package:pixelmatch/pixelmatch.dart';
import 'dart:typed_data';

void main() {
  // Prepare your image data as RGBA Uint8Lists
  final img1 = Uint8List(width * height * 4); // First image
  final img2 = Uint8List(width * height * 4); // Second image
  final diff = Uint8List(width * height * 4); // Output diff (or null)

  // Compare images
  final numDiffPixels = pixelmatch(img1, img2, diff, width, height, { 'threshold': 0.1 });

  print('Found $numDiffPixels different pixels');
}
```

With Flutter SDK it can be used for integration_test. There are additional lightweight utils like readPng/writePng, imgToRgba/rgbaToImg, resizeImage, cropNotch, cropSides, with it you can make your own E2E/Integration workflow for host/cloud testing as shown in example.

```dart
import 'package:pixelmatch/pixelmatch.dart';
import 'package:pixelmatch/integration_utils.dart';
import 'dart:typed_data';

void main() {
  final img1 = await readPng('screenshot/$name1.png');
  final img2 = await readPng('screenshot/$name2.png');
  final width = img1.width;
  final height = img1.height;
  final rgba1 = await imgToRgba(img1);
  final rgba2 = await imgToRgba(img2);
  final diff = Uint8List(width * height * 4);

  // Compare images
  final numDiffPixels = pixelmatch(rgba1, rgba2, diff, width, height, { 'threshold': 0.1 });

  print('Found $numDiffPixels different pixels');
}
```

## This solves some issues in Flutter

- [Proposal: Make on-device testing awesome](https://github.com/flutter/flutter/issues/148028)
- [Add end-to-end integration test tests for all generators](https://github.com/flutter/flutter/issues/111505)
- [Missing matchesGoldenFile documentation](https://github.com/flutter/flutter/issues/103222)
- [Chromedriver resize bug with --browser-dimension](https://github.com/flutter/flutter/issues/136109)

## Pixelmatch options

- `threshold` (default: 0.1): Matching threshold (0 to 1); smaller is more sensitive
- `includeAA` (default: false): Whether to skip anti-aliasing detection
- `alpha` (default: 0.1): Opacity of original image in diff output
- `aaColor` (default: [255, 255, 0]): Color of anti-aliased pixels in diff output
- `diffColor` (default: [255, 0, 0]): Color of different pixels in diff output
- `diffColorAlt` (default: null): Alternative color for dark on light differences
- `diffMask` (default: false): Draw the diff over a transparent background