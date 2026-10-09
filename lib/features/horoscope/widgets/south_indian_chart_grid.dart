import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Traditional South Indian 4x4 Vedic Horoscope Chart (Raasi / Navamsam).
/// Houses 1 to 12 are arrayed in fixed zodiac positions around the central 2x2 courtyard.
class SouthIndianChartGrid extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Map<int, List<String>> planetsInHouses; // Key 1 to 12 (1 = Mesham, ..., 12 = Meenam)
  final int? lagnaHouse; // House 1 to 12
  final double size;

  const SouthIndianChartGrid({
    super.key,
    this.title = 'ராசி கட்டம்',
    this.subtitle,
    this.planetsInHouses = const {},
    this.lagnaHouse,
    this.size = 320,
  });

  // South Indian house coordinates on 4x4 grid (row, col):
  // 12 (Meenam): (0, 0)
  // 1 (Mesham):  (0, 1)
  // 2 (Rishabam):(0, 2)
  // 3 (Mithunam):(0, 3)
  // 4 (Kadagam): (1, 3)
  // 5 (Simmam):  (2, 3)
  // 6 (Kanni):   (3, 3)
  // 7 (Thulam):  (3, 2)
  // 8 (Viruchigam): (3, 1)
  // 9 (Dhanusu): (3, 0)
  // 10 (Makaram):(2, 0)
  // 11 (Kumbam): (1, 0)
  static const Map<int, (int, int)> housePositions = {
    12: (0, 0),
    1: (0, 1),
    2: (0, 2),
    3: (0, 3),
    4: (1, 3),
    5: (2, 3),
    6: (3, 3),
    7: (3, 2),
    8: (3, 1),
    9: (3, 0),
    10: (2, 0),
    11: (1, 0),
  };

  static const Map<int, String> houseTamilNames = {
    1: 'மேஷம்',
    2: 'ரிஷபம்',
    3: 'மிதுனம்',
    4: 'கடகம்',
    5: 'சிம்மம்',
    6: 'கன்னி',
    7: 'துலாம்',
    8: 'விருச்சிகம்',
    9: 'தனுசு',
    10: 'மகரம்',
    11: 'கும்பம்',
    12: 'மீனம்',
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.maroonBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Outer 4x4 Grid Outline
            CustomPaint(
              size: Size(size, size),
              painter: _SouthIndianChartPainter(),
            ),

            // 12 House Cell Contents
            ...housePositions.entries.map((entry) {
              final houseNumber = entry.key;
              final (row, col) = entry.value;
              final cellWidth = size / 4;
              final cellHeight = size / 4;

              final planets = planetsInHouses[houseNumber] ?? [];
              final isLagna = lagnaHouse == houseNumber;

              return Positioned(
                left: col * cellWidth,
                top: row * cellHeight,
                width: cellWidth,
                height: cellHeight,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // House subtle label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              houseTamilNames[houseNumber] ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          if (isLagna)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'லக்',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      // Planets residing in house
                      if (planets.isNotEmpty)
                        Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: planets.map((p) {
                            return Text(
                              p,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            }),

            // Center Courtyard (2x2)
            Positioned(
              left: size / 4,
              top: size / 4,
              width: size / 2,
              height: size / 2,
              child: Container(
                color: const Color(0xFFFFFBEB),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroonText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SouthIndianChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.maroonBorder
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final cellW = size.width / 4;
    final cellH = size.height / 4;

    // Horizontal Lines: skip center courtyard
    // Line 1: (0, cellH) to (4*cellW, cellH)
    canvas.drawLine(Offset(0, cellH), Offset(size.width, cellH), paint);
    // Line 2: (0, 2*cellH) to (cellW, 2*cellH) and (3*cellW, 2*cellH) to (4*cellW, 2*cellH)
    canvas.drawLine(Offset(0, cellH * 2), Offset(cellW, cellH * 2), paint);
    canvas.drawLine(Offset(cellW * 3, cellH * 2), Offset(size.width, cellH * 2), paint);
    // Line 3: (0, 3*cellH) to (4*cellW, 3*cellH)
    canvas.drawLine(Offset(0, cellH * 3), Offset(size.width, cellH * 3), paint);

    // Vertical Lines: skip center courtyard
    // Line 1: (cellW, 0) to (cellW, size.height)
    canvas.drawLine(Offset(cellW, 0), Offset(cellW, size.height), paint);
    // Line 2: (2*cellW, 0) to (2*cellW, cellH) and (2*cellW, 3*cellH) to (2*cellW, size.height)
    canvas.drawLine(Offset(cellW * 2, 0), Offset(cellW * 2, cellH), paint);
    canvas.drawLine(Offset(cellW * 2, cellH * 3), Offset(cellW * 2, size.height), paint);
    // Line 3: (3*cellW, 0) to (3*cellW, size.height)
    canvas.drawLine(Offset(cellW * 3, 0), Offset(cellW * 3, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
