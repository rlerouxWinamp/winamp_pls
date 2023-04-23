import 'dart:io';

import 'package:winamp_pls/winamp_pls.dart';
import 'package:test/test.dart';

void main() {
  group('Parser tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Test typical playlist', () {
      var testFile = File('test/files/playlist.pls');
      var content = testFile.readAsStringSync();
      var playlist = parsePls(content);
      
      expect(playlist.length, 5);

      expect(playlist.first.index, 1);
      expect(playlist.first.file, r'Alternative\everclear - SMFTA.mp3');
      expect(playlist.first.title, 'Everclear - So Much For The Afterglow');
      expect(playlist.first.length, 233);
    });

    test('Test shoutcast', () {
      var testFile = File('test/files/tunein-station.pls');
      var content = testFile.readAsStringSync();
      var playlist = parsePls(content);

      expect(playlist.length, 1);

      expect(playlist.first.index, 1);
      expect(playlist.first.file, 'http://stream.antenne.de:80/antenne');
      expect(playlist.first.title, '(#1 - 11993/500000) ANTENNE BAYERN');
      expect(playlist.first.length, -1);
    });

    test('Test winamp', () {
      var testFile = File('test/files/winamp.pls');
      var content = testFile.readAsStringSync();
      var playlist = parsePls(content);

      expect(playlist.length, 2);

      expect(playlist.first.index, 1);
      expect(playlist.first.file, 'https://dancewave.online:443/dance.mp3');
      expect(playlist.first.title, 'All about Dance from 2000 till today! (Dance Wave!)');
      expect(playlist.first.length, -1);
      
      expect(playlist.last.index, 2);
      expect(playlist.last.file, r'C:\Users\User Name\AppData\Roaming\Winamp\demo.mp3');
      expect(playlist.last.title, 'DJ Mike Llama - Llama Whippin\' Intro');
      expect(playlist.last.length, 5);
    });
  });
}
