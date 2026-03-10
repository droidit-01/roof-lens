// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/roof_provider.dart';
import '../providers/camera_provider.dart';
import '../painters/roof_3d_painter.dart';

class Roof3DView extends StatefulWidget {
  const Roof3DView({super.key});

  @override
  State<Roof3DView> createState() => _Roof3DViewState();
}

class _Roof3DViewState extends State<Roof3DView> {
  Offset? _lastFocal;
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoofProvider, CameraProvider>(
      builder: (ctx, roof, cam, _) {
        final model = roof.model;
        if (model == null) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A90D9)));
        }
        final painter = Roof3DPainter(
          model: model,
          selectedFaceIds: roof.selectedFaceIds,
          yaw: cam.yaw,
          pitch: cam.pitch,
          distance: cam.distance,
        );
        return GestureDetector(
          onScaleStart: (d) {
            _lastFocal = d.focalPoint;
            _lastScale = 1.0;
          },
          onScaleUpdate: (d) {
            if (_lastFocal != null) {
              final delta = d.focalPoint - _lastFocal!;
              if (d.pointerCount == 1) cam.orbit(delta.dx, -delta.dy);
              _lastFocal = d.focalPoint;
            }
            if (d.scale != 1.0) {
              cam.zoom(-(d.scale / _lastScale - 1.0) * 14);
              _lastScale = d.scale;
            }
          },
          onScaleEnd: (_) {
            _lastFocal = null;
            _lastScale = 1.0;
          },
          onTapUp: (d) {
            final box = context.findRenderObject() as RenderBox;
            final hit = painter.hitTestFace(d.localPosition, box.size);
            if (hit != null) roof.toggleFaceSelection(hit);
          },
          child: Stack(
            children: [
              CustomPaint(painter: painter, size: Size.infinite),
              Positioned(
                top: 12,
                right: 12,
                child: _Controls(cam: cam),
              ),
              const Positioned(
                top: 12,
                left: 12,
                child: _Hint(
                    'Drag to orbit  •  Pinch to zoom  •  Tap face to select'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  final CameraProvider cam;
  const _Controls({required this.cam});

  @override
  Widget build(BuildContext context) => Column(children: [
        _Btn(Icons.add, () => cam.zoom(-1.8)),
        const SizedBox(height: 6),
        _Btn(Icons.remove, () => cam.zoom(1.8)),
        const SizedBox(height: 6),
        _Btn(Icons.refresh, cam.reset),
      ]);
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF141826).withOpacity(0.88),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)
            ],
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
      );
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF141826).withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(text,
            style: const TextStyle(color: Color(0xFF8892A4), fontSize: 10)),
      );
}
