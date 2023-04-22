import 'dart:io';

import 'package:winamp_pls/winamp_pls.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Test typical playlist', () {
      var p = Parser();
      var testFile = File('test/test1.pls');
      var content = testFile.readAsStringSync();
      var playlist = p.parse(content);
      
      expect(playlist.length, 5);

      expect(playlist.first.index, 1);
      expect(playlist.first.file, r'Alternative\everclear - SMFTA.mp3');
      expect(playlist.first.title, 'Everclear - So Much For The Afterglow');
      expect(playlist.first.length, 233);
    });

    test('Test shoutcast', () {
      var p = Parser();
      var testFile = File('test/tunein-station.pls');
      var content = testFile.readAsStringSync();
      var playlist = p.parse(content);

      expect(playlist.length, 1);

      expect(playlist.first.index, 1);
      expect(playlist.first.file, 'http://stream.antenne.de:80/antenne');
      expect(playlist.first.title, '(#1 - 11993/500000) ANTENNE BAYERN');
      expect(playlist.first.length, -1);
    });
  });
}
