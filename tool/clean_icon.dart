import 'dart:io';
import 'package:image/image.dart' as img;

bool isWhiteLike(img.Pixel p, int thr) => p.a > 0 && p.r >= thr && p.g >= thr && p.b >= thr;

void main() {
  final input = File('/root/GeoLocationMapper/UI/sitepin_app_icon.png');
  final output = File('/root/GeoLocationMapper/UI/sitepin_app_icon_clean.png');

  final bytes = input.readAsBytesSync();
  final src = img.decodePng(bytes);
  if (src == null) {
    stderr.writeln('Could not decode PNG');
    exit(1);
  }

  final w = src.width;
  final h = src.height;
  const thr = 245;

  // Remove white-like background globally so any white canvas is eliminated.
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final p = src.getPixel(x, y);
      if (isWhiteLike(p, thr)) {
        src.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 0);
      }
    }
  }

  var minX = w, minY = h, maxX = -1, maxY = -1;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final p = src.getPixel(x, y);
      if (p.a > 0) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (maxX < minX || maxY < minY) {
    stderr.writeln('No visible pixels after background cleanup');
    exit(1);
  }

  final cropW = maxX - minX + 1;
  final cropH = maxY - minY + 1;
  final cropped = img.copyCrop(src, x: minX, y: minY, width: cropW, height: cropH);

  final side = cropW > cropH ? cropW : cropH;
  final pad = (side * 0.03).round();
  final canvasSize = side + (pad * 2);
  final canvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  final ox = ((canvasSize - cropped.width) / 2).round();
  final oy = ((canvasSize - cropped.height) / 2).round();
  img.compositeImage(canvas, cropped, dstX: ox, dstY: oy);

  final resized = img.copyResize(canvas, width: 1024, height: 1024, interpolation: img.Interpolation.cubic);
  output.writeAsBytesSync(img.encodePng(resized));

  stdout.writeln(output.path);
}
