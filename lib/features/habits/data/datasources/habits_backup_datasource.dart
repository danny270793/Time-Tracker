import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Moves JSON habit backups in and out of the device (share sheet / picker).
class HabitsBackupDatasource {
  /// Writes [json] to a temporary file and opens the system share sheet.
  Future<void> share(String json, {required String title}) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/habits-export.json');
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], title: title),
    );
  }

  /// Lets the user pick a `.json` file; returns its contents or `null`.
  Future<String?> pickJson() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null) return null;
    return String.fromCharCodes(await picked.readAsBytes());
  }
}
