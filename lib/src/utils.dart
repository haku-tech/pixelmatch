import 'dart:typed_data';

bool antialiased(Uint8List img, int x1, int y1, int width, int height, Uint8List img2) {
  final x0 = x1 > 0 ? x1 - 1 : 0;
  final y0 = y1 > 0 ? y1 - 1 : 0;
  final x2 = x1 < width - 1 ? x1 + 1 : width - 1;
  final y2 = y1 < height - 1 ? y1 + 1 : height - 1;
  final pos = (y1 * width + x1) * 4;
  int zeroes = (x1 == x0 || x1 == x2 || y1 == y0 || y1 == y2) ? 1 : 0;
  double min = 0;
  double max = 0;
  int? minX, minY, maxX, maxY;

  for (var x = x0; x <= x2; x++) {
    for (var y = y0; y <= y2; y++) {
      if (x == x1 && y == y1) continue;

      final delta = colorDelta(img, img, pos, (y * width + x) * 4, true);

      if (delta == 0) {
        zeroes++;
        if (zeroes > 2) return false;
      } else if (delta < min) {
        min = delta;
        minX = x;
        minY = y;
      } else if (delta > max) {
        max = delta;
        maxX = x;
        maxY = y;
      }
    }
  }

  if (min == 0 || max == 0) return false;

  return (hasManySiblings(img, minX!, minY!, width, height) && hasManySiblings(img2, minX, minY, width, height)) ||
         (hasManySiblings(img, maxX!, maxY!, width, height) && hasManySiblings(img2, maxX, maxY, width, height));
}

bool hasManySiblings(Uint8List img, int x1, int y1, int width, int height) {
  final x0 = x1 > 0 ? x1 - 1 : 0;
  final y0 = y1 > 0 ? y1 - 1 : 0;
  final x2 = x1 < width - 1 ? x1 + 1 : width - 1;
  final y2 = y1 < height - 1 ? y1 + 1 : height - 1;
  final pos = (y1 * width + x1) * 4;
  int zeroes = (x1 == x0 || x1 == x2 || y1 == y0 || y1 == y2) ? 1 : 0;

  for (var x = x0; x <= x2; x++) {
    for (var y = y0; y <= y2; y++) {
      if (x == x1 && y == y1) continue;

      final pos2 = (y * width + x) * 4;
      if (img[pos] == img[pos2] &&
          img[pos + 1] == img[pos2 + 1] &&
          img[pos + 2] == img[pos2 + 2] &&
          img[pos + 3] == img[pos2 + 3]) {
        zeroes++;
      }

      if (zeroes > 2) return true;
    }
  }

  return false;
}

double colorDelta(Uint8List img1, Uint8List img2, int k, int m, [bool yOnly = false]) {
  double r1 = img1[k + 0].toDouble();
  double g1 = img1[k + 1].toDouble();
  double b1 = img1[k + 2].toDouble();
  double a1 = img1[k + 3].toDouble();

  double r2 = img2[m + 0].toDouble();
  double g2 = img2[m + 1].toDouble();
  double b2 = img2[m + 2].toDouble();
  double a2 = img2[m + 3].toDouble();

  if (a1 == a2 && r1 == r2 && g1 == g2 && b1 == b2) return 0;

  if (a1 < 255.0) {
    a1 = a1 / 255.0;
    r1 = blend(r1, a1);
    g1 = blend(g1, a1);
    b1 = blend(b1, a1);
  }

  if (a2 < 255.0) {
    a2 = a2 / 255.0;
    r2 = blend(r2, a2);
    g2 = blend(g2, a2);
    b2 = blend(b2, a2);
  }

  final y1 = rgb2y(r1, g1, b1);
  final y2 = rgb2y(r2, g2, b2);
  final y = y1 - y2;

  if (yOnly) return y;

  final i = rgb2i(r1, g1, b1) - rgb2i(r2, g2, b2);
  final q = rgb2q(r1, g1, b1) - rgb2q(r2, g2, b2);

  final delta = 0.5053 * y * y + 0.299 * i * i + 0.1957 * q * q;

  return y1 > y2 ? -delta : delta;
}

double rgb2y(double r, double g, double b) => r * 0.29889531 + g * 0.58662247 + b * 0.11448223;
double rgb2i(double r, double g, double b) => r * 0.59597799 - g * 0.27417610 - b * 0.32180189;
double rgb2q(double r, double g, double b) => r * 0.21147017 - g * 0.52261711 + b * 0.31114694;

double blend(double c, double a) => (255.0 + (c - 255.0) * a);

void drawPixel(Uint8List output, int pos, int r, int g, int b) {
  output[pos + 0] = r;
  output[pos + 1] = g;
  output[pos + 2] = b;
  output[pos + 3] = 255;
}

void drawGrayPixel(Uint8List img, int i, double alpha, Uint8List output) {
  final r = img[i + 0].toDouble();
  final g = img[i + 1].toDouble();
  final b = img[i + 2].toDouble();
  final val = blend(rgb2y(r, g, b), alpha * img[i + 3] / 255.0);
  drawPixel(output, i, val.toInt(), val.toInt(), val.toInt());
}