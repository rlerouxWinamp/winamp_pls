class ParserException implements Exception {
  final String message;
  final int? lineIndex;

  const ParserException([this.message = '', this.lineIndex]);

  @override
  String toString() => 'ParserException: $message${lineIndex != null ? ' at line $lineIndex' : ''}';
}
