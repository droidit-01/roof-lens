import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import 'roof_point.dart';
import 'roof_line.dart';

class RoofFace {
  final String id, name, faceType;
  final double area, pitch;
  final List<String> pointIds, lineIds;
  double eaveLength, rakeLength, ridgeLength, valleyLength, hipLength;

  RoofFace({
    required this.id, required this.name, required this.faceType,
    required this.area, required this.pitch,
    required this.pointIds, required this.lineIds,
    this.eaveLength = 0, this.rakeLength = 0, this.ridgeLength = 0,
    this.valleyLength = 0, this.hipLength = 0,
  });

  bool get isRoofFace => faceType == 'ROOF';
  double get eaveTimesRake => eaveLength * rakeLength;
  String get displayName => name.isNotEmpty ? name : id;
}

class RoofModel {
  final String address, city, state, postal, sourceFormat;
  final double lat, lng;
  final List<RoofFace> faces;
  final Map<String, RoofLine> lines;
  final Map<String, RoofPoint> points;

  const RoofModel({
    required this.address, required this.city, required this.state,
    required this.postal, required this.lat, required this.lng,
    required this.faces, required this.lines, required this.points,
    required this.sourceFormat,
  });

  List<RoofFace> get roofFaces => faces.where((f) => f.isRoofFace).toList();
  double get totalArea => roofFaces.fold(0.0, (s, f) => s + f.area);
  int get faceCount => roofFaces.length;
  double get averagePitch {
    if (roofFaces.isEmpty) return 0;
    return roofFaces.fold(0.0, (s, f) => s + f.pitch) / roofFaces.length;
  }

  List<double> get boundingBox {
    if (points.isEmpty) return [0, 0, 0, 1, 1, 1];
    double mnX = 1e9, mnY = 1e9, mnZ = 1e9;
    double mxX = -1e9, mxY = -1e9, mxZ = -1e9;
    for (final p in points.values) {
      if (p.x < mnX) mnX = p.x; if (p.y < mnY) mnY = p.y; if (p.z < mnZ) mnZ = p.z;
      if (p.x > mxX) mxX = p.x; if (p.y > mxY) mxY = p.y; if (p.z > mxZ) mxZ = p.z;
    }
    return [mnX, mnY, mnZ, mxX, mxY, mxZ];
  }

  Vector3 get center {
    final b = boundingBox;
    return Vector3((b[0]+b[3])/2, (b[1]+b[4])/2, (b[2]+b[5])/2);
  }

  double get maxExtent {
    final b = boundingBox;
    final dx = b[3]-b[0], dy = b[4]-b[1], dz = b[5]-b[2];
    return math.sqrt(dx*dx + dy*dy + dz*dz);
  }

  List<RoofPoint> getPointsForFace(RoofFace face) =>
      face.pointIds.map((id) => points[id]).whereType<RoofPoint>().toList();
}
