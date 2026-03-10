// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/roof_provider.dart';

const _kBlue = Color(0xFF4A90D9);
const _kPurple = Color(0xFF7B68EE);
const _kCard = Color(0xFF141826);
const _kSurface = Color(0xFF1E2535);

class FaceListPanel extends StatelessWidget {
  const FaceListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoofProvider>(builder: (context, provider, _) {
      final faces = provider.model?.roofFaces ?? [];

      return Container(
        decoration: BoxDecoration(
          color: _kCard,
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _kSurface,
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: Row(children: [
                const Icon(Icons.roofing_rounded, size: 14, color: _kBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Roof Faces',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
                Text('${faces.length}',
                    style: GoogleFonts.inter(color: _kBlue, fontSize: 12)),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: faces.length,
                itemBuilder: (context, idx) {
                  final face = faces[idx];
                  final isSelected = provider.isFaceSelected(face.id);
                  final faceColors = [
                    _kBlue,
                    _kPurple,
                    const Color(0xFF50C878),
                    const Color(0xFFFF7F50),
                    const Color(0xFFE8B84B),
                    const Color(0xFF20B2AA),
                    const Color(0xFFFF6B9D),
                    const Color(0xFF88D498),
                  ];
                  final color = faceColors[idx % faceColors.length];

                  return GestureDetector(
                    onTap: () => provider.toggleFaceSelection(face.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _kBlue.withOpacity(0.12)
                            : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? _kBlue : color,
                            width: 3,
                          ),
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(
                                face.displayName,
                                style: GoogleFonts.inter(
                                  color: isSelected ? _kBlue : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  size: 14, color: _kBlue),
                          ]),
                          const SizedBox(height: 3),
                          Text(
                            '${face.area.toStringAsFixed(0)} sf  •  ${face.pitch.toStringAsFixed(1)} pitch',
                            style: GoogleFonts.inter(
                                color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
