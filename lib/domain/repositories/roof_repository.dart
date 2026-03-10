import '../entities/roof_face.dart';

abstract class RoofRepository {
  Future<RoofModel> parseFromAsset(String assetPath);
  Future<RoofModel> parseFromFile(String filePath);
}
