import 'package:flutter_test/flutter_test.dart';
import 'package:roof_viewer/data/datasources/xml_parser.dart';

void main() {
  group('RoofXmlParser', () {
    final parser = RoofXmlParser();

    // ── Test 1: EagleView format ──────────────────────────────────────
    test('parses EagleView XML format correctly', () {
      const xml = '''<?xml version="1.0" encoding="utf-8"?>
<EAGLEVIEW_EXPORT>
  <LOCATION address="123 Main St" city="Springfield" lat="39.0" long="-77.5" postal="12345" state="VA" />
  <STRUCTURES northorientation="0.0">
    <ROOF id="ROOF1">
      <FACES>
        <FACE designator="A" id="F1" type="ROOF" children="">
          <POLYGON id="P1" path="L1,L2,L3,L4" pitch="7" size="492" unroundedsize="491.8" />
        </FACE>
      </FACES>
      <LINES>
        <LINE id="L1" path="C1,C2" type="EAVE" />
        <LINE id="L2" path="C2,C3" type="RAKE" />
        <LINE id="L3" path="C3,C4" type="RIDGE" />
        <LINE id="L4" path="C4,C1" type="RAKE" />
      </LINES>
      <POINTS>
        <POINT id="C1" data="0.0,0.0,0.0" />
        <POINT id="C2" data="10.0,0.0,0.0" />
        <POINT id="C3" data="10.0,20.0,5.0" />
        <POINT id="C4" data="0.0,20.0,5.0" />
      </POINTS>
    </ROOF>
  </STRUCTURES>
</EAGLEVIEW_EXPORT>''';

      final result = parser.parse(xml);
      expect(result.address, equals('123 Main St'));
      expect(result.city, equals('Springfield'));
      expect(result.state, equals('VA'));
      expect(result.sourceFormat, equals('EAGLEVIEW'));
      expect(result.roofFaces.length, equals(1));
      expect(result.roofFaces.first.area, closeTo(492.0, 0.1));
      expect(result.roofFaces.first.pitch, closeTo(7.0, 0.01));
    });

    // ── Test 2: Hover format ──────────────────────────────────────────
    test('parses Hover XML format correctly', () {
      const xml = '''<?xml version="1.0"?>
<DATA_EXPORT xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <LOCATION address="456 Oak Ave" city="Testville" lat="40.0" long="-75.0" postal="67890" state="NJ"/>
  <STRUCTURES supports="SOFFIT,RAKE">
    <ROOF id="ROOF1">
      <FACES>
        <FACE id="F1" type="ROOF" name="RF-1" children="">
          <POLYGON id="P1" path="L1,L2,L3,L4" pitch="3.5" size="300.0"/>
        </FACE>
      </FACES>
      <LINES>
        <LINE id="L1" path="C1,C2" type="EAVE"/>
        <LINE id="L2" path="C2,C3" type="RAKE"/>
        <LINE id="L3" path="C3,C4" type="RIDGE"/>
        <LINE id="L4" path="C4,C1" type="RAKE"/>
      </LINES>
      <POINTS>
        <POINT id="C1" data="0.0,0.0,0.0"/>
        <POINT id="C2" data="15.0,0.0,0.0"/>
        <POINT id="C3" data="15.0,20.0,4.0"/>
        <POINT id="C4" data="0.0,20.0,4.0"/>
      </POINTS>
    </ROOF>
  </STRUCTURES>
</DATA_EXPORT>''';

      final result = parser.parse(xml);
      expect(result.address, equals('456 Oak Ave'));
      expect(result.sourceFormat, equals('HOVER'));
      expect(result.roofFaces.length, equals(1));
      expect(result.roofFaces.first.name, equals('RF-1'));
      expect(result.roofFaces.first.area, closeTo(300.0, 0.1));
    });

    // ── Test 3: Eave × Rake formula ───────────────────────────────────
    test('eaveTimesRake (Ev × Rk) computes correctly', () {
      const xml = '''<?xml version="1.0"?>
<DATA_EXPORT xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <LOCATION address="Calc" city="City" lat="0" long="0" postal="00000" state="TX"/>
  <STRUCTURES supports="">
    <ROOF id="ROOF1">
      <FACES>
        <FACE id="F1" type="ROOF" name="F1" children="">
          <POLYGON id="P1" path="L1,L2,L3,L4" pitch="5" size="200"/>
        </FACE>
      </FACES>
      <LINES>
        <LINE id="L1" path="C1,C2" type="EAVE"/>
        <LINE id="L2" path="C2,C3" type="RAKE"/>
        <LINE id="L3" path="C3,C4" type="RIDGE"/>
        <LINE id="L4" path="C4,C1" type="RAKE"/>
      </LINES>
      <POINTS>
        <POINT id="C1" data="0.0,0.0,0.0"/>
        <POINT id="C2" data="6.0,0.0,0.0"/>
        <POINT id="C3" data="6.0,8.0,0.0"/>
        <POINT id="C4" data="0.0,8.0,0.0"/>
      </POINTS>
    </ROOF>
  </STRUCTURES>
</DATA_EXPORT>''';

      final result = parser.parse(xml);
      final face = result.roofFaces.first;
      // Eave = 6 ft (L1), Rake = 8+8 = 16 ft (L2 + L4)
      expect(face.eaveLength, closeTo(6.0, 0.1));
      expect(face.rakeLength, closeTo(16.0, 0.1));
      expect(face.eaveTimesRake, closeTo(96.0, 0.5));
    });

    // ── Test 4: Unknown format throws ─────────────────────────────────
    test('throws FormatException for unknown XML format', () {
      const xml = '<?xml version="1.0"?><UNKNOWN_FORMAT/>';
      expect(() => parser.parse(xml), throwsA(isA<FormatException>()));
    });

    // ── Test 5: WALL faces excluded from roofFaces ────────────────────
    test('non-ROOF faces are excluded from roofFaces', () {
      const xml = '''<?xml version="1.0" encoding="utf-8"?>
<EAGLEVIEW_EXPORT>
  <LOCATION address="A" city="B" lat="0" long="0" postal="0" state="CA" />
  <STRUCTURES northorientation="0">
    <ROOF id="ROOF1">
      <FACES>
        <FACE id="F1" type="ROOF" designator="A" children="">
          <POLYGON id="P1" path="L1,L2,L3" pitch="7" size="100" unroundedsize="100" />
        </FACE>
        <FACE id="F2" type="WALL" designator="B" children="">
          <POLYGON id="P2" path="L1,L2,L3" size="50" />
        </FACE>
      </FACES>
      <LINES>
        <LINE id="L1" path="C1,C2" type="EAVE" />
        <LINE id="L2" path="C2,C3" type="RAKE" />
        <LINE id="L3" path="C3,C1" type="RAKE" />
      </LINES>
      <POINTS>
        <POINT id="C1" data="0,0,0" />
        <POINT id="C2" data="10,0,0" />
        <POINT id="C3" data="5,8,5" />
      </POINTS>
    </ROOF>
  </STRUCTURES>
</EAGLEVIEW_EXPORT>''';

      final result = parser.parse(xml);
      expect(result.faceCount, equals(1)); // Only ROOF type
      expect(result.totalArea, closeTo(100.0, 0.1));
    });

    // ── Test 6: RoofModel aggregates totalArea and faceCount ──────────
    test('RoofModel totalArea and faceCount aggregate correctly', () {
      const xml = '''<?xml version="1.0"?>
<DATA_EXPORT xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <LOCATION address="Multi" city="C" lat="0" long="0" postal="0" state="FL"/>
  <STRUCTURES supports="">
    <ROOF id="ROOF1">
      <FACES>
        <FACE id="F1" type="ROOF" name="A" children="">
          <POLYGON id="P1" path="L1,L2,L3" pitch="5" size="150"/>
        </FACE>
        <FACE id="F2" type="ROOF" name="B" children="">
          <POLYGON id="P2" path="L1,L2,L3" pitch="7" size="250"/>
        </FACE>
      </FACES>
      <LINES>
        <LINE id="L1" path="C1,C2" type="EAVE"/>
        <LINE id="L2" path="C2,C3" type="RAKE"/>
        <LINE id="L3" path="C3,C1" type="RAKE"/>
      </LINES>
      <POINTS>
        <POINT id="C1" data="0,0,0"/>
        <POINT id="C2" data="10,0,0"/>
        <POINT id="C3" data="5,8,0"/>
      </POINTS>
    </ROOF>
  </STRUCTURES>
</DATA_EXPORT>''';

      final result = parser.parse(xml);
      expect(result.faceCount, equals(2));
      expect(result.totalArea, closeTo(400.0, 0.1));
    });
  });
}
