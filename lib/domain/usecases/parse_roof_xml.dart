import '../entities/roof_face.dart';
import '../repositories/roof_repository.dart';

class ParseRoofXmlFromAsset {
  final RoofRepository repo;
  const ParseRoofXmlFromAsset(this.repo);
  Future<RoofModel> call(String path) => repo.parseFromAsset(path);
}

class ParseRoofXmlFromFile {
  final RoofRepository repo;
  const ParseRoofXmlFromFile(this.repo);
  Future<RoofModel> call(String path) => repo.parseFromFile(path);
}
