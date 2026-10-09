// ignore_for_file: avoid_print
import 'dart:io';
import 'package:archive/archive.dart';

void main() async {
  print('==============================================');
  print('EXPORTING AZURE MIGRATION BUNDLE');
  print('==============================================');

  final archive = Archive();

  // Add db/schema
  final schemaDir = Directory('db/schema');
  if (await schemaDir.exists()) {
    for (final f in schemaDir.listSync(recursive: true).whereType<File>()) {
      final name = f.path.replaceAll('\\', '/');
      final bytes = await f.readAsBytes();
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }
  }

  // Add db/azure
  final azureDir = Directory('db/azure');
  if (await azureDir.exists()) {
    for (final f in azureDir.listSync(recursive: true).whereType<File>()) {
      final name = f.path.replaceAll('\\', '/');
      final bytes = await f.readAsBytes();
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }
  }

  // Add db/master
  final masterDir = Directory('db/master');
  if (await masterDir.exists()) {
    for (final f in masterDir.listSync(recursive: true).whereType<File>()) {
      final name = f.path.replaceAll('\\', '/');
      final bytes = await f.readAsBytes();
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }
  }

  final zipEncoder = ZipEncoder();
  final zipBytes = zipEncoder.encode(archive);
  if (zipBytes != null) {
    final bundleFile = File('db/azure_migration_bundle.zip');
    await bundleFile.writeAsBytes(zipBytes);
    print('  [✓] Successfully created db/azure_migration_bundle.zip (${zipBytes.length} bytes)');
  }
}
