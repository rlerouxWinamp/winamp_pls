import 'dart:convert';
import 'dart:developer';

import 'parser_exception.dart';
import 'playlist_entry.dart';

const splitter = LineSplitter();

final _fileRegExp = RegExp(r'^[Ff]ile(?<index>\d+)=(?<file>.*)$');
final _titleRegExp = RegExp(r'^[Tt]itle(?<index>\d+)=(?<title>.*)$');
final _lengthRegExp = RegExp(r'^[Ll]ength(?<index>\d+)=(?<length>.*)$');

List<PlaylistEntry> parsePls(String content) {
  final lines = splitter.convert(content);

  if (lines.first != '[playlist]') {
    throw ParserException('Missing [playlist] at start');
  }

  final context = _ParserContext();
  for (int i = 1; i < lines.length; i++) {
    context.line = lines[i];
    context.lineIndex = i;
    _parseLine(context);
  }

  final n = context.numberOfEntries;
  final pn = context.playlistEntries.length;
  if (n != null && n != pn) {
    throw ParserException(
        "NumberOfEntries mismatch : claimed($n) vs parsed($pn)");
  }

  var result = context.playlistEntries.values.toList();
  result.sort((a, b) => a.index.compareTo(b.index));
  return result;
}

void _parseLine(_ParserContext context) {
  if (context.line.isEmpty || context.line.trim() == '') {
    return; // skip empty lines
  }

  // We're generous with casing
  // For ex: the shoutcast directory files contain
  // lowercase "numberofentries" instead of "NumberOfEntries"
  if (context.line.startsWith('File') || context.line.startsWith('file')) {
    _parseFileLine(context);
  } else if (context.line.startsWith('Title') ||
      context.line.startsWith('title')) {
    _parseTitleLine(context);
  } else if (context.line.startsWith('Length') ||
      context.line.startsWith('length')) {
    _parseLengthLine(context);
  } else if (context.line.startsWith('NumberOfEntries=') ||
      context.line.startsWith('numberofentries=')) {
    _parseNumberOfEntries(context);
  } else if (context.line.startsWith('Version=') ||
      context.line.startsWith('version=')) {
    log(context.line);
  } else {
    log('Unknown "${context.line}" at line ${context.lineIndex}');
  }
}

void _parseFileLine(_ParserContext context) {
  var match = _fileRegExp.firstMatch(context.line);

  if (match == null) {
    throw ParserException(
        'Invalid "File" in "${context.line}"', context.lineIndex);
  }

  var index = int.parse(match.namedGroup('index')!);
  context.getEntryAt(index).file = match.namedGroup('file')!;
}

void _parseTitleLine(_ParserContext context) {
  var match = _titleRegExp.firstMatch(context.line);

  if (match == null) {
    throw ParserException(
        'Invalid "Title" in "${context.line}"', context.lineIndex);
  }

  var index = int.parse(match.namedGroup('index')!);
  context.getEntryAt(index).title = match.namedGroup('title')!;
}

void _parseLengthLine(_ParserContext context) {
  var match = _lengthRegExp.firstMatch(context.line);

  if (match == null) {
    throw ParserException(
        'Invalid "Length" in "${context.line}"', context.lineIndex);
  }

  var index = int.parse(match.namedGroup('index')!);
  context.getEntryAt(index).length = int.parse(match.namedGroup('length')!);
}

void _parseNumberOfEntries(_ParserContext context) {
  final n = int.tryParse(context.line.substring('NumberOfEntries='.length));
  if (n == null) {
    throw ParserException(
        'Invalid "NumberOfEntries" in "${context.line}"', context.lineIndex);
  }
}

class _ParserContext {
  final playlistEntries = <int, PlaylistEntry>{};
  int? numberOfEntries;
  late String line;
  late int lineIndex;

  PlaylistEntry getEntryAt(int index) {
    if (!playlistEntries.containsKey(index)) {
      playlistEntries[index] = PlaylistEntry(index);
    }
    return playlistEntries[index]!;
  }
}
