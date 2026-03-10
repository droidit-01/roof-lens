// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/roof_provider.dart';

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoofProvider>(builder: (ctx, p, _) {
      final m = p.model;
      if (m == null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFF141826),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08))),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF4A90D9), Color(0xFF7B4FD9)]),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.home_outlined,
                        color: Colors.white, size: 22)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(m.address,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text('${m.city}, ${m.state} ${m.postal}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF8892A4))),
                    ])),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF4A90D9).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF4A90D9).withOpacity(0.3))),
                    child: Text(m.sourceFormat,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF4A90D9),
                            fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: _Stat('Total Area', m.totalArea.toStringAsFixed(0),
                        'sqft', Icons.square_foot, const Color(0xFF4A90D9))),
                const SizedBox(width: 12),
                Expanded(
                    child: _Stat('Roof Faces', '${m.faceCount}', 'faces',
                        Icons.layers_outlined, const Color(0xFF7B68EE))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _Stat('Avg Pitch', m.averagePitch.toStringAsFixed(2),
                        'ratio', Icons.trending_up, const Color(0xFF50C878))),
                const SizedBox(width: 12),
                Expanded(
                    child: _Stat(
                        'Lat',
                        m.lat.toStringAsFixed(4),
                        m.lng.toStringAsFixed(4),
                        Icons.location_on_outlined,
                        const Color(0xFFFF7F50))),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2535),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text('Close',
                          style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600)))),
            ]),
      );
    });
  }
}

class _Stat extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.unit, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1E2535),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(unit,
              style: GoogleFonts.inter(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: const Color(0xFF8892A4))),
        ]),
      );
}
