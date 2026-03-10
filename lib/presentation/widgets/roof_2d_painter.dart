// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/roof_provider.dart';
import '../painters/roof_2d_painter.dart';

typedef Roof2DPlanView = Roof2DView;

class Roof2DView extends StatefulWidget {
  const Roof2DView({super.key});

  @override
  State<Roof2DView> createState() => _Roof2DViewState();
}

class _Roof2DViewState extends State<Roof2DView> {
  double _scale = 1.0, _lastScale = 1.0;
  Offset _pan = Offset.zero;
  Offset? _lastFocal;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoofProvider>(
      builder: (ctx, roof, _) {
        final model = roof.model;
        if (model == null) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A90D9)));
        }
        final painter = Roof2DPainter(
          model: model,
          selectedFaceIds: roof.selectedFaceIds,
          scale: _scale,
          pan: _pan,
        );
        return GestureDetector(
          onScaleStart: (d) {
            _lastFocal = d.focalPoint;
            _lastScale = _scale;
          },
          onScaleUpdate: (d) {
            setState(() {
              if (_lastFocal != null) {
                _pan += d.focalPoint - _lastFocal!;
                _lastFocal = d.focalPoint;
              }
              if (d.scale != 1.0) {
                _scale = (_lastScale * d.scale).clamp(0.3, 6.0);
              }
            });
          },
          onScaleEnd: (_) => _lastFocal = null,
          onTapUp: (d) {
            final box = context.findRenderObject() as RenderBox;
            final hit = painter.hitTestFace(d.localPosition, box.size);
            if (hit != null) roof.toggleFaceSelection(hit);
          },
          child: Stack(children: [
            CustomPaint(painter: painter, size: Size.infinite),
            Positioned(
              top: 12,
              right: 12,
              child: Column(children: [
                _Btn(
                    Icons.add,
                    () => setState(
                        () => _scale = (_scale * 1.3).clamp(0.3, 6.0))),
                const SizedBox(height: 6),
                _Btn(
                    Icons.remove,
                    () => setState(
                        () => _scale = (_scale * 0.77).clamp(0.3, 6.0))),
                const SizedBox(height: 6),
                _Btn(
                    Icons.refresh,
                    () => setState(() {
                          _scale = 1.0;
                          _pan = Offset.zero;
                        })),
              ]),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF141826).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Text(
                  'Top-down plan view  •  Tap face to select',
                  style: TextStyle(color: Color(0xFF8892A4), fontSize: 10),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
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
