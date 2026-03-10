import 'package:flutter/foundation.dart';
import '../../domain/entities/roof_face.dart';
import '../../domain/usecases/parse_roof_xml.dart';
import '../../data/repositories/roof_repository_impl.dart';
import '../../data/datasources/xml_parser.dart';

enum LoadingState { idle, loading, loaded, error }

class RoofProvider extends ChangeNotifier {
  late final ParseRoofXmlFromAsset _fromAsset;
  late final ParseRoofXmlFromFile _fromFile;

  RoofModel? _model;
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  final Set<String> _selected = {};

  RoofProvider() {
    final repo = RoofRepositoryImpl(RoofXmlParser());
    _fromAsset = ParseRoofXmlFromAsset(repo);
    _fromFile = ParseRoofXmlFromFile(repo);
  }

  RoofModel? get model => _model;
  LoadingState get loadingState => _state;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasData => _model != null;
  String get errorMessage => _errorMessage;
  Set<String> get selectedFaceIds => Set.unmodifiable(_selected);

  bool isSelected(String id) => _selected.contains(id);
  bool isFaceSelected(String id) => _selected.contains(id);

  List<RoofFace> get selectedFaces =>
      _model?.roofFaces.where((f) => _selected.contains(f.id)).toList() ?? [];

  double get grandTotal =>
      selectedFaces.fold(0.0, (s, f) => s + f.eaveTimesRake);

  Future<void> loadFromAsset(String path) async {
    _state = LoadingState.loading;
    _errorMessage = '';
    _selected.clear();
    notifyListeners();
    try {
      _model = await _fromAsset(path);
      _state = LoadingState.loaded;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Parse error: $e';
    }
    notifyListeners();
  }

  Future<void> loadFromFile(String path) async {
    _state = LoadingState.loading;
    _errorMessage = '';
    _selected.clear();
    notifyListeners();
    try {
      _model = await _fromFile(path);
      _state = LoadingState.loaded;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Parse error: $e';
    }
    notifyListeners();
  }

  void toggleFaceSelection(String id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  void selectAll() {
    _selected.addAll(_model?.roofFaces.map((f) => f.id) ?? []);
    notifyListeners();
  }
}
