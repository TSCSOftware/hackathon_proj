import 'dart:io';
import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bg.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:pocketbase/pocketbase.dart';

final pb_admin = PocketBase('http://test.otan.cc:8095', reuseHTTPClient: true);

Future<String> Upload_file() async {
  var userid = await storage.read(key: "vv_id");
  var uuidxx = "$userid${DateTime.now().microsecondsSinceEpoch}";
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
  );

  if (result != null) {
    List<File> files = result.paths.map((path) => File(path!)).toList();
    List<String> tempFilePaths = [];
    for (var file in files) {
      print('Selected file: ${file.path}');
      // You can now upload the file to your server or process it as needed
      // copy files to temp directory
      final tempDir = Directory.systemTemp;
      final tempFile = await file.copy(
        '${tempDir.path}\\${file.uri.pathSegments.last}',
      );
      tempFilePaths.add(tempFile.path);
      print('Copied to temp location: ${tempFile.path}');
    }

    // Add to background queue
    final task = Bgtask(
      task_type: 'file_upload',
      body: {'filePaths': tempFilePaths, 'uuidxx': uuidxx},
    );
    await Bg_engine.add_to_queue(task);

    return uuidxx;
  } else {
    return "null";
    // User canceled the picker
  }
}
