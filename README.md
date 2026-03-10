# RoofLens — Senior Flutter Developer Assignment

An interactive roof measurement viewer that parses EagleView and Hover XML exports, renders an interactive 3D orbit viewer and 2D plan view, and calculates per-face Eave × Rake values.

---

## Setup & Running

### Prerequisites
- Flutter 3.x (`flutter --version` should show 3.10 or higher)
- Dart SDK ≥ 3.0.0

### Steps
```bash
# 1. Clone or unzip the project
cd roof_viewer

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. Run unit tests
flutter test
```

Both sample XML files are bundled as assets — no external file needed to see the app working immediately.

---

## What Was Built

### 1. XML Parsing
- Auto-detects format from the root element (`EAGLEVIEW_EXPORT` vs `DATA_EXPORT`)
- Uses the `xml` package only — no regex anywhere
- Extracts per-face: area, pitch, vertices (ordered polygon), and all edge lengths (eave, rake, ridge, hip, valley) by computing Euclidean distance between 3D points
- Extracts summary: address, city, state, postal, lat/lng, total area, face count, average pitch

### 2. Roof Viewer — 3D + 2D Plan

**3D View**
- Pure `CustomPainter` with `vector_math` Matrix3 rotation (no external 3D library needed)
- Painter's algorithm depth-sorting for correct face occlusion
- Per-face diffuse lighting using surface normals
- Drag = orbit (yaw + pitch), pinch = zoom, tap = select face
- Camera state lives in a separate `CameraProvider` so 3D camera changes don't repaint the 2D view

**2D Plan View**
- Top-down XY projection with a scale ruler
- Pinch to zoom, drag to pan, tap to select face
- Faces labeled with name/ID + area

**Shared Selection**
- Both views read from the same `Set<String> selectedFaceIds` in `RoofProvider`
- Tapping a face in either view calls `toggleFaceSelection()` → both views repaint via `Consumer`

### 3. Roofing Calculations
Displays exactly three columns per selected face as specified:

| Face | Area (sqft) | Eave (ft) | Rake (ft) | Ev × Rk |
|------|-------------|-----------|-----------|---------|
| RF-1 | 492.0 | 24.0 | 32.0 | 768.0 |

Formula: **Eave × Rake = result** per face, summed into a **Grand Total**.

---

## State Management — Provider

**Choice: `provider` package (`ChangeNotifier`)**

**Why Provider over BLoC / Riverpod / GetX:**

1. **Simplicity matches scope** — this is a single-feature viewer. BLoC's event/state boilerplate would triple the file count with no architectural benefit here.
2. **Native Flutter feel** — `Consumer` and `context.read()` compose cleanly with `CustomPainter`'s repaint model. Painters get the exact data they need without subscribing to a stream.
3. **Split providers avoid over-repainting** — `RoofProvider` holds model + selection state; `CameraProvider` holds orbit/zoom state. A camera drag only repaints the 3D view, not the face list or calculations panel.
4. **Testability** — `RoofProvider` can be instantiated directly in tests with no mocking framework needed.

Riverpod would have been the next choice for a larger app (better compile-time safety, no `BuildContext` dependency), but for this assignment Provider is the cleaner, more readable option.

---

## Architecture — Clean Architecture

```
lib/
├── domain/                         # Pure Dart — no Flutter imports
│   ├── entities/
│   │   ├── roof_face.dart          # RoofFace + RoofModel
│   │   ├── roof_line.dart          # RoofLine, LineType, LineTypeX
│   │   └── roof_point.dart         # RoofPoint (x, y, z)
│   ├── repositories/
│   │   └── roof_repository.dart    # Abstract interface
│   └── usecases/
│       └── parse_roof_xml.dart     # ParseRoofXmlFromAsset, ParseRoofXmlFromFile
│
├── data/                           # Implements domain interfaces
│   ├── datasources/
│   │   └── xml_parser.dart         # RoofXmlParser (EagleView + Hover)
│   └── repositories/
│       └── roof_repository_impl.dart
│
└── presentation/                   # Flutter UI
    ├── painters/
    │   ├── roof_3d_painter.dart    # 3D CustomPainter with lighting
    │   └── roof_2d_painter.dart    # 2D plan CustomPainter
    ├── providers/
    │   ├── roof_provider.dart      # Model + selection state
    │   └── camera_provider.dart    # Orbit/zoom camera state
    ├── screens/
    │   ├── home_screen.dart        # File picker + sample loader
    │   └── viewer_screen.dart      # Tabbed 3D/2D viewer
    └── widgets/
        ├── calculations_panel.dart # Ev × Rk table + grand total
        ├── face_list_sheet.dart    # Bottom sheet face list
        ├── summary_panel.dart      # Address + stats summary
        ├── roof_3d_view.dart       # 3D gesture wrapper
        └── roof_2d_view.dart       # 2D gesture wrapper
```

**Dependency rule is enforced:** `domain` has zero Flutter/package imports. `data` depends on `domain`. `presentation` depends on `domain` only (never on `data` directly — accessed through use cases).

---

## Unit Tests (6 tests)

File: `test/roof_xml_parser_test.dart`

| # | Test |
|---|------|
| 1 | EagleView XML parses address, format, face count, area, pitch correctly |
| 2 | Hover XML parses address, format, face name and area correctly |
| 3 | Eave × Rake formula: 6 ft eave × 16 ft rake = 96.0 |
| 4 | Unknown XML root element throws `FormatException` |
| 5 | Non-ROOF faces (WALL, etc.) are excluded from `roofFaces` and `faceCount` |
| 6 | `RoofModel.totalArea` and `faceCount` aggregate across multiple ROOF faces |

Run with: `flutter test`

---

## Sample XML Files

| File | Format | Address | Roof Faces |
|------|--------|---------|------------|
| `assets/xml/eagleview_sample.xml` | EagleView | 21420 Humbolt Sq, Ashburn VA | 12 |
| `assets/xml/hover_sample.xml` | Hover | 312 Lake Shore Drive, Parsippany NJ | 5 |

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management |
| `xml` | ^6.3.0 | XML parsing (no regex) |
| `vector_math` | ^2.1.4 | 3D matrix rotation for CustomPainter |
| `file_picker` | ^6.1.1 | Import custom XML files |
| `google_fonts` | ^6.2.1 | Inter typeface |

---

## Time Spent

| Task | Hours |
|------|-------|
| XML parsing (both formats) + entities | 2.0 h |
| 3D CustomPainter (projection, lighting, hit-test) | 2.5 h |
| 2D plan painter + pan/zoom/select | 1.5 h |
| Provider wiring + shared selection | 1.0 h |
| Screens, UI, calculations panel | 2.0 h |
| Unit tests | 1.0 h |
| README + polish | 0.5 h |
| **Total** | **~10.5 h** |
