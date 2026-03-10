// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/roof_provider.dart';
import '../widgets/roof_3d_view.dart';
import '../widgets/roof_2d_view.dart';
import '../widgets/calculations_panel.dart';
import '../widgets/face_list_sheet.dart';
import '../widgets/summary_panel.dart';

const _kBlue = Color(0xFF4A90D9);
const _kBg = Color(0xFF0D1117);
const _kCard = Color(0xFF141826);

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _showCalc = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoofProvider>(builder: (ctx, roof, _) {
      if (!roof.hasData) {
        return const Scaffold(
          backgroundColor: _kBg,
          body: Center(child: CircularProgressIndicator(color: _kBlue)),
        );
      }
      final m = roof.model!;

      return Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: Column(children: [
            _TopBar(
              roofProvider: roof,
              showCalc: _showCalc,
              onToggleCalc: () => setState(() => _showCalc = !_showCalc),
              onInfo: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => const SummaryPanel(),
              ),
              onFaceList: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const FaceListSheet(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF0F1520),
              child: Row(children: [
                const Icon(Icons.location_on_outlined, size: 13, color: _kBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${m.address}, ${m.city}, ${m.state}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                _StatPill('${m.faceCount} faces'),
                const SizedBox(width: 6),
                _StatPill('${m.totalArea.toStringAsFixed(0)} sqft'),
              ]),
            ),
            Container(
              color: _kCard,
              child: TabBar(
                controller: _tabCtrl,
                indicatorColor: _kBlue,
                indicatorWeight: 2.5,
                labelColor: _kBlue,
                unselectedLabelColor: Colors.white38,
                labelStyle: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w400),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.view_in_ar_rounded, size: 15),
                      text: '3D View'),
                  Tab(
                      icon: Icon(Icons.map_outlined, size: 15),
                      text: '2D Plan'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: const [
                  Roof3DView(),
                  Roof2DView(),
                ],
              ),
            ),
            if (_showCalc)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CalculationsPanel(
                  onClose: () => setState(() => _showCalc = false),
                ),
              ),
          ]),
        ),
      );
    });
  }
}

class _TopBar extends StatelessWidget {
  final RoofProvider roofProvider;
  final bool showCalc;
  final VoidCallback onToggleCalc;
  final VoidCallback onInfo;
  final VoidCallback onFaceList;

  const _TopBar({
    required this.roofProvider,
    required this.showCalc,
    required this.onToggleCalc,
    required this.onInfo,
    required this.onFaceList,
  });

  @override
  Widget build(BuildContext context) {
    final selCount = roofProvider.selectedFaceIds.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: _kCard,
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white70, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF3A7BD5), Color(0xFF7B4FD9)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.roofing_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text('RoofLens',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const Spacer(),
        if (selCount > 0)
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _kBlue.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBlue.withOpacity(0.4)),
            ),
            child: Text('$selCount selected',
                style: GoogleFonts.inter(
                    fontSize: 11, color: _kBlue, fontWeight: FontWeight.w700)),
          ),
        IconButton(
          icon: const Icon(Icons.layers_outlined,
              color: Colors.white54, size: 20),
          onPressed: onFaceList,
          tooltip: 'Face List',
        ),
        IconButton(
          icon: const Icon(Icons.info_outline_rounded,
              color: Colors.white54, size: 20),
          onPressed: onInfo,
          tooltip: 'Summary',
        ),
        IconButton(
          icon: Icon(
            showCalc ? Icons.calculate_rounded : Icons.calculate_outlined,
            color: showCalc ? _kBlue : Colors.white54,
            size: 20,
          ),
          onPressed: onToggleCalc,
          tooltip: 'Calculations',
        ),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String text;
  const _StatPill(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: _kBlue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _kBlue.withOpacity(0.25)),
        ),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 10, color: _kBlue, fontWeight: FontWeight.w600)),
      );
}
