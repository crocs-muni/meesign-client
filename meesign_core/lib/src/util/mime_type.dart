class MimeType {
  final String value;

  const MimeType(this.value);

  static const textUtf8 = MimeType('text/plain;charset=UTF-8');
  static const octetStream = MimeType('application/octet-stream');
  static const imageSvg = MimeType('image/svg+xml');

  bool get isText => value.startsWith('text/');
  bool get isImage => value.startsWith('image/');

  @override
  bool operator ==(other) {
    if (other is! MimeType) return false;
    return value.toLowerCase() == other.value.toLowerCase();
  }

  @override
  int get hashCode => value.toLowerCase().hashCode;
}
