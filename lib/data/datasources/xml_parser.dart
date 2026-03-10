import 'dart:math' as math;
import 'package:xml/xml.dart';
import '../../domain/entities/roof_face.dart';
import '../../domain/entities/roof_line.dart';
import '../../domain/entities/roof_point.dart';

class RoofXmlParser {
  RoofModel parse(String xmlContent) {
    final doc = XmlDocument.parse(xmlContent);
    final root = doc.rootElement;
    if (root.name.local == 'EAGLEVIEW_EXPORT') return _parse(root, 'EAGLEVIEW');
    if (root.name.local == 'DATA_EXPORT') return _parse(root, 'HOVER');
    throw FormatException('Unknown XML format: ${root.name.local}');
  }

  RoofModel _parse(XmlElement root, String format) {
    final loc = root.findElements('LOCATION').firstOrNull;
    final address = loc?.getAttribute('address') ?? '';
    final city = loc?.getAttribute('city') ?? '';
    final state = loc?.getAttribute('state') ?? '';
    final postal = loc?.getAttribute('postal') ?? '';
    final lat = double.tryParse(loc?.getAttribute('lat') ?? '0') ?? 0.0;
    final lng = double.tryParse(loc?.getAttribute('long') ?? '0') ?? 0.0;
    final roof = root.findAllElements('ROOF').firstOrNull;
    if (roof == null) throw const FormatException('No ROOF element found');
    final points = _parsePoints(roof);
    final lines = _parseLines(roof);
    final faces = _parseFaces(roof, lines, points);
    return RoofModel(
      address: address,
      city: city,
      state: state,
      postal: postal,
      lat: lat,
      lng: lng,
      faces: faces,
      lines: lines,
      points: points,
      sourceFormat: format,
    );
  }

  Map<String, RoofPoint> _parsePoints(XmlElement roof) {
    final map = <String, RoofPoint>{};
    for (final p in roof.findAllElements('POINT')) {
      final id = p.getAttribute('id') ?? '';
      final data = (p.getAttribute('data') ?? '0,0,0').split(',');
      if (data.length >= 3) {
        map[id] = RoofPoint(
          id: id,
          x: double.tryParse(data[0].trim()) ?? 0,
          y: double.tryParse(data[1].trim()) ?? 0,
          z: double.tryParse(data[2].trim()) ?? 0,
        );
      }
    }
    return map;
  }

  Map<String, RoofLine> _parseLines(XmlElement roof) {
    final map = <String, RoofLine>{};
    for (final l in roof.findAllElements('LINE')) {
      final id = l.getAttribute('id') ?? '';
      final path = l.getAttribute('path') ?? '';
      final pts = path.split(',');
      if (pts.length >= 2) {
        map[id] = RoofLine(
          id: id,
          startPointId: pts[0].trim(),
          endPointId: pts[1].trim(),
          type: LineTypeX.fromString(l.getAttribute('type') ?? 'OTHER'),
        );
      }
    }
    return map;
  }

  List<RoofFace> _parseFaces(XmlElement roof, Map<String, RoofLine> lines,
      Map<String, RoofPoint> points) {
    final faces = <RoofFace>[];
    for (final face in roof.findAllElements('FACE')) {
      final id = face.getAttribute('id') ?? '';
      final name = face.getAttribute('name') ?? '';
      final faceType = face.getAttribute('type') ?? 'ROOF';
      final polygon = face.findElements('POLYGON').firstOrNull;
      if (polygon == null) continue;
      final area = double.tryParse(polygon.getAttribute('size') ?? '0') ?? 0.0;
      final pitch =
          double.tryParse(polygon.getAttribute('pitch') ?? '0') ?? 0.0;
      final path = polygon.getAttribute('path') ?? '';
      final lineIds = path
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final pointIds = _orderedPoints(lineIds, lines);
      final f = RoofFace(
          id: id,
          name: name,
          faceType: faceType,
          area: area,
          pitch: pitch,
          pointIds: pointIds,
          lineIds: lineIds);
      _calcEdges(f, lineIds, lines, points);
      faces.add(f);
    }
    return faces;
  }

  List<String> _orderedPoints(
      List<String> lineIds, Map<String, RoofLine> lines) {
    final ids = <String>[];
    final seen = <String>{};
    for (final lid in lineIds) {
      final line = lines[lid];
      if (line != null && !seen.contains(line.startPointId)) {
        seen.add(line.startPointId);
        ids.add(line.startPointId);
      }
    }
    return ids;
  }

  void _calcEdges(RoofFace face, List<String> lineIds,
      Map<String, RoofLine> lines, Map<String, RoofPoint> points) {
    double ev = 0, rk = 0, ri = 0, va = 0, hi = 0;
    for (final lid in lineIds) {
      final line = lines[lid];
      if (line == null) continue;
      final p1 = points[line.startPointId];
      final p2 = points[line.endPointId];
      if (p1 == null || p2 == null) continue;
      final dx = p2.x - p1.x, dy = p2.y - p1.y, dz = p2.z - p1.z;
      final len = math.sqrt(dx * dx + dy * dy + dz * dz);
      switch (line.type) {
        case LineType.eave:
          ev += len;
          break;
        case LineType.rake:
          rk += len;
          break;
        case LineType.ridge:
          ri += len;
          break;
        case LineType.valley:
          va += len;
          break;
        case LineType.hip:
          hi += len;
          break;
        default:
          break;
      }
    }
    face.eaveLength = ev;
    face.rakeLength = rk;
    face.ridgeLength = ri;
    face.valleyLength = va;
    face.hipLength = hi;
  }
}
