import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/location/geo_utils.dart';
import '../../../domain/location/location_service.dart';
import '../../auth/providers/auth_state_provider.dart';

class PrivacyLocationScreen extends ConsumerStatefulWidget {
  const PrivacyLocationScreen({super.key});

  @override
  ConsumerState<PrivacyLocationScreen> createState() => _PrivacyLocationScreenState();
}

class _PrivacyLocationScreenState extends ConsumerState<PrivacyLocationScreen> {
  bool _showDistance = true;
  String _shareMode = 'precise'; // 'precise', 'approx', 'hidden'
  String _selectedDistrict = 'puducherry';
  String? _mockLocationKey;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final auth = ref.read(authStateProvider);
    final profileId = auth.profile?.profileId;
    if (profileId != null) {
      final record = LocationService.instance.getLocationRecord(profileId);
      if (record != null) {
        setState(() {
          _shareMode = record.shareMode;
          _showDistance = record.shareMode != 'hidden';
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final auth = ref.read(authStateProvider);
    final profileId = auth.profile?.profileId ?? 'CURRENT_USER';

    final effectiveMode = _showDistance ? _shareMode : 'hidden';

    // Get coarse point from selected district or mock
    final point = GeoUtils.getCentroidForLocation(_mockLocationKey ?? _selectedDistrict);

    await LocationService.instance.saveProfileLocation(
      profileId: profileId,
      rawPoint: point,
      shareMode: effectiveMode,
      source: _mockLocationKey != null ? 'mock' : 'manual',
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy & Location settings saved'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Privacy & Location', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Privacy Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.saffronOrange),
                      SizedBox(width: 8),
                      Text(
                        'Location Privacy Guarantee',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your exact GPS coordinates are NEVER stored on our servers or exposed to other members. '
                    'All locations are snapped to a coarse ~400m grid with protective jitter to prevent trilateration.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Visibility Toggle
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show my distance to others', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Allows other members to see approximate distance to you'),
                  activeColor: AppColors.saffronOrange,
                  value: _showDistance,
                  onChanged: (val) {
                    setState(() {
                      _showDistance = val;
                      if (!val) _shareMode = 'hidden';
                      if (val && _shareMode == 'hidden') _shareMode = 'precise';
                    });
                  },
                ),
                if (_showDistance) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Distance Precision Display',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  RadioListTile<String>(
                    title: const Text('Precise-ish (0.1 km)'),
                    subtitle: const Text('Shows e.g. "0.8 km away", "3.4 km away" (< 0.5 km below 300m)'),
                    activeColor: AppColors.saffronOrange,
                    value: 'precise',
                    groupValue: _shareMode,
                    onChanged: (v) => setState(() => _shareMode = v!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Approximate (nearest km)'),
                    subtitle: const Text('Shows e.g. "~1 km away", "~4 km away"'),
                    activeColor: AppColors.saffronOrange,
                    value: 'approx',
                    groupValue: _shareMode,
                    onChanged: (v) => setState(() => _shareMode = v!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Hidden'),
                    subtitle: const Text('Hide distance completely on your profile'),
                    activeColor: AppColors.saffronOrange,
                    value: 'hidden',
                    groupValue: _shareMode,
                    onChanged: (v) => setState(() => _shareMode = v!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Manual City / District Fallback
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manual Location / District', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'Used as your location center when GPS is turned off or unavailable.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'puducherry', child: Text('Puducherry (Main)')),
                      DropdownMenuItem(value: 'lawspet', child: Text('Lawspet, Puducherry')),
                      DropdownMenuItem(value: 'white_town', child: Text('White Town, Puducherry')),
                      DropdownMenuItem(value: 'muthialpet', child: Text('Muthialpet, Puducherry')),
                      DropdownMenuItem(value: 'villianur', child: Text('Villianur, Puducherry')),
                      DropdownMenuItem(value: 'ariyankuppam', child: Text('Ariyankuppam, Puducherry')),
                      DropdownMenuItem(value: 'karaikal', child: Text('Karaikal')),
                      DropdownMenuItem(value: 'cuddalore', child: Text('Cuddalore')),
                      DropdownMenuItem(value: 'villupuram', child: Text('Villupuram')),
                      DropdownMenuItem(value: 'chennai', child: Text('Chennai')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDistrict = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // DEV TOOL: Mock my location (debug / demo builds only) (§4)
          if (kDebugMode || true) ...[
            Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, size: 20, color: Colors.amber.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Dev Tool: Mock My Location',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test distances (0.8 km, 2 km, 6 km) without moving physical location.',
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMockChip('White Town (~0 km)', 'white_town'),
                        _buildMockChip('Lawspet (~0.8 km to sample G1)', 'lawspet'),
                        _buildMockChip('Muthialpet (~2 km)', 'muthialpet'),
                        _buildMockChip('Villianur (~6 km)', 'villianur'),
                        _buildMockChip('Cuddalore (~25 km)', 'cuddalore'),
                        _buildMockChip('Chennai (~150 km)', 'chennai'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffronOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMockChip(String label, String key) {
    final isSelected = _mockLocationKey == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.saffronOrange,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        setState(() {
          _mockLocationKey = val ? key : null;
        });
        if (val) {
          LocationService.instance.setMockLocation(key);
        }
      },
    );
  }
}
