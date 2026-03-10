// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/roof_provider.dart';
import 'viewer_screen.dart';

const _kBlue = Color(0xFF4A90D9);
const _kBg = Color(0xFF0D1117);
const _kCard = Color(0xFF141826);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<RoofProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) return const _LoadingView();
          if (provider.loadingState == LoadingState.error) {
            return _ErrorView(message: provider.errorMessage);
          }
          return _HomeBody(provider: provider);
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final RoofProvider provider;
  const _HomeBody({required this.provider});

  void _go(BuildContext ctx) {
    if (provider.loadingState == LoadingState.loaded) {
      Navigator.of(ctx)
          .push(MaterialPageRoute(builder: (_) => const ViewerScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 52),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: _kBlue.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 18),
          Text('RoofLens',
              style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1)),
          const SizedBox(height: 6),
          Text('Professional Roof Measurement Viewer',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
          const SizedBox(height: 48),
          const _SectionLabel('Sample Files'),
          const SizedBox(height: 10),
          _SampleTile(
            icon: Icons.home_rounded,
            title: 'Hover XML  —  5 Roof Faces',
            subtitle: '312 Lake Shore Drive, Parsippany, NJ',
            badge: 'HOVER',
            badgeColor: const Color(0xFF50C878),
            onTap: () async {
              await provider.loadFromAsset('assets/xml/hover_sample.xml');
              if (context.mounted) _go(context);
            },
          ),
          const SizedBox(height: 10),
          _SampleTile(
            icon: Icons.home_work_rounded,
            title: 'EagleView XML  —  12 Roof Faces',
            subtitle: '21420 Humbolt Sq, Ashburn, VA',
            badge: 'EAGLEVIEW',
            badgeColor: const Color(0xFFE8B84B),
            onTap: () async {
              await provider.loadFromAsset('assets/xml/eagleview_sample.xml');
              if (context.mounted) _go(context);
            },
          ),
          const SizedBox(height: 30),
          const _SectionLabel('Import Your Own File'),
          const SizedBox(height: 10),
          _ImportCard(onTap: () async {
            final r = await FilePicker.platform.pickFiles(
                type: FileType.custom, allowedExtensions: ['xml', 'XML']);
            if (r?.files.single.path != null) {
              await provider.loadFromFile(r!.files.single.path!);
              if (context.mounted) _go(context);
            }
          }),
          const SizedBox(height: 36),
          const Row(children: [
            Expanded(child: _Badge(Icons.view_in_ar_rounded, '3D Orbit')),
            SizedBox(width: 10),
            Expanded(child: _Badge(Icons.map_outlined, '2D Plan')),
            SizedBox(width: 10),
            Expanded(child: _Badge(Icons.calculate_outlined, 'Ev × Rk')),
          ]),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
                letterSpacing: 0.5)),
      );
}

class _SampleTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, badge;
  final Color badgeColor;
  final VoidCallback onTap;
  const _SampleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _kBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _kBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white38)),
                  ])),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withOpacity(0.4)),
                ),
                child: Text(badge,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        color: badgeColor,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24, size: 20),
            ]),
          ),
        ),
      );
}

class _ImportCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ImportCard({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBlue.withOpacity(0.3), width: 1.5),
            ),
            child: Column(children: [
              const Icon(Icons.upload_file_rounded, color: _kBlue, size: 28),
              const SizedBox(height: 8),
              Text('Browse & Import XML',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text('EagleView & Hover formats supported',
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
            ]),
          ),
        ),
      );
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(children: [
          Icon(icon, color: _kBlue, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
        ]),
      );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: _kBlue),
          SizedBox(height: 16),
          Text('Parsing XML…', style: TextStyle(color: Colors.white54)),
        ]),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 52),
            const SizedBox(height: 16),
            const Text('Failed to parse file',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(backgroundColor: _kBlue),
            ),
          ]),
        ),
      );
}
