import 'dart:convert';

class Parser {
  static const splitter = LineSplitter();
  
  final _fileRegExp = RegExp(r'^[Ff]ile(?<index>\d+)=(?<file>.*)$');
  final _titleRegExp = RegExp(r'^[Tt]itle(?<index>\d+)=(?<title>.*)$');
  final _lengthRegExp = RegExp(r'^[Ll]ength(?<index>\d+)=(?<length>.*)$');
  
  final _playlistEntries = <int,PlaylistEntry>{};
  int? _numberOfEntries = null;
  
  List<PlaylistEntry> parse(String content) {
    final lines = splitter.convert(content);
    
    if (lines[0] != '[playlist]') {
      throw ParserException('Missing [playlist] at start');
    }
    
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      _parseLine(line, i);
    }
    
    if (_numberOfEntries != null && _playlistEntries.length != _numberOfEntries) {
      throw ParserException("NumberOfEntries mismatch : in file ($_numberOfEntries) vs parsed($_playlistEntries.length)");
    }
    
    var result = _playlistEntries.values.toList();
    result.sort((a,b) => a.index.compareTo(b.index));
    return result;
  }
  
  void _parseLine(String line, int lineIndex) {
    if (line.isEmpty || line.trim() == '') {
      return; // skip empty lines
    }
    
    if (line.startsWith('File') || line.startsWith('file')) {
      _parseFileLine(line, lineIndex);
    }
    else if (line.startsWith('Title') || line.startsWith('title')) {
      _parseTitleLine(line, lineIndex);
    }
    else if (line.startsWith('Length') || line.startsWith('length')) {
      _parseLengthLine(line, lineIndex);
    }
    else if (line.startsWith('NumberOfEntries=') || line.startsWith('numberofentries=')) {
      _numberOfEntries = int.parse(line.substring('NumberOfEntries='.length));
    }
    else if (line.startsWith('Version=') || line.startsWith('version=')) {
      print(line);
    }
    else {
      print('Unknown line "$line"');
    }
  }
  
  void _parseFileLine(String line, int lineIndex) {
    var match = _fileRegExp.firstMatch(line);
    
    if (match == null) {
      throw ParserException('Invalid "File" at line $lineIndex : "$line"');
    }
    
    var index = int.parse(match.namedGroup('index')!);
    var entry = _getOrCreatePlaylistEntryAt(index);
    entry.file = match.namedGroup('file')!;
  }

  void _parseTitleLine(String line, int lineIndex) {
    var match = _titleRegExp.firstMatch(line);

    if (match == null) {
      throw ParserException('Invalid "Title" at line $lineIndex : "$line"');
    }

    var index = int.parse(match.namedGroup('index')!);
    var entry = _getOrCreatePlaylistEntryAt(index);
    entry.title = match.namedGroup('title')!;
  }

  void _parseLengthLine(String line, int lineIndex) {
    var match = _lengthRegExp.firstMatch(line);

    if (match == null) {
      throw ParserException('Invalid "Length" at line $lineIndex : "$line"');
    }
      

    var index = int.parse(match.namedGroup('index')!);
    var entry = _getOrCreatePlaylistEntryAt(index);
    entry.length = int.parse(match.namedGroup('length')!);
  }
  
  PlaylistEntry _getOrCreatePlaylistEntryAt(int index) {
    if (!_playlistEntries.containsKey(index)) {
      _playlistEntries[index] = PlaylistEntry(index);
    }
    return _playlistEntries[index]!;
  }
}

class ParserException implements Exception {
  final String message;
  const ParserException(this.message);
  @override
  String toString() => 'ParserException: $message';
}

class PlaylistEntry {
  final int index;
  
  late String file;
  
  String title = '';
  int length = -1;
  
  PlaylistEntry(this.index);
}
