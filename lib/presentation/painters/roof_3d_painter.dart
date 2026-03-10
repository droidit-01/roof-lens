// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../../domain/entities/roof_face.dart';
import '../../domain/entities/roof_point.dart';

class Roof3DPainter extends CustomPainter {
  final RoofModel model;
  final Set<String> selectedFaceIds;
  final double yaw, pitch, distance;

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

  const Roof3DPainter({
    required this.model,
    required this.selectedFaceIds,
    required this.yaw,
    required this.pitch,
    required this.distance,
  });

  Matrix3 get _rot {
    final ry = Matrix3.rotationY(yaw);
    final rx = Matrix3.rotationX(pitch);
    return rx * ry;
  }

  Offset _project(
      RoofPoint p, Vector3 center, Matrix3 rot, double scale, Size size) {
    final v =
        rot.transform(Vector3(p.x - center.x, p.y - center.y, p.z - center.z));
    final fov = distance * 1.8;
    final pp = fov / (fov + v.z + distance * 0.05);
    return Offset(
        size.width / 2 + v.x * scale * pp, size.height / 2 - v.y * scale * pp);
  }

  double _depth(RoofPoint p, Vector3 center, Matrix3 rot) =>
      rot.transform(Vector3(p.x - center.x, p.y - center.y, p.z - center.z)).z;

  @override
  void paint(Canvas canvas, Size size) {
    final center = model.center;
    final ext = model.maxExtent;
    final scale =
        math.min(size.width, size.height) * 0.58 / (ext > 0 ? ext : 1);
    final rot = _rot;

    final gPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 12; i++) {
      canvas.drawLine(Offset(size.width * i / 12, 0),
          Offset(size.width * i / 12, size.height), gPaint);
      canvas.drawLine(Offset(0, size.height * i / 12),
          Offset(size.width, size.height * i / 12), gPaint);
    }

    final entries = <MapEntry<RoofFace, double>>[];
    for (final face in model.roofFaces) {
      final pts = model.getPointsForFace(face);
      if (pts.isEmpty) continue;
      final avg =
          pts.fold(0.0, (s, p) => s + _depth(p, center, rot)) / pts.length;
      entries.add(MapEntry(face, avg));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));

    final lightDir = Vector3(0.55, 1.0, 0.35).normalized();
    int ci = 0;
    for (final e in entries) {
      final face = e.key;
      final pts = model.getPointsForFace(face);
      if (pts.length < 3) {
        ci++;
        continue;
      }
      final proj =
          pts.map((p) => _project(p, center, rot, scale, size)).toList();
      final isSel = selectedFaceIds.contains(face.id);
      var col = _palette[ci % _palette.length];

      final path = Path()..moveTo(proj[0].dx, proj[0].dy);
      for (int i = 1; i < proj.length; i++) {
        path.lineTo(proj[i].dx, proj[i].dy);
      }
      path.close();

      final n = _normal(pts, rot);
      final diff = n.dot(lightDir).clamp(0.0, 1.0);
      final bright = 0.38 + diff * 0.62;

      if (isSel) col = Color.lerp(col, const Color(0xFFFFD700), 0.5)!;
      final fc = Color.fromRGBO(
        (col.red * bright).round().clamp(0, 255),
        (col.green * bright).round().clamp(0, 255),
        (col.blue * bright).round().clamp(0, 255),
        isSel ? 0.96 : 0.88,
      );

      canvas.drawPath(
          path.shift(const Offset(2.5, 3)),
          Paint()
            ..color = Colors.black.withOpacity(0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

      canvas.drawPath(
          path,
          Paint()
            ..color = fc
            ..style = PaintingStyle.fill);
      canvas.drawPath(
          path,
          Paint()
            ..color =
                isSel ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSel ? 2.5 : 0.8);

      final cx = proj.map((o) => o.dx).reduce((a, b) => a + b) / proj.length;
      final cy = proj.map((o) => o.dy).reduce((a, b) => a + b) / proj.length;
      final tp = TextPainter(
        text: TextSpan(
          text: face.displayName,
          style: TextStyle(
            color: isSel ? const Color(0xFFFFD700) : Colors.white,
            fontSize: 11,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 1))
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
      ci++;
    }
  }

  Vector3 _normal(List<RoofPoint> pts, Matrix3 rot) {
    if (pts.length < 3) return Vector3(0, 1, 0);
    final v0 = Vector3(pts[0].x, pts[0].y, pts[0].z);
    final n = (Vector3(pts[1].x, pts[1].y, pts[1].z) - v0)
        .cross(Vector3(pts[2].x, pts[2].y, pts[2].z) - v0);
    if (n.length > 0) n.normalize();
    return rot.transform(n);
  }

  String? hitTestFace(Offset tap, Size size) {
    final center = model.center;
    final ext = model.maxExtent;
    final scale =
        math.min(size.width, size.height) * 0.58 / (ext > 0 ? ext : 1);
    final rot = _rot;

    final entries = <MapEntry<RoofFace, double>>[];
    for (final face in model.roofFaces) {
      final pts = model.getPointsForFace(face);
      if (pts.isEmpty) continue;
      entries.add(MapEntry(
        face,
        pts.fold(0.0, (s, p) => s + _depth(p, center, rot)) / pts.length,
      ));
    }
    entries.sort((a, b) => a.value.compareTo(b.value));

    for (final e in entries) {
      final pts = model.getPointsForFace(e.key);
      if (pts.length < 3) continue;
      final proj =
          pts.map((p) => _project(p, center, rot, scale, size)).toList();
      final path = Path()..moveTo(proj[0].dx, proj[0].dy);
      for (int i = 1; i < proj.length; i++) {
        path.lineTo(proj[i].dx, proj[i].dy);
      }
      path.close();
      if (path.contains(tap)) return e.key.id;
    }
    return null;
  }

  @override
  bool shouldRepaint(Roof3DPainter old) =>
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.distance != distance ||
      old.selectedFaceIds != selectedFaceIds ||
      old.model != model;
}
