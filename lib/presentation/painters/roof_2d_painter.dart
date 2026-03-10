// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/roof_face.dart';
import '../../domain/entities/roof_point.dart';

class Roof2DPainter extends CustomPainter {
  final RoofModel model;
  final Set<String> selectedFaceIds;
  final double scale;
  final Offset pan;

  static const _palette = [
    Color(0xFF4A90D9),
    Color(0xFF7B68EE),
    Color(0xFF50C878),
    Color(0xFFFF7F50),
    Color(0xFFE8B84B),
    Color(0xFF20B2AA),
    Color(0xFFFF6B9D),
    Color(0xFF88D498),
    Color(0xFFDDA0DD),
    Color(0xFF87CEEB),
    Color(0xFFF4A460),
    Color(0xFF66CDAA),
  ];

  const Roof2DPainter({
    required this.model,
    required this.selectedFaceIds,
    required this.scale,
    required this.pan,
  });

  (double, double, double) _t(Size size) {
    final bb = model.boundingBox;
    final mw = bb[3] - bb[0], mh = bb[4] - bb[1];
    if (mw == 0 || mh == 0) return (1.0, size.width / 2, size.height / 2);
    final s =
        math.min((size.width * 0.85) / mw, (size.height * 0.85) / mh) * scale;
    final ox = size.width / 2 - ((bb[0] + bb[3]) / 2) * s + pan.dx;
    final oy = size.height / 2 - ((bb[1] + bb[4]) / 2) * s + pan.dy;
    return (s, ox, oy);
  }

  Offset _p(RoofPoint p, double s, double ox, double oy) =>
      Offset(p.x * s + ox, p.y * s + oy);

  @override
  void paint(Canvas canvas, Size size) {
    final (s, ox, oy) = _t(size);

    final gPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 16; i++) {
      canvas.drawLine(Offset(size.width * i / 16, 0),
          Offset(size.width * i / 16, size.height), gPaint);
      canvas.drawLine(Offset(0, size.height * i / 16),
          Offset(size.width, size.height * i / 16), gPaint);
    }

    int ci = 0;
    for (final face in model.roofFaces) {
      final pts = model.getPointsForFace(face);
      if (pts.length < 3) {
        ci++;
        continue;
      }
      final pj = pts.map((p) => _p(p, s, ox, oy)).toList();
      final isSel = selectedFaceIds.contains(face.id);
      final col = _palette[ci % _palette.length];

      final path = Path()..moveTo(pj[0].dx, pj[0].dy);
      for (int i = 1; i < pj.length; i++) {
        path.lineTo(pj[i].dx, pj[i].dy);
      }
      path.close();

      canvas.drawPath(
          path.shift(const Offset(2, 2.5)),
          Paint()
            ..color = Colors.black.withOpacity(0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      canvas.drawPath(
          path,
          Paint()
            ..color = col.withOpacity(isSel ? 0.88 : 0.58)
            ..style = PaintingStyle.fill);
      canvas.drawPath(
          path,
          Paint()
            ..color =
                isSel ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.75)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSel ? 2.5 : 1.0);

      final cx = pj.map((o) => o.dx).reduce((a, b) => a + b) / pj.length;
      final cy = pj.map((o) => o.dy).reduce((a, b) => a + b) / pj.length;
      final label = '${face.displayName}\n${face.area.toStringAsFixed(0)} sqft';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isSel ? const Color(0xFFFFD700) : Colors.white,
            fontSize: 10,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
      ci++;
    }

    _drawRuler(canvas, size, s);
  }

  void _drawRuler(Canvas canvas, Size size, double s) {
    const rulerFt = 10.0;
    final rulerLen = rulerFt * s;
    if (rulerLen < 20) return;
    final ry = size.height - 24.0;
    const rx = 16.0;
    final paint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(rx, ry), Offset(rx + rulerLen, ry), paint);
    canvas.drawLine(Offset(rx, ry - 4), Offset(rx, ry + 4), paint);
    canvas.drawLine(
        Offset(rx + rulerLen, ry - 4), Offset(rx + rulerLen, ry + 4), paint);
    final tp = TextPainter(
      text: const TextSpan(
        text: '10 ft',
        style: TextStyle(color: Colors.white38, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rx + rulerLen / 2 - tp.width / 2, ry + 6));
  }

  String? hitTestFace(Offset tap, Size size) {
    final (s, ox, oy) = _t(size);
    for (final face in model.roofFaces.reversed) {
      final pts = model.getPointsForFace(face);
      if (pts.length < 3) continue;
      final pj = pts.map((p) => _p(p, s, ox, oy)).toList();
      final path = Path()..moveTo(pj[0].dx, pj[0].dy);
      for (int i = 1; i < pj.length; i++) {
        path.lineTo(pj[i].dx, pj[i].dy);
      }
      path.close();
      if (path.contains(tap)) return face.id;
    }
    return null;
  }

  @override
  bool shouldRepaint(Roof2DPainter old) =>
      old.selectedFaceIds != selectedFaceIds ||
      old.scale != scale ||
      old.pan != pan ||
      old.model != model;
}
