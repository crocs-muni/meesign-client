class MimeType {
  final String value;

  const MimeType(this.value);

  static const textUtf8 = MimeType('text/plain;charset=UTF-8');
  static const octetStream = MimeType('application/octet-stream');

  bool get isText => value.startsWith('text/');

  @override
  bool operator ==(other) {
    if (other is! MimeType) return false;
    return value.toLowerCase() == other.value.toLowerCase();
  }

  @override
  int get hashCode => value.toLowerCase().hashCode;
}
