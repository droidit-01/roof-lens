// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/roof_provider.dart';
import '../../domain/entities/roof_face.dart';

class CalculationsPanel extends StatelessWidget {
  final VoidCallback? onClose;
  const CalculationsPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoofProvider>(builder: (ctx, p, _) {
      final sel = p.selectedFaces;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF141826),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4A90D9).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF4A90D9), Color(0xFF7B4FD9)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.calculate, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Calculations',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const Spacer(),
              if (sel.isEmpty)
                Text('Select roof faces',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFF8892A4))),
              if (sel.isNotEmpty) ...[
                GestureDetector(
                  onTap: p.clearSelection,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Clear',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              GestureDetector(
                onTap: p.selectAll,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('All',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF4A90D9),
                          fontWeight: FontWeight.w600)),
                ),
              ),
              if (onClose != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: const Color(0xFF1E2535),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close,
                        color: Colors.white54, size: 14),
                  ),
                ),
              ],
            ]),
          ),
          if (sel.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E2535),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.touch_app_outlined,
                      color: Color(0xFF8892A4), size: 20),
                  const SizedBox(width: 12),
                  Text('Tap roof faces in 3D or 2D view',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF8892A4))),
                ]),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(children: [
                      Expanded(
                          flex: 2,
                          child: Text('Face',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF8892A4),
                                  fontWeight: FontWeight.w600))),
                      Expanded(
                          child: Text('Area\n(sqft)',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF8892A4),
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text('Eave\n(ft)',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF4A90D9),
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text('Rake\n(ft)',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF7B68EE),
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text('Ev×Rk',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center)),
                    ]),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  ...sel.map((f) => _CalcRow(face: f)),
                  const Divider(color: Colors.white12, height: 1),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF4A90D9), Color(0xFF7B4FD9)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Text('Grand Total (${sel.length} faces)',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(p.grandTotal.toStringAsFixed(2),
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ]),
      );
    });
  }
}

class _CalcRow extends StatelessWidget {
  final RoofFace face;
  const _CalcRow({required this.face});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Text(face.displayName,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600))),
          Expanded(
              child: Text(face.area.toStringAsFixed(1),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center)),
          Expanded(
              child: Text(face.eaveLength.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF4A90D9)),
                  textAlign: TextAlign.center)),
          Expanded(
              child: Text(face.rakeLength.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF7B68EE)),
                  textAlign: TextAlign.center)),
          Expanded(
              child: Text(face.eaveTimesRake.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center)),
        ]),
      );
}
