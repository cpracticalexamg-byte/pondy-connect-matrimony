import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/horoscope/horoscope_engine.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../widgets/south_indian_chart_grid.dart';

class HoroscopeScreen extends ConsumerStatefulWidget {
  final String? candidateId;

  const HoroscopeScreen({super.key, this.candidateId});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen> {
  String _brideStar = 'ashwini';
  String _groomStar = 'bharani';
  String _brideRasi = 'Mesham';
  String _groomRasi = 'Rishabam';
  String _brideDosham = 'none';
  String _groomDosham = 'none';
  bool _isLoading = true;
  HoroscopeResult? _result;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final authState = ref.read(authStateProvider);
      final my = authState.profile;
      final profileRepo = ref.read(profileRepoProvider);

      if (my != null) {
        if (my.gender == 'Female') {
          _brideStar = my.star.isNotEmpty ? my.star : 'ashwini';
          _brideRasi = my.rasi.isNotEmpty ? my.rasi : 'Mesham';
          _brideDosham = my.dosham;
        } else {
          _groomStar = my.star.isNotEmpty ? my.star : 'bharani';
          _groomRasi = my.rasi.isNotEmpty ? my.rasi : 'Rishabam';
          _groomDosham = my.dosham;
        }
      }

      if (widget.candidateId != null && widget.candidateId!.isNotEmpty) {
        final candidate = await profileRepo.getProfileById(widget.candidateId!);
        if (candidate != null) {
          if (candidate.gender == 'Female') {
            _brideStar = candidate.star.isNotEmpty ? candidate.star : 'ashwini';
            _brideRasi = candidate.rasi.isNotEmpty ? candidate.rasi : 'Mesham';
            _brideDosham = candidate.dosham;
          } else {
            _groomStar = candidate.star.isNotEmpty ? candidate.star : 'bharani';
            _groomRasi = candidate.rasi.isNotEmpty ? candidate.rasi : 'Rishabam';
            _groomDosham = candidate.dosham;
          }
        }
      }

      _calculate();
    } catch (e, stack) {
      AppLogger.error('Failed to load horoscope profiles', tag: 'HoroscopeScreen', error: e, stackTrace: stack);
      _calculate();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculate() {
    final res = HoroscopeEngine.instance.evaluatePorutham(
      brideStar: _brideStar,
      groomStar: _groomStar,
      brideRasi: _brideRasi,
      groomRasi: _groomRasi,
      brideDosham: _brideDosham,
      groomDosham: _groomDosham,
    );
    setState(() {
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('10-Porutham Horoscope', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Result Summary Card
                  if (_result != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.purple.withAlpha(80), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                '${_result!.matchedCount} / 10 Poruthams Match',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _result!.overallVerdict,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMiniBadge(
                                'Rajju Porutham',
                                _result!.isRajjuMatched ? 'Matched ✓' : 'Remedy Required',
                                _result!.isRajjuMatched ? Colors.greenAccent : Colors.orangeAccent,
                              ),
                              _buildMiniBadge(
                                'Dosham Match',
                                _result!.isDoshamCompatible ? 'Compatible ✓' : 'Consult Astrologer',
                                _result!.isDoshamCompatible ? Colors.greenAccent : Colors.amberAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 2. Stars and Rasis Selection
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected Nakshatram & Rasi', style: AppTypography.heading3.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Bride (மணமகள்)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.saffronOrange)),
                                  const SizedBox(height: 4),
                                  Text('Star: ${_formatName(_brideStar)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text('Rasi: $_brideRasi', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey.shade200),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Groom (மணமகன்)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                                  const SizedBox(height: 4),
                                  Text('Star: ${_formatName(_groomStar)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text('Rasi: $_groomRasi', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Vedic Horoscope Raasi Chart
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vedic Horoscope Chart (ராசி கட்டம்)', style: AppTypography.heading3.copyWith(fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Positions: சந்(ம) = Bride Moon, சந்(வ) = Groom Moon',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 14),
                        SouthIndianChartGrid(
                          title: 'ராசி கட்டம்',
                          subtitle: 'Moon Placements',
                          planetsInHouses: _buildChartPlanets(),
                          size: 280,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. 10-Porutham Detailed Breakdown List
                  Text('Detailed 10-Porutham Analysis', style: AppTypography.heading3.copyWith(fontSize: 16)),
                  const SizedBox(height: 8),

                  if (_result != null)
                    ..._result!.items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.isMatched ? Colors.green.shade200 : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: item.isMatched ? Colors.green.shade50 : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.isMatched ? Icons.check_circle : Icons.cancel_outlined,
                                color: item.isMatched ? AppColors.successGreen : Colors.grey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.importance,
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item.tamilName,
                                    style: TextStyle(fontSize: 12, color: AppColors.saffronOrange.withAlpha(200), fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniBadge(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatName(String raw) {
    final clean = raw.replaceAll('star_', '').replaceAll('_', ' ');
    if (clean.isEmpty) return '';
    return clean[0].toUpperCase() + clean.substring(1);
  }

  int _getRasiHouseNumber(String rasi) {
    final clean = rasi.toLowerCase().replaceAll(' ', '');
    if (clean.contains('mesh')) return 1;
    if (clean.contains('rishab')) return 2;
    if (clean.contains('mithun')) return 3;
    if (clean.contains('kadag') || clean.contains('katak')) return 4;
    if (clean.contains('sim')) return 5;
    if (clean.contains('kanni')) return 6;
    if (clean.contains('thula') || clean.contains('tula')) return 7;
    if (clean.contains('viruch') || clean.contains('vris')) return 8;
    if (clean.contains('dhanu')) return 9;
    if (clean.contains('makar')) return 10;
    if (clean.contains('kumb')) return 11;
    if (clean.contains('meen')) return 12;
    return 1;
  }

  Map<int, List<String>> _buildChartPlanets() {
    final bHouse = _getRasiHouseNumber(_brideRasi);
    final gHouse = _getRasiHouseNumber(_groomRasi);
    final map = <int, List<String>>{};
    if (bHouse == gHouse) {
      map[bHouse] = ['சந்(ம)', 'சந்(வ)'];
    } else {
      map[bHouse] = ['சந்(ம)'];
      map[gHouse] = ['சந்(வ)'];
    }
    return map;
  }
}
