class RoofLine {
  final String id;
  final String startPointId;
  final String endPointId;
  final LineType type;
  const RoofLine({required this.id, required this.startPointId, required this.endPointId, required this.type});
}

enum LineType { eave, ridge, rake, valley, hip, flashing, stepFlash, hidden, soffit, other, insideCorner, outsideCorner }

class LineTypeX {
  static LineType fromString(String s) {
    switch (s.toUpperCase()) {
      case 'EAVE': return LineType.eave;
      case 'RIDGE': return LineType.ridge;
      case 'RAKE': return LineType.rake;
      case 'VALLEY': return LineType.valley;
      case 'HIP': return LineType.hip;
      case 'FLASHING': return LineType.flashing;
      case 'STEPFLASH': return LineType.stepFlash;
      case 'HIDDEN': return LineType.hidden;
      case 'SOFFIT': return LineType.soffit;
      case 'INSIDECORNER': return LineType.insideCorner;
      case 'OUTSIDECORNER': return LineType.outsideCorner;
      default: return LineType.other;
    }
  }
}