import 'dart:io';
import 'package:flutter/services.dart';
import '../../domain/entities/roof_face.dart';
import '../../domain/repositories/roof_repository.dart';
import '../datasources/xml_parser.dart';

class RoofRepositoryImpl implements RoofRepository {
  final RoofXmlParser _parser;
  RoofRepositoryImpl(this._parser);

  @override
  Future<RoofModel> parseFromAsset(String path) async {
    final content = await rootBundle.loadString(path);
    return _parser.parse(content);
  }

  @override
  Future<RoofModel> parseFromFile(String path) async {
    return _parser.parse(await File(path).readAsString());
  }
}
