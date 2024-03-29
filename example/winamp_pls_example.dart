import 'dart:io';

import 'package:winamp_pls/winamp_pls.dart';

void main() {
  final f = File('test/files/playlist.pls');
  var content = f.readAsStringSync();
  
  final playlist = parsePls(content);
  for (var entry in playlist) {
    print('Title : "${entry.title}"');
    print('File : "${entry.file}"');
    print('Length : "${entry.length}"');
  }
}
