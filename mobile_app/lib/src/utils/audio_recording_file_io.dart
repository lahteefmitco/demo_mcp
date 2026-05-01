import 'dart:io';
import 'dart:typed_data';

Future<String> buildAudioRecordingPath() async {
  return '${Directory.systemTemp.path}/gulfon_chat_${DateTime.now().microsecondsSinceEpoch}.m4a';
}

Future<Uint8List> readAudioRecordingBytes(String path) {
  return File(path).readAsBytes();
}
