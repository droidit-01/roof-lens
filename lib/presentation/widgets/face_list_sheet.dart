// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/roof_provider.dart';
import '../../domain/entities/roof_face.dart';

class FaceListSheet extends StatelessWidget {
  const FaceListSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoofProvider>(builder: (ctx, p, _) {
      final m = p.model;
      if (m == null) return const SizedBox.shrink();
      final faces = m.roofFaces;
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
              color: Color(0xFF141826),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Text('Roof Faces',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(width: 10),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: const Color(0xFF4A90D9).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('${faces.length}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF4A90D9),
                              fontWeight: FontWeight.w700))),
                  const Spacer(),
                  TextButton(
                    onPressed: p.selectedFaceIds.length == faces.length
                        ? p.clearSelection
                        : p.selectAll,
                    child: Text(
                        p.selectedFaceIds.length == faces.length
                            ? 'Deselect All'
                            : 'Select All',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF4A90D9),
                            fontWeight: FontWeight.w600)),
                  ),
                ])),
            const SizedBox(height: 8),
            Expanded(
                child: ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: faces.length,
              itemBuilder: (_, i) => _Item(
                  face: faces[i],
                  isSel: p.isFaceSelected(faces[i].id),
                  onTap: () => p.toggleFaceSelection(faces[i].id)),
            )),
          ]),
        ),
      );
    });
  }
}

class _Item extends StatelessWidget {
  final RoofFace face;
  final bool isSel;
  final VoidCallback onTap;
  const _Item({required this.face, required this.isSel, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSel
                ? const Color(0xFF4A90D9).withOpacity(0.12)
                : const Color(0xFF1E2535),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSel
                    ? const Color(0xFF4A90D9).withOpacity(0.5)
                    : Colors.transparent),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color:
                      isSel ? const Color(0xFF4A90D9) : const Color(0xFF2A3347),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(isSel ? Icons.check : Icons.roofing,
                  color: isSel ? Colors.white : const Color(0xFF8892A4),
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(face.displayName,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                      '${face.area.toStringAsFixed(1)} sqft • Pitch: ${face.pitch.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF8892A4))),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _Mini('Eave', '${face.eaveLength.toStringAsFixed(1)} ft',
                  const Color(0xFF4A90D9)),
              const SizedBox(height: 3),
              _Mini('Rake', '${face.rakeLength.toStringAsFixed(1)} ft',
                  const Color(0xFF7B68EE)),
            ]),
          ]),
        ),
      );
}

class _Mini extends StatelessWidget {
  final String l, v;
  final Color c;
  const _Mini(this.l, this.v, this.c);
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$l: ',
            style: GoogleFonts.inter(
                fontSize: 10, color: const Color(0xFF8892A4))),
        Text(v,
            style: GoogleFonts.inter(
                fontSize: 10, color: c, fontWeight: FontWeight.w600)),
      ]);
}
