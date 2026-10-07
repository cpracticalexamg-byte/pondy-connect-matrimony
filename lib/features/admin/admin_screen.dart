import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../data/csv/csv_store.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, int> _rowCounts = {};
  bool _isLoading = true;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadRowCounts();
  }

  Future<void> _loadRowCounts() async {
    setState(() => _isLoading = true);
    final counts = await CsvStore.instance.getRowCounts();
    if (mounted) {
      setState(() {
        _rowCounts = counts;
        _isLoading = false;
      });
    }
  }

  Future<void> _exportZip() async {
    setState(() => _statusMessage = 'Exporting database zip...');
    try {
      final zipBytes = await CsvStore.instance.exportAsZip();
      final tempDir = await getTemporaryDirectory();
      final zipFile = File('${tempDir.path}/pondy_matrimony_csv_export.zip');
      await zipFile.writeAsBytes(zipBytes);

      await Share.shareXFiles(
        [XFile(zipFile.path)],
        subject: 'Pondy Connect Matrimony CSV Database Export',
      );

      setState(() => _statusMessage = 'Export ready! Share sheet opened.');
    } catch (e) {
      setState(() => _statusMessage = 'Export failed: $e');
    }
  }

  Future<void> _resetDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text('This will delete all local changes and re-seed from bundled demo assets.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await CsvStore.instance.resetDatabase();
      await _loadRowCounts();
      setState(() => _statusMessage = 'Database reset and re-seeded successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Dev / Admin Console'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRowCounts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_statusMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Database Management', style: AppTypography.sectionTitle()),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Export CSVs as ZIP',
                          icon: Icons.share,
                          type: AppButtonType.primary,
                          height: 48,
                          onPressed: _exportZip,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Reset Database to Seed State',
                          icon: Icons.restore,
                          type: AppButtonType.outline,
                          height: 48,
                          onPressed: _resetDatabase,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Table Row Counts Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Table Row Counts', style: AppTypography.sectionTitle()),
                            Text('${_rowCounts.values.fold(0, (a, b) => a + b)} total rows', style: AppTypography.caption()),
                          ],
                        ),
                        const Divider(height: 24),
                        ..._rowCounts.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.table_chart_outlined, size: 16, color: AppColors.textMuted),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${e.key}.csv',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: e.value > 0 ? AppColors.primaryLight : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${e.value} rows',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: e.value > 0 ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
