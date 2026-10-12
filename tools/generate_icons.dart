// Generator ikon PNG 512x512 (line-art, stroke 1.8/24) untuk MySaving.
// Menggambar path SVG dari desain (desain/src/App.tsx) ke PNG transparan
// berwarna hitam solid supaya bisa di-tint lewat Image.asset(color: ...).
// Murni dart:io, tanpa dependensi.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int S = 512;
const double scale = S / 24.0;
const double r = 1.8 * scale / 2.0; // radius lingkaran stempel

class MiniCanvas {
  final Uint8List px = Uint8List(S * S * 4);

  void stamp(double x, double y) {
    final cx = x * scale;
    final cy = y * scale;
    final x0 = (cx - r).floor().clamp(0, S - 1);
    final x1 = (cx + r).ceil().clamp(0, S - 1);
    final y0 = (cy - r).floor().clamp(0, S - 1);
    final y1 = (cy + r).ceil().clamp(0, S - 1);
    for (var yy = y0; yy <= y1; yy++) {
      for (var xx = x0; xx <= x1; xx++) {
        final dx = xx - cx + 0.5;
        final dy = yy - cy + 0.5;
        if (dx * dx + dy * dy <= r * r) {
          final i = (yy * S + xx) * 4;
          px[i] = 0;
          px[i + 1] = 0;
          px[i + 2] = 0;
          px[i + 3] = 255;
        }
      }
    }
  }

  void polyline(List<List<double>> pts) {
    for (var s = 0; s < pts.length - 1; s++) {
      final ax = pts[s][0], ay = pts[s][1];
      final bx = pts[s + 1][0], by = pts[s + 1][1];
      final dist = math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay));
      final steps = (dist * 6).ceil();
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        stamp(ax + (bx - ax) * t, ay + (by - ay) * t);
      }
    }
  }

  void arc(
    double cx,
    double cy,
    double rad,
    double startDeg,
    double endDeg, {
    int samples = 160,
  }) {
    for (var i = 0; i <= samples; i++) {
      final t = i / samples;
      final a = (startDeg + (endDeg - startDeg) * t) * math.pi / 180;
      stamp(cx + rad * math.cos(a), cy + rad * math.sin(a));
    }
  }

  void circle(double cx, double cy, double rad) =>
      arc(cx, cy, rad, 0, 360, samples: 128);

  void cubic(
    double x0,
    double y0,
    double c1x,
    double c1y,
    double c2x,
    double c2y,
    double x1,
    double y1, {
    int samples = 48,
  }) {
    for (var i = 0; i <= samples; i++) {
      final t = i / samples;
      final mt = 1 - t;
      final x =
          mt * mt * mt * x0 +
          3 * mt * mt * t * c1x +
          3 * mt * t * t * c2x +
          t * t * t * x1;
      final y =
          mt * mt * mt * y0 +
          3 * mt * mt * t * c1y +
          3 * mt * t * t * c2y +
          t * t * t * y1;
      stamp(x, y);
    }
  }

  void rrect(double x, double y, double w, double h, double rx) {
    // tepi lurus + 4 sudut melengkung
    for (var t = x + rx; t <= x + w - rx; t += 0.2) {
      stamp(t, y);
      stamp(t, y + h);
    }
    for (var t = y + rx; t <= y + h - rx; t += 0.2) {
      stamp(x, t);
      stamp(x + w, t);
    }
    // sudut: pusat (x+rx, y+rx) dst., radius rx
    final corners = [
      [x + rx, y + rx, 180.0, 270.0], // kiri-atas
      [x + w - rx, y + rx, 270.0, 360.0], // kanan-atas
      [x + w - rx, y + h - rx, 0.0, 90.0], // kanan-bawah
      [x + rx, y + h - rx, 90.0, 180.0], // kiri-bawah
    ];
    for (final c in corners) {
      arc(c[0], c[1], rx, c[2], c[3], samples: 24);
    }
  }
}

// ===== PNG encoder (murni dart:io) =====
final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

Uint8List _chunk(String type, List<int> data) {
  final out = BytesBuilder();
  final len = Uint8List(4)..buffer.asByteData().setUint32(0, data.length);
  out.add(len);
  out.add(type.codeUnits);
  out.add(data);
  final crcData = Uint8List(type.codeUnits.length + data.length)
    ..setAll(0, type.codeUnits)
    ..setAll(type.codeUnits.length, data);
  final crc = Uint8List(4)..buffer.asByteData().setUint32(0, _crc32(crcData));
  out.add(crc);
  return out.takeBytes();
}

Uint8List encodePng(MiniCanvas c) {
  final raw = BytesBuilder();
  for (var y = 0; y < S; y++) {
    raw.add([0]); // filter: none
    raw.add(c.px.sublist(y * S * 4, (y + 1) * S * 4));
  }
  final compressed = ZLibCodec().encode(raw.takeBytes());

  final png = BytesBuilder();
  png.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  final ihdr = Uint8List(13);
  final ih = ihdr.buffer.asByteData();
  ih.setUint32(0, S);
  ih.setUint32(4, S);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 6; // color type: RGBA
  ihdr[10] = 0; // compression
  ihdr[11] = 0; // filter
  ihdr[12] = 0; // interlace
  png.add(_chunk('IHDR', ihdr));
  png.add(_chunk('IDAT', compressed));
  png.add(_chunk('IEND', []));
  return png.takeBytes();
}

void save(String name, MiniCanvas canvas) {
  final dir = Directory(
    r'C:\Users\USER\Documents\android\mysaving\assets\icons',
  );
  File('${dir.path}/$name').writeAsBytesSync(encodePng(canvas));
  stdout.writeln('generated $name');
}

void main() {
  // 1. arrow (chevron-left) — tombol kembali
  var c = MiniCanvas();
  c.polyline([
    [15, 18],
    [9, 12],
    [15, 6],
  ]);
  save('ic_arrow.png', c);

  // 2. chevron (chevron-right) — akhir baris pengaturan
  c = MiniCanvas();
  c.polyline([
    [9, 6],
    [15, 12],
    [9, 18],
  ]);
  save('ic_chevron.png', c);

  // 3. trend (trending-up)
  c = MiniCanvas();
  c.polyline([
    [4, 17],
    [9, 12],
    [13, 15],
    [20, 7],
  ]);
  c.polyline([
    [15, 7],
    [20, 7],
    [20, 12],
  ]);
  save('ic_trend.png', c);

  // 4. check
  c = MiniCanvas();
  c.polyline([
    [5, 12],
    [9, 16],
    [19, 6],
  ]);
  save('ic_check.png', c);

  // 5. image
  c = MiniCanvas();
  c.rrect(3, 4, 18, 16, 2);
  c.circle(8.5, 9, 1.5);
  c.polyline([
    [4, 17],
    [9, 12],
    [13, 16],
    [16, 13],
    [21, 18],
  ]);
  save('ic_image.png', c);

  // 6. bell
  c = MiniCanvas();
  c.arc(12, 9, 6, 0, -180); // lengkung atas
  c.cubic(6, 9, 6, 16, 3, 16, 3, 18); // sisi kiri
  c.polyline([
    [3, 18],
    [21, 18],
  ]); // dasar
  c.cubic(21, 18, 21, 16, 18, 16, 18, 9); // sisi kanan
  c.polyline([
    [10, 21],
    [14, 21],
  ]); // gagang bawah
  save('ic_bell.png', c);

  // 7. moon (crescent) — dua busur r=9
  //    busur luar: pusat (16.9777, 7.0223), 70.36° -> 199.64°
  //    busur dalam: pusat (11.5223, 12.4777), 250.36° -> 19.64° (mundur)
  c = MiniCanvas();
  c.arc(16.9777, 7.0223, 9, 70.36, 199.64);
  c.arc(11.5223, 12.4777, 9, 250.36, 19.64);
  save('ic_moon.png', c);

  stdout.writeln('done');
}
