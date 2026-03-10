import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class CameraProvider extends ChangeNotifier {
  double yaw = 0.5, pitch = -0.45, distance = 60.0;

  void orbit(double dx, double dy) {
    yaw += dx * 0.008;
    pitch = (pitch + dy * 0.008).clamp(-math.pi / 2 + 0.1, math.pi / 2 - 0.1);
    notifyListeners();
  }

  void zoom(double delta) {
    distance = (distance * (1.0 + delta * 0.05)).clamp(5.0, 500.0);
    notifyListeners();
  }

  void pan(double dx, double dy) {
    notifyListeners();
  }

  void reset({double d = 60.0}) {
    yaw = 0.5;
    pitch = -0.45;
    distance = d;
    notifyListeners();
  }
}
